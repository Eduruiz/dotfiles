<script setup lang="ts">
import { computed, onMounted } from 'vue'
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

const jobId = route.params.jobId as string
const job = computed(() => jobsStore.getJob(jobId))

onMounted(() => {
  if (job.value && job.value.status !== 'done' && job.value.status !== 'failed') {
    jobsStore.startPolling(jobId)
  }
})

async function handleUseYtDlp(position: number) {
  try {
    await useYtDlp(jobId, position)
  } catch (e) {
    console.error('use-ytdlp failed', e)
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
        console.error('cancel job failed', e)
        message.error(e.message || 'Erro ao cancelar')
      }
    }
  })
}
</script>

<template>
  <div class="view">
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
.view { min-height: 100%; }
.content { padding: 24px 16px; }
.center { display: flex; align-items: center; justify-content: center; padding: 80px; }
.result { margin-top: 16px; }
.cancel-section { margin-top: 16px; }
</style>
