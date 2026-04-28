<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NSpin, NEmpty } from 'naive-ui'
import { fetchReleaseTracks, startDownload, type ReleaseTracksResponse } from '@/api'
import { useFreshStore } from '@/stores/fresh'
import { useJobsStore } from '@/stores/jobs'
import { useMainButton } from '@/telegram'
import TrackList from '@/components/TrackList.vue'

const route = useRoute()
const router = useRouter()
const freshStore = useFreshStore()
const jobsStore = useJobsStore()
const mb = useMainButton()

const mbid = route.params.mbid as string
const data = ref<ReleaseTracksResponse | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)
const downloading = ref(false)

const freshRelease = freshStore.releaseByMbid(mbid)
const coverUrl = `https://coverartarchive.org/release/${mbid}/front-500`
const imgError = ref(false)

const missingCount = computed(() => data.value?.missing ?? 0)

async function load() {
  try {
    data.value = await fetchReleaseTracks(mbid)
  } catch (e) {
    error.value = (e as Error).message
  } finally {
    loading.value = false
  }
}

async function download() {
  if (downloading.value || !missingCount.value) return
  downloading.value = true
  mb.showProgress()
  try {
    const job = await startDownload(mbid)
    jobsStore.addJob({ ...job, release_id: mbid, status: 'pending', tracks: [], error: null, status_message: null })
    router.push(`/jobs/${job.job_id}`)
  } catch (e) {
    error.value = (e as Error).message
    mb.hideProgress()
    downloading.value = false
  }
}

onMounted(async () => {
  await load()
  if (missingCount.value > 0) {
    mb.setText(`Baixar ${missingCount.value} faixa${missingCount.value > 1 ? 's' : ''}`)
    mb.show()
    mb.onClick(download)
  }
})

onUnmounted(() => {
  mb.hide()
  mb.offClick(download)
})
</script>

<template>
  <div class="view">
    <div class="header">
      <div class="cover">
        <img v-if="!imgError" :src="coverUrl" @error="imgError = true" />
        <div v-else class="cover-placeholder">
          {{ (freshRelease?.artist_credit_name ?? data?.artist ?? '?')[0] }}
        </div>
      </div>
      <div class="header-info">
        <div class="artist">{{ data?.artist ?? freshRelease?.artist_credit_name }}</div>
        <div class="album">{{ data?.album ?? freshRelease?.release_name }}</div>
        <div class="stats" v-if="data">
          <span class="in-lib">✅ {{ data.have }} na biblioteca</span>
          <span v-if="data.missing"> · ⬇️ {{ data.missing }} a baixar</span>
        </div>
      </div>
    </div>

    <div v-if="loading" class="center"><n-spin /></div>
    <div v-else-if="error" class="center error">{{ error }}</div>
    <n-empty v-else-if="!data?.tracks.length" description="Sem faixas" style="margin-top: 40px" />
    <track-list v-else :tracks="data!.tracks" />
  </div>
</template>

<style scoped>
.view { min-height: 100%; }

.header {
  display: flex;
  gap: 16px;
  padding: 20px 16px;
  border-bottom: 1px solid rgba(128,128,128,0.15);
}

.cover {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
  background: rgba(128,128,128,0.15);
}
.cover img { width: 100%; height: 100%; object-fit: cover; }
.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: 700;
  opacity: 0.4;
}

.header-info { flex: 1; min-width: 0; display: flex; flex-direction: column; justify-content: center; gap: 4px; }
.artist { font-size: 13px; opacity: 0.6; }
.album { font-size: 16px; font-weight: 600; }
.stats { font-size: 12px; opacity: 0.6; margin-top: 4px; }

.center { display: flex; align-items: center; justify-content: center; padding: 60px; }
.error { color: #ff3b30; font-size: 14px; }
</style>
