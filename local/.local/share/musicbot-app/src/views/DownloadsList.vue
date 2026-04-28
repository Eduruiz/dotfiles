<script setup lang="ts">
import { computed } from 'vue'
import { NEmpty, NButton } from 'naive-ui'
import { useJobsStore } from '@/stores/jobs'
import { useRouter } from 'vue-router'
import type { JobStatus } from '@/api'

const store = useJobsStore()
const router = useRouter()

const all = computed(() => [...store.jobs.values()].reverse())
const active = computed(() => all.value.filter(j => j.status === 'pending' || j.status === 'running'))
const finished = computed(() => all.value.filter(j => j.status === 'done' || j.status === 'failed'))

function doneTracks(j: JobStatus) {
  return j.tracks.filter(t => t.status === 'done').length
}
function totalTracks(j: JobStatus) {
  return (j.tracks.length || j.total_tracks) - j.tracks.filter(t => t.status === 'in_library').length
}
function statusColor(j: JobStatus) {
  if (j.status === 'done') return '#34c759'
  if (j.status === 'failed') return '#ff3b30'
  return '#0a84ff'
}
function statusLabel(j: JobStatus) {
  if (j.status === 'done') return `${doneTracks(j)}/${totalTracks(j)} faixas`
  if (j.status === 'failed') return 'erro'
  return `${doneTracks(j)}/${totalTracks(j)} · baixando`
}
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 14px 16px 6px">
      <div style="font-size: 12px; font-weight: 600; opacity: 0.45; text-transform: uppercase; letter-spacing: 0.5px">
        Downloads
      </div>
      <n-button v-if="all.length" size="tiny" quaternary type="error" @click="store.clearAll()">
        Limpar tudo
      </n-button>
    </div>

    <template v-if="active.length">
      <div style="padding: 14px 16px 6px; font-size: 11px; font-weight: 600; opacity: 0.3">
        EM ANDAMENTO
      </div>
      <div v-for="j in active" :key="j.job_id"
           @click="router.push(`/jobs/${j.job_id}`)"
           style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-bottom: 1px solid rgba(128,128,128,0.1); cursor: pointer">
        <div style="flex: 1; min-width: 0">
          <div style="font-size: 13px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ j.artist }}</div>
          <div style="font-size: 12px; opacity: 0.6; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ j.album }}</div>
        </div>
        <div :style="{ fontSize: '12px', color: statusColor(j), flexShrink: 0 }">{{ statusLabel(j) }}</div>
      </div>
    </template>

    <template v-if="finished.length">
      <div style="padding: 14px 16px 6px; font-size: 12px; font-weight: 600; opacity: 0.45; text-transform: uppercase; letter-spacing: 0.5px">
        Concluídos
      </div>
      <div v-for="j in finished" :key="j.job_id"
           @click="router.push(`/jobs/${j.job_id}`)"
           style="display: flex; align-items: center; gap: 12px; padding: 12px 16px; border-bottom: 1px solid rgba(128,128,128,0.1); cursor: pointer">
        <div style="flex: 1; min-width: 0">
          <div style="font-size: 13px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ j.artist }}</div>
          <div style="font-size: 12px; opacity: 0.6; white-space: nowrap; overflow: hidden; text-overflow: ellipsis">{{ j.album }}</div>
        </div>
        <div :style="{ fontSize: '12px', color: statusColor(j), flexShrink: 0 }">{{ statusLabel(j) }}</div>
      </div>
    </template>

    <n-empty v-if="!active.length && !finished.length"
             description="Nenhum download ainda" style="margin-top: 80px" />
  </div>
</template>
