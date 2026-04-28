import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { fetchFreshReleases, fetchReleaseTracks, type FreshRelease, type TrackStatus } from '@/api'

export interface ReleaseItem {
  release_mbid: string
  release_name: string
  artist_credit_name: string
  release_date: string
  type_label: string
  in_library: boolean
}

export interface ExpandedRelease {
  tracks: TrackStatus[]
  loading: boolean
  error: string | null
  selected: number[]
  release_date: string
}

export const useFreshStore = defineStore('fresh', () => {
  const releases = ref<FreshRelease[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const onlyAlbums = ref(false)
  const expanded = ref<Record<string, ExpandedRelease>>({})

  async function load(force = false) {
    if (releases.value.length && !force) return
    loading.value = true
    error.value = null
    try {
      releases.value = await fetchFreshReleases(onlyAlbums.value)
    } catch (e) {
      error.value = (e as Error).message
    } finally {
      loading.value = false
    }
  }

  async function toggleFilter() {
    onlyAlbums.value = !onlyAlbums.value
    expanded.value = {}
    await load(true)
  }

  function releaseByMbid(mbid: string): FreshRelease | undefined {
    return releases.value.find((r) => r.release_mbid === mbid)
  }

  function isExpanded(mbid: string): boolean {
    return mbid in expanded.value
  }

  async function toggleExpand(mbid: string) {
    if (mbid in expanded.value) {
      const { [mbid]: _, ...rest } = expanded.value
      expanded.value = rest
      return
    }

    expanded.value = { ...expanded.value, [mbid]: { tracks: [], loading: true, error: null, selected: [], release_date: '' } }

    try {
      const data = await fetchReleaseTracks(mbid)
      const selected = data.tracks.filter((t) => !t.in_library).map((t) => t.position)
      expanded.value = { ...expanded.value, [mbid]: { tracks: data.tracks, loading: false, error: null, selected, release_date: data.release_date } }
    } catch (e) {
      expanded.value = { ...expanded.value, [mbid]: { tracks: [], loading: false, error: (e as Error).message, selected: [], release_date: '' } }
    }
  }

  function toggleTrack(mbid: string, position: number) {
    const entry = expanded.value[mbid]
    if (!entry) return
    const selected = entry.selected.includes(position)
      ? entry.selected.filter((p) => p !== position)
      : [...entry.selected, position]
    expanded.value = { ...expanded.value, [mbid]: { ...entry, selected } }
  }

  const selectedByRelease = computed(() =>
    Object.entries(expanded.value)
      .filter(([, e]) => e.selected.length > 0)
      .map(([mbid, e]) => ({ mbid, positions: e.selected }))
  )

  const totalSelected = computed(() =>
    Object.values(expanded.value).reduce((sum, e) => sum + e.selected.length, 0)
  )

  return {
    releases, loading, error, onlyAlbums, expanded,
    load, toggleFilter, releaseByMbid,
    isExpanded, toggleExpand, toggleTrack,
    selectedByRelease, totalSelected,
  }
})
