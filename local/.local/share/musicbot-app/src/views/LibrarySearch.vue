<script setup lang="ts">
import { ref, watch } from 'vue'
import { NInput, NSpin, NEmpty } from 'naive-ui'
import { searchLibrary, type SearchResult } from '@/api'

const query = ref('')
const results = ref<SearchResult[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
let debounceTimer: ReturnType<typeof setTimeout>

watch(query, (q) => {
  clearTimeout(debounceTimer)
  if (q.length < 2) { results.value = []; return }
  debounceTimer = setTimeout(async () => {
    loading.value = true
    error.value = null
    try {
      results.value = await searchLibrary(q)
    } catch (e) {
      error.value = (e as Error).message
    } finally {
      loading.value = false
    }
  }, 300)
})
</script>

<template>
  <div class="view">
    <div class="search-bar">
      <n-input
        v-model:value="query"
        placeholder="Buscar na biblioteca..."
        clearable
        :input-props="{ autocomplete: 'off' }"
      />
    </div>

    <div v-if="loading" class="center"><n-spin /></div>
    <div v-else-if="error" class="center error">{{ error }}</div>
    <n-empty v-else-if="query.length >= 2 && !results.length" description="Sem resultados" style="margin-top: 60px" />
    <n-empty v-else-if="!query.length" description="Digite para buscar" style="margin-top: 60px" />

    <div v-else class="list">
      <div v-for="r in results" :key="r.path" class="result">
        <div class="result-title">{{ r.artist }} — {{ r.title }}</div>
        <div class="result-meta">
          {{ r.album }}
          <span v-if="r.track"> · Faixa {{ r.track }}</span>
          <span v-if="r.year"> · {{ r.year }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.view { height: 100%; display: flex; flex-direction: column; }
.search-bar { padding: 12px 16px; flex-shrink: 0; }
.center { flex: 1; display: flex; align-items: center; justify-content: center; padding: 60px; }
.error { color: #ff3b30; font-size: 14px; }
.list { flex: 1; overflow-y: auto; padding: 0 16px; }
.result { padding: 12px 0; border-bottom: 1px solid rgba(128,128,128,0.1); }
.result:last-child { border-bottom: none; }
.result-title { font-size: 14px; font-weight: 500; }
.result-meta { font-size: 12px; opacity: 0.5; margin-top: 3px; }
</style>
