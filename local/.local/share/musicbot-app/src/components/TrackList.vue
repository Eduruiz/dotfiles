<script setup lang="ts">
import type { TrackStatus } from '@/api'

defineProps<{ tracks: TrackStatus[] }>()
</script>

<template>
  <div class="tracklist">
    <div v-for="track in tracks" :key="track.position" class="track">
      <span class="num">{{ track.position }}</span>
      <span class="title">{{ track.title }}</span>
      <span class="status">{{ track.in_library ? '✅' : '⬇️' }}</span>
    </div>
  </div>
</template>

<style scoped>
.tracklist { padding: 0 16px; }
.track {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid rgba(128,128,128,0.1);
  font-size: 14px;
}
.track:last-child { border-bottom: none; }
.num { width: 24px; text-align: right; opacity: 0.4; font-size: 12px; flex-shrink: 0; }
.title { flex: 1; }
.status { flex-shrink: 0; font-size: 14px; }
</style>
