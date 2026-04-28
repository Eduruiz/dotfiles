<script setup lang="ts">
import { computed } from 'vue'
import { NProgress, NButton } from 'naive-ui'
import type { JobStatus, TrackDownloadStatus } from '@/api'

const props = defineProps<{ job: JobStatus }>()
const emit = defineEmits<{ (e: 'use-ytdlp', position: number): void }>()

const done = computed(() => props.job.tracks.filter(t => t.status === 'done').length)
const total = computed(() => props.job.tracks.filter(t => t.status !== 'in_library').length)
const percentage = computed(() => total.value ? Math.round((done.value / total.value) * 100) : 0)

const progressStatus = computed(() => {
  if (props.job.status === 'failed') return 'error'
  if (props.job.status === 'done') return 'success'
  return 'default'
})

function statusText(t: TrackDownloadStatus): string {
  switch (t.status) {
    case 'in_library':  return 'biblioteca'
    case 'done':        return t.source === 'YtDlp' ? 'YouTube' : (t.source ?? '✓')
    case 'failed':      return 'falhou'
    case 'cancelled':   return 'cancelado'
    case 'converting':  return 'convertendo'
    case 'importing':   return 'importando'
    case 'downloading':
      if (t.percent != null && t.percent > 0) return `${Math.round(t.percent)}%`
      return t.source ?? 'baixando'
    default:            return 'aguardando'
  }
}

function statusColor(t: TrackDownloadStatus): string {
  switch (t.status) {
    case 'in_library':
    case 'done':       return 'var(--success-color, #34c759)'
    case 'failed':     return 'var(--error-color, #ff3b30)'
    case 'cancelled':  return 'var(--warning-color, #ff9f0a)'
    case 'downloading':
    case 'converting':
    case 'importing':  return 'var(--info-color, #0a84ff)'
    default:           return 'inherit'
  }
}

function canSwitch(t: TrackDownloadStatus) {
  return (t.status === 'downloading' && t.source === 'Soulseek') || t.status === 'pending'
}
</script>

<template>
  <div>
    <div style="font-size: 15px; font-weight: 600; margin-bottom: 10px">
      {{ job.artist }} — {{ job.album }}
    </div>
    <n-progress
      type="line"
      :percentage="percentage"
      :status="progressStatus"
      :show-indicator="false"
    />
    <div style="font-size: 12px; opacity: 0.5; margin: 4px 0 16px">
      <span v-if="job.status === 'done'">Concluído</span>
      <span v-else-if="job.status === 'failed'">Erro: {{ job.error }}</span>
      <span v-else>
        {{ done }}/{{ total }} faixas
        <span v-if="job.status_message" style="display: block; margin-top: 2px; font-size: 11px; opacity: 0.7">
          {{ job.status_message }}
        </span>
      </span>
    </div>

    <div v-for="t in job.tracks" :key="t.position"
         style="display: flex; align-items: center; gap: 8px; padding: 8px 0; border-bottom: 1px solid rgba(128,128,128,0.08)">
      <span style="flex: 1; font-size: 13px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap">
        {{ t.title }}
      </span>
      <span :style="{ fontSize: '11px', color: statusColor(t), flexShrink: 0 }">
        {{ statusText(t) }}
      </span>
      <n-button
        v-if="canSwitch(t)"
        size="tiny"
        quaternary
        type="warning"
        @click.stop="emit('use-ytdlp', t.position)"
      >YT</n-button>
    </div>
  </div>
</template>
