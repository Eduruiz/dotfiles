<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { NSpin, NEmpty, NButton } from 'naive-ui'
import { startDownload, type FreshRelease } from '@/api'
import { useFreshStore, type ReleaseItem } from '@/stores/fresh'
import { useJobsStore } from '@/stores/jobs'
import { useMainButton } from '@/telegram'
import ReleaseCard from '@/components/ReleaseCard.vue'

function toReleaseItem(r: FreshRelease): ReleaseItem {
  return {
    release_mbid: r.release_mbid,
    release_name: r.release_name,
    artist_credit_name: r.artist_credit_name,
    release_date: r.release_date,
    type_label: r.release_group_secondary_type ?? r.release_group_primary_type,
    in_library: r.in_library,
  }
}

const store = useFreshStore()
const jobsStore = useJobsStore()
const router = useRouter()
const mb = useMainButton()
const downloading = ref(false)

const buttonLabel = computed(() => {
  const n = store.totalSelected
  return n > 0 ? `Baixar ${n} faixa${n > 1 ? 's' : ''}` : ''
})

async function downloadSelected() {
  if (downloading.value || store.totalSelected === 0) return
  downloading.value = true
  mb.showProgress()

  try {
    for (const { mbid, positions } of store.selectedByRelease) {
      const job = await startDownload(mbid, positions)
      const release = store.releaseByMbid(mbid)
      jobsStore.addJob({
        ...job,
        release_id: mbid,
        status: 'pending',
        tracks: [],
        error: null,
        status_message: null,
        artist: release?.artist_credit_name ?? job.artist,
        album: release?.release_name ?? job.album,
      })
    }
    router.push(`/jobs/${jobsStore.lastJobId}`)
  } catch (e) {
    mb.hideProgress()
    downloading.value = false
  }
}

onMounted(async () => {
  await store.load()
  mb.onClick(downloadSelected)
})

onUnmounted(() => {
  mb.hide()
  mb.offClick(downloadSelected)
})
</script>

<template>
  <div class="view">
    <div class="toolbar">
      <span class="toolbar-label">Só álbuns/EPs</span>
      <label class="switch">
        <input type="checkbox" :checked="store.onlyAlbums" @change="store.toggleFilter" />
        <span class="slider" />
      </label>
    </div>

    <div v-if="store.loading" class="center">
      <n-spin />
    </div>

    <div v-else-if="store.error" class="center error">
      {{ store.error }}
    </div>

    <n-empty v-else-if="!store.releases.length" description="Nenhum lançamento" style="margin-top: 60px" />

    <div v-else class="list">
      <release-card
        v-for="r in store.releases"
        :key="r.release_mbid"
        :release="toReleaseItem(r)"
      />
    </div>

    <div v-if="buttonLabel" class="download-bar">
      <n-button type="primary" block size="large" :loading="downloading" @click="downloadSelected">
        {{ buttonLabel }}
      </n-button>
    </div>
  </div>
</template>

<style scoped>
.view { height: 100%; display: flex; flex-direction: column; }

.toolbar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
  padding: 10px 16px;
  border-bottom: 1px solid rgba(128,128,128,0.15);
  font-size: 13px;
  flex-shrink: 0;
}

.list { flex: 1; overflow-y: auto; }

.center {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 16px;
}

.error { color: #ff3b30; font-size: 14px; text-align: center; }

.download-bar {
  flex-shrink: 0;
  padding: 12px 16px;
  padding-bottom: max(12px, env(safe-area-inset-bottom));
  border-top: 1px solid rgba(128,128,128,0.15);
}

.switch { position: relative; display: inline-block; width: 44px; height: 24px; }
.switch input { opacity: 0; width: 0; height: 0; }
.slider {
  position: absolute; inset: 0;
  background: rgba(128,128,128,0.3);
  border-radius: 24px;
  transition: background 0.2s;
  cursor: pointer;
}
.slider::before {
  content: '';
  position: absolute;
  width: 18px; height: 18px;
  left: 3px; top: 3px;
  background: white;
  border-radius: 50%;
  transition: transform 0.2s;
}
input:checked + .slider { background: var(--tg-theme-button-color, #5288c1); }
input:checked + .slider::before { transform: translateX(20px); }
</style>
