import { getInitData } from '@/telegram'

const BASE = import.meta.env.VITE_API_BASE ?? '/api'

export interface FreshRelease {
  release_mbid: string
  release_name: string
  artist_credit_name: string
  release_date: string
  release_group_primary_type: string
  release_group_secondary_type: string | null
  confidence: number
  in_library: boolean
}

export interface TrackStatus {
  position: number
  disc: number
  title: string
  in_library: boolean
  path: string | null
}

export interface ReleaseTracksResponse {
  release_id: string
  artist: string
  album: string
  release_date: string
  tracks: TrackStatus[]
  have: number
  missing: number
}

export interface TrackDownloadStatus {
  position: number
  title: string
  status: 'pending' | 'in_library' | 'downloading' | 'converting' | 'importing' | 'done' | 'failed' | 'cancelled'
  needs_review: boolean
  source: string | null
  percent: number | null
  transfer_id: string | null
  slskd_username: string | null
}

export interface JobStatus {
  job_id: string
  status: 'pending' | 'running' | 'done' | 'failed'
  release_id: string
  artist: string
  album: string
  total_tracks: number
  tracks: TrackDownloadStatus[]
  error: string | null
  status_message: string | null
}

export interface ReviewFile {
  filename: string
  artist: string | null
  title: string | null
  album: string | null
  duration: number | null
  size_bytes: number
  review_reason: string | null
  expected_mbid: string | null
  expected_tracknum: string | null
  expected_album: string | null
  expected_artist: string | null
}

export interface SearchResult {
  artist: string
  title: string
  album: string
  path: string
  track: number | null
  year: number | null
}

export interface DownloadStarted {
  job_id: string
  artist: string
  album: string
  total_tracks: number
}

export interface ReleaseResult {
  release_mbid: string
  release_name: string
  artist_credit_name: string
  release_date: string
  primary_type: string
  secondary_type: string | null
  in_library: boolean
}

function headers(): HeadersInit {
  return {
    'X-Telegram-Init-Data': getInitData(),
    'Content-Type': 'application/json',
  }
}

async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, { ...options, headers: headers() })
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail ?? `HTTP ${res.status}`)
  }
  return res.json()
}

export function fetchFreshReleases(onlyAlbums: boolean): Promise<FreshRelease[]> {
  return apiFetch(`/fresh-releases?only_albums=${onlyAlbums}`)
}

export function fetchReleaseTracks(mbid: string): Promise<ReleaseTracksResponse> {
  return apiFetch(`/release/${mbid}/tracks`)
}

export function startDownload(mbid: string, positions?: number[]): Promise<DownloadStarted> {
  return apiFetch(`/release/${mbid}/download`, {
    method: 'POST',
    body: positions ? JSON.stringify({ positions }) : JSON.stringify({}),
  })
}

export function fetchJobStatus(jobId: string): Promise<JobStatus> {
  return apiFetch(`/jobs/${jobId}`)
}

export function useYtDlp(jobId: string, position: number): Promise<void> {
  return apiFetch(`/jobs/${jobId}/tracks/${position}/use-ytdlp`, { method: 'POST' })
}

export function cancelJob(jobId: string): Promise<void> {
  return apiFetch(`/jobs/${jobId}`, { method: 'DELETE' })
}

export function fetchReview(): Promise<ReviewFile[]> {
  return apiFetch('/review')
}

export function acceptReview(filename: string): Promise<void> {
  return apiFetch(`/review/${encodeURIComponent(filename)}/accept`, { method: 'POST' })
}

export function deleteReview(filename: string): Promise<void> {
  return apiFetch(`/review/${encodeURIComponent(filename)}/delete`, { method: 'POST' })
}

export function searchLibrary(q: string): Promise<SearchResult[]> {
  return apiFetch(`/library/search?q=${encodeURIComponent(q)}`)
}

export function searchReleases(q: string, type?: string): Promise<ReleaseResult[]> {
  const params = new URLSearchParams({ q })
  if (type) params.set('type', type)
  return apiFetch(`/search/releases?${params}`)
}

export function searchByArtist(q: string): Promise<ReleaseResult[]> {
  return apiFetch(`/search/artists?q=${encodeURIComponent(q)}`)
}
