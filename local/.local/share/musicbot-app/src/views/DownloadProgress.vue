<script setup lang="ts">
import { computed, onMounted, onActivated, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NSpin, NButton, useDialog, useMessage } from 'naive-ui'
import { useJobsStore } from '@/stores/jobs'
import { useYtDlp, cancelJob, fetchJobStatus } from '@/api'
import JobProgress from '@/components/JobProgress.vue'

const route = useRoute()
const router = useRouter()
const jobsStore = useJobsStore()
const dialog = useDialog()
const message = useMessage()

const debugLogs = ref<string[]>([])

function log(msg: string) {
  const timestamp = new Date().toLocaleTimeString()
  debugLogs.value.push(`[${timestamp}] ${msg}`)
  if (debugLogs.value.length > 15) debugLogs.value.shift()
}

function copyDebugLogs() {
  const text = debugLogs.value.join('\n')
  navigator.clipboard.writeText(text).then(() => {
    message.success('Logs copiados!')
  }).catch(() => {
    message.error('Erro ao copiar')
  })
}

const jobId = route.params.jobId as string
const job = computed(() => jobsStore.getJob(jobId))

// Watch job changes to log (not inside computed to avoid infinite loop)
watch(job, (newJob) => {
  if (newJob) {
    const tracks = newJob.tracks.map(t => `${t.position}:${t.status}${t.needs_review?'(R)':''}`).join(' ')
    log(`job updated: ${newJob.status} tracks=[${tracks}]`)
  }
}, { deep: true })

// onActivated é chamado quando componente é reativado do keep-alive
onActivated(() => {
  log('activated')
  if (job.value && job.value.status !== 'done' && job.value.status !== 'failed') {
    jobsStore.startPolling(jobId)
  }
})

onMounted(() => {
  log('mounted')
  if (job.value && job.value.status !== 'done' && job.value.status !== 'failed') {
    jobsStore.startPolling(jobId)
  }
})

async function handleUseYtDlp(position: number) {
  try {
    log(`YT clicked for pos ${position}`)
    await useYtDlp(jobId, position)
  } catch (e) {
    log(`YT failed: ${e}`)
  }
}

function handleCancel() {
  dialog.warning({
    title: 'Cancelar Download',
    content: 'Tem certeza? Downloads em andamento serão cancelados.',
    positiveText: 'Sim, cancelar',
    negativeText: 'Não',
    onPositiveClick: async () => {
      try {
        await cancelJob(jobId)
        jobsStore.stopPolling(jobId)
        
        // Fetch updated status immediately
        const updated = await fetchJobStatus(jobId)
        jobsStore.jobs.set(jobId, updated)
        
        message.success('Download cancelado')
      } catch (e: any) {
        log(`cancel failed: ${e}`)
        message.error(e.message || 'Erro ao cancelar')
      }
    }
  })
}
</script>

<template>
  <div class="view">
    <!-- Debug overlay - always visible -->
    <div v-if="debugLogs.length > 0" class="debug-overlay" @click="copyDebugLogs">
      <div class="debug-header">🐛 Debug ({{ debugLogs.length }} logs - clique para copiar)</div>
      <div v-for="(line, i) in debugLogs" :key="i" class="debug-line">{{ line }}</div>
    </div>

    <div v-if="!job" class="center"><n-spin /></div>

    <div v-else class="content">
      <job-progress :job="job" @use-ytdlp="handleUseYtDlp" />

      <div v-if="job.status === 'done' || job.status === 'failed'" class="result">
        <n-button block @click="router.push('/')" style="margin-top: 24px">
          Voltar ao início
        </n-button>
      </div>
      
      <div v-else-if="job.status === 'running' || job.status === 'pending'" class="cancel-section">
        <n-button block quaternary type="error" @click="handleCancel" style="margin-top: 16px">
          🛑 Cancelar Download
        </n-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.view { min-height: 100%; position: relative; }
.content { padding: 24px 16px; }
.center { display: flex; align-items: center; justify-content: center; padding: 80px; }
.result { margin-top: 16px; }
.cancel-section { margin-top: 16px; }

.debug-overlay {
  position: fixed;
  bottom: 60px; /* acima da nav bar */
  left: 0;
  right: 0;
  background: rgba(0,0,0,0.95);
  color: #0f0;
  font-family: monospace;
  font-size: 10px;
  padding: 8px;
  z-index: 9999;
  max-height: 150px;
  overflow-y: auto;
  cursor: pointer;
  border-top: 2px solid #0f0;
}
.debug-header {
  color: #fff;
  font-weight: bold;
  margin-bottom: 4px;
  text-align: center;
}
.debug-line {
  padding: 2px 0;
  border-bottom: 1px solid rgba(0,255,0,0.2);
}
</style>
