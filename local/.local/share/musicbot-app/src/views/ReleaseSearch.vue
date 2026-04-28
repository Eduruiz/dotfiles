<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import { NSpin, NEmpty, NInput, NButton, NRadioGroup, NRadioButton } from 'naive-ui'
import { searchReleases, searchByArtist, startDownload, type ReleaseResult } from '@/api'
import { useFreshStore, type ReleaseItem } from '@/stores/fresh'
import { useJobsStore } from '@/stores/jobs'
import { useRouter } from 'vue-router'
import ReleaseCard from '@/components/ReleaseCard.vue'

const store = useFreshStore()
const jobsStore = useJobsStore()
const router = useRouter()

const query = ref('')
const activeFilter = ref<string>('all')
const results = ref<ReleaseResult[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
const downloading = ref(false)
let debounceTimer: ReturnType<typeof setTimeout>

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

async function doSearch() {
  if (query.value.length < 2) { results.value = []; return }
  loading.value = true
  error.value = null
  try {
    if (activeFilter.value === 'artist') {
      results.value = await searchByArtist(query.value)
    } else {
      const type = activeFilter.value === 'all' ? undefined : activeFilter.value
      results.value = await searchReleases(query.value, type)
    }
  } catch (e) {
    error.value = (e as Error).message
  } finally {
    loading.value = false
  }
}

watch(query, () => {
  clearTimeout(debounceTimer)
  store.expanded = {}
  results.value = []
  if (query.value.length < 2) return
  debounceTimer = setTimeout(doSearch, 400)
})

watch(activeFilter, () => {
  store.expanded = {}
  if (query.value.length >= 2) doSearch()
})

const buttonLabel = computed(() => {
  const n = store.totalSelected
  return n > 0 ? `Baixar ${n} faixa${n > 1 ? 's' : ''}` : ''
})

async function downloadSelected() {
  if (downloading.value || store.totalSelected === 0) return
  downloading.value = true
  try {
    for (const { mbid, positions } of store.selectedByRelease) {
      const r = results.value.find((rel) => rel.release_mbid === mbid)
      const job = await startDownload(mbid, positions)
      jobsStore.addJob({
        ...job,
        release_id: mbid,
        status: 'pending',
        tracks: [],
        error: null,
        artist: r?.artist_credit_name ?? job.artist,
        album: r?.release_name ?? job.album,
      })
    }
    router.push(`/jobs/${jobsStore.lastJobId}`)
  } catch (e) {
    error.value = (e as Error).message
    downloading.value = false
  }
}

onUnmounted(() => { store.expanded = {} })
</script>

<template>
  <div class="view">
    <div class="search-bar">
      <n-input
        v-model:value="query"
        placeholder="Artista, álbum..."
        clearable
        :input-props="{ autocomplete: 'off', autocorrect: 'off', spellcheck: 'false' }"
      />
      <n-radio-group v-model:value="activeFilter" class="filters" size="small">
        <n-radio-button v-for="f in filters" :key="f.value" :value="f.value">
          {{ f.label }}
        </n-radio-button>
      </n-radio-group>
    </div>

    <div v-if="loading" class="center"><n-spin /></div>
    <div v-else-if="error" class="center error">{{ error }}</div>
    <n-empty v-else-if="query.length >= 2 && !results.length && !loading" description="Sem resultados" style="margin-top: 60px" />
    <n-empty v-else-if="!query.length" description="Digite para buscar" style="margin-top: 60px" />

    <div v-else class="list">
      <release-card
        v-for="r in results"
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
