import { defineStore } from 'pinia'
import { ref } from 'vue'
import { fetchJobStatus, type JobStatus } from '@/api'

const STORAGE_KEY = 'musicbot_jobs'
const MAX_STORED = 20 // CloudStorage tem limites, melhor manter enxuto

const tg = () => window.Telegram?.WebApp
const cloud = () => tg()?.CloudStorage

async function loadStored(): Promise<Map<string, JobStatus>> {
  return new Promise((resolve) => {
    try {
      // Tenta CloudStorage primeiro
      if (cloud()) {
        cloud()?.getItem(STORAGE_KEY, (err: Error | null, val: string) => {
          if (!err && val) {
            try {
              const arr: JobStatus[] = JSON.parse(val)
              return resolve(new Map(arr.map(j => [j.job_id, j])))
            } catch {}
          }
          // Fallback para localStorage se Cloud falhar ou estiver vazio
          resolve(_loadLocal())
        })
      } else {
        resolve(_loadLocal())
      }
    } catch {
      resolve(new Map())
    }
  })
}

function _loadLocal(): Map<string, JobStatus> {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return new Map()
    const arr: JobStatus[] = JSON.parse(raw)
    return new Map(arr.map(j => [j.job_id, j]))
  } catch {
    return new Map()
  }
}

function persist(jobs: Map<string, JobStatus>) {
  try {
    const arr = [...jobs.values()].slice(-MAX_STORED)
    const raw = JSON.stringify(arr)
    
    // Salva em ambos para redundância
    localStorage.setItem(STORAGE_KEY, raw)
    if (cloud()) {
      cloud()?.setItem(STORAGE_KEY, raw, (err: Error | null) => {
        if (err) console.error('CloudStorage save error', err)
      })
    }
  } catch {}
}

export const useJobsStore = defineStore('jobs', () => {
  const jobs = ref<Map<string, JobStatus>>(new Map())
  const pollingIds = ref<Map<string, number>>(new Map())
  const lastJobId = ref<string | null>(null)
  const isLoaded = ref(false)
  let visibilitySetup = false
  const pausedJobs = new Set<string>()

  // Inicialização assíncrona
  async function init() {
    if (isLoaded.value) return
    jobs.value = await loadStored()
    isLoaded.value = true
    
    // Validação proativa: verifica se os jobs ainda existem no servidor
    for (const jobId of Array.from(jobs.value.keys())) {
      try {
        const status = await fetchJobStatus(jobId)
        jobs.value.set(jobId, status)
      } catch (e: any) {
        if (e.message?.includes('404')) {
          jobs.value.delete(jobId)
        }
      }
    }
    persist(jobs.value)
    resumeActiveJobs()
  }

  function clearAll() {
    jobs.value.clear()
    persist(jobs.value)
    for (const id of pollingIds.value.values()) {
      clearInterval(id)
    }
    pollingIds.value.clear()
  }

  function getJob(jobId: string): JobStatus | undefined {
    return jobs.value.get(jobId)
  }

  function addJob(job: JobStatus) {
    jobs.value.set(job.job_id, job)
    lastJobId.value = job.job_id
    persist(jobs.value)
    startPolling(job.job_id)
  }

  function startPolling(jobId: string) {
    if (pollingIds.value.has(jobId)) return
    _setupVisibility()

    const id = window.setInterval(async () => {
      try {
        const status = await fetchJobStatus(jobId)
        jobs.value.set(jobId, status)
        persist(jobs.value)
        if (status.status === 'done' || status.status === 'failed') {
          stopPolling(jobId)
        }
      } catch (e: any) {
        // Se der 404, o job sumiu do servidor (ex: restart)
        if (e.message?.includes('404')) {
          jobs.value.delete(jobId)
          persist(jobs.value)
          stopPolling(jobId)
        }
      }
    }, 2000)

    pollingIds.value.set(jobId, id)
  }

  function stopPolling(jobId: string) {
    const id = pollingIds.value.get(jobId)
    if (id !== undefined) {
      clearInterval(id)
      pollingIds.value.delete(jobId)
    }
  }

  function resumeActiveJobs() {
    for (const job of jobs.value.values()) {
      if (job.status !== 'done' && job.status !== 'failed') {
        startPolling(job.job_id)
      }
    }
  }

  function _setupVisibility() {
    if (visibilitySetup) return
    visibilitySetup = true

    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        for (const jobId of pollingIds.value.keys()) {
          pausedJobs.add(jobId)
          stopPolling(jobId)
        }
      } else {
        for (const jobId of pausedJobs) {
          const job = jobs.value.get(jobId)
          if (job && job.status !== 'done' && job.status !== 'failed') {
            startPolling(jobId)
          }
        }
        pausedJobs.clear()
      }
    })
  }

  return { jobs, lastJobId, isLoaded, init, getJob, addJob, startPolling, stopPolling, resumeActiveJobs, clearAll }
})
