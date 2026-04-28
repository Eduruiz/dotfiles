<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import { NSpin, NEmpty, NInput, NButton, NRadioGroup, NRadioButton } from 'naive-ui'
import { startDownload, type ReleaseResult } from '@/api'
import { useFreshStore, type ReleaseItem } from '@/stores/fresh'
import { useJobsStore } from '@/stores/jobs'
import { useSearchStore } from '@/stores/search'
import { useRouter } from 'vue-router'
import ReleaseCard from '@/components/ReleaseCard.vue'

const freshStore = useFreshStore()
const jobsStore = useJobsStore()
const searchStore = useSearchStore()
const router = useRouter()

const downloading = ref(false)

const filters = [
  { label: 'Tudo', value: 'all' },
  { label: 'Álbum', value: 'Album' },
  { label: 'Single', value: 'Single' },
  { label: 'EP', value: 'EP' },
  { label: 'Artista', value: 'artist' },
]

function toReleaseItem(r: ReleaseResult): ReleaseItem {
  return {
    release_mbid: r.release_mbid,
    release_name: r.release_name,
    artist_credit_name: r.artist_credit_name,
    release_date: r.release_date,
    type_label: r.secondary_type ?? r.primary_type,
    in_library: r.in_library,
  }
}

// Clear expanded state when search changes
watch(() => searchStore.query, () => {
  freshStore.expanded = {}
})

watch(() => searchStore.activeFilter, () => {
  freshStore.expanded = {}
})

const buttonLabel = computed(() => {
  const n = freshStore.totalSelected
  return n > 0 ? `Baixar ${n} faixa${n > 1 ? 's' : ''}` : ''
})

async function downloadSelected() {
  if (downloading.value || freshStore.totalSelected === 0) return
  downloading.value = true
  try {
    for (const { mbid, positions } of freshStore.selectedByRelease) {
      const r = searchStore.results.find((rel) => rel.release_mbid === mbid)
      const job = await startDownload(mbid, positions)
      jobsStore.addJob({
        ...job,
        release_id: mbid,
        status: 'pending',
        tracks: [],
        error: null,
        status_message: null,
        artist: r?.artist_credit_name ?? job.artist,
        album: r?.release_name ?? job.album,
      })
    }
    router.push(`/jobs/${jobsStore.lastJobId}`)
  } catch (e) {
    searchStore.error = (e as Error).message
    downloading.value = false
  }
}

onUnmounted(() => { freshStore.expanded = {} })
</script>

<template>
  <div class="view">
    <div class="search-bar">
      <n-input
        :value="searchStore.query"
        @update:value="searchStore.updateQuery"
        placeholder="Artista, álbum..."
        clearable
        :input-props="{ autocomplete: 'off', autocorrect: 'off', spellcheck: 'false' }"
      />
      <n-radio-group :value="searchStore.activeFilter" @update:value="searchStore.updateFilter" class="filters" size="small">
        <n-radio-button v-for="f in filters" :key="f.value" :value="f.value">
          {{ f.label }}
        </n-radio-button>
      </n-radio-group>
    </div>

    <div v-if="searchStore.loading" class="center"><n-spin /></div>
    <div v-else-if="searchStore.error" class="center error">{{ searchStore.error }}</div>
    <n-empty v-else-if="searchStore.query.length >= 2 && !searchStore.results.length && !searchStore.loading" description="Sem resultados" style="margin-top: 60px" />
    <n-empty v-else-if="!searchStore.query.length" description="Digite para buscar" style="margin-top: 60px" />

    <div v-else class="list">
      <release-card
        v-for="r in searchStore.results"
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

.search-bar { padding: 12px 16px 8px; flex-shrink: 0; display: flex; flex-direction: column; gap: 8px; }

.filters { overflow-x: auto; scrollbar-width: none; }
.filters::-webkit-scrollbar { display: none; }

.list { flex: 1; overflow-y: auto; }

.center { flex: 1; display: flex; align-items: center; justify-content: center; padding: 60px; }
.error { color: #ff3b30; font-size: 14px; }

.download-bar {
  flex-shrink: 0;
  padding: 12px 16px;
  padding-bottom: max(12px, env(safe-area-inset-bottom));
  border-top: 1px solid rgba(128,128,128,0.15);
}
</style>
