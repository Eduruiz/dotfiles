import { defineStore } from 'pinia'
import { ref } from 'vue'
import { searchReleases, searchByArtist, type ReleaseResult } from '@/api'

export const useSearchStore = defineStore('search', () => {
  const query = ref('')
  const activeFilter = ref<string>('all')
  const results = ref<ReleaseResult[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  let debounceTimer: ReturnType<typeof setTimeout>
  let currentAbortController: AbortController | null = null

  async function doSearch() {
    if (query.value.length < 2) {
      results.value = []
      return
    }

    // Cancel previous request
    if (currentAbortController) {
      currentAbortController.abort()
    }
    currentAbortController = new AbortController()

    loading.value = true
    error.value = null

    try {
      if (activeFilter.value === 'artist') {
        results.value = await searchByArtist(query.value)
      } else {
        const type = activeFilter.value === 'all' ? undefined : activeFilter.value
        results.value = await searchReleases(query.value, type)
      }
    } catch (e: any) {
      // Don't show error if request was cancelled
      if (e.name !== 'AbortError') {
        error.value = e.message
      }
    } finally {
      loading.value = false
      currentAbortController = null
    }
  }

  function updateQuery(newQuery: string) {
    query.value = newQuery
    clearTimeout(debounceTimer)
    results.value = []
    
    if (query.value.length < 2) {
      loading.value = false
      return
    }

    // Wait for user to stop typing (800ms)
    debounceTimer = setTimeout(doSearch, 800)
  }

  function updateFilter(newFilter: string) {
    activeFilter.value = newFilter
    if (query.value.length >= 2) {
      doSearch()
    }
  }

  function clearSearch() {
    query.value = ''
    results.value = []
    error.value = null
    loading.value = false
    clearTimeout(debounceTimer)
    if (currentAbortController) {
      currentAbortController.abort()
      currentAbortController = null
    }
  }

  return {
    query,
    activeFilter,
    results,
    loading,
    error,
    updateQuery,
    updateFilter,
    clearSearch,
    doSearch,
  }
})
