<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { NSpin, NEmpty, NButton, useMessage, useDialog } from 'naive-ui'
import { fetchReview, acceptReview, deleteReview, type ReviewFile } from '@/api'

const files = ref<ReviewFile[]>([])
const loading = ref(true)
const processing = ref<Record<string, boolean>>({})
const error = ref<string | null>(null)
const message = useMessage()
const dialog = useDialog()

function formatSize(bytes: number) {
  return (bytes / 1024 / 1024).toFixed(1) + ' MB'
}

async function getAudioUrl(f: ReviewFile) {
  try {
    const res = await fetch('/api/review/stream-token', {
      headers: {
        'X-Telegram-Init-Data': window.Telegram?.WebApp.initData ?? '',
      }
    })
    const data = await res.json()
    return `/api/review/${encodeURIComponent(f.filename)}/stream?token=${data.token}`
  } catch {
    return ''
  }
}

// Inicializar URLs de áudio
const audioUrls = ref<Record<string, string>>({})

async function load() {
  loading.value = true
  try {
    files.value = await fetchReview()
    for (const f of files.value) {
      audioUrls.value[f.filename] = await getAudioUrl(f)
    }
  } catch (e) {
    error.value = (e as Error).message
  } finally {
    loading.value = false
  }
}

async function handleAccept(f: ReviewFile) {
  processing.value[f.filename] = true
  try {
    await acceptReview(f.filename)
    message.success('Faixa importada com sucesso!')
    await load()
  } catch (e: any) {
    message.error('Falha na importação: ' + e.message)
  } finally {
    processing.value[f.filename] = false
  }
}

async function handleAcceptAll() {
  dialog.warning({
    title: 'Aceitar tudo',
    content: 'Aceitar todos os arquivos deste review?',
    positiveText: 'Aceitar',
    negativeText: 'Cancelar',
    onPositiveClick: async () => {
      for (const f of files.value) {
        await handleAccept(f)
      }
    }
  })
}

async function handleDelete(f: ReviewFile) {
  dialog.error({
    title: 'Deletar arquivo',
    content: 'Deletar este arquivo permanentemente?',
    positiveText: 'Deletar',
    negativeText: 'Cancelar',
    onPositiveClick: async () => {
      processing.value[f.filename] = true
      try {
        await deleteReview(f.filename)
        message.info('Arquivo removido')
        await load()
      } catch (e: any) {
        message.error('Falha ao deletar: ' + e.message)
      } finally {
        processing.value[f.filename] = false
      }
    }
  })
}

onMounted(load)
</script>

<template>
  <div class="view">
    <div class="header">
      <div class="section-title">Review de Faixas ({{ files.length }})</div>
      <div v-if="files.length" class="header-actions">
        <n-button size="tiny" quaternary type="primary" @click="handleAcceptAll">Aceitar Tudo</n-button>
        <n-button size="tiny" quaternary @click="load" :disabled="loading">Atualizar</n-button>
      </div>
    </div>

    <div v-if="loading" class="center"><n-spin /></div>
    <div v-else-if="error" class="center error">{{ error }}</div>
    <n-empty v-else-if="!files.length" description="Tudo limpo! Nenhuma faixa em review" style="margin-top: 80px" />

    <div v-else class="list">
      <div v-for="f in files" :key="f.filename" class="file-card">
        <div class="card-header">
          <div class="reason" v-if="f.review_reason">⚠️ {{ f.review_reason }}</div>
          <div class="filename">{{ f.filename }} ({{ formatSize(f.size_bytes) }})</div>
        </div>

        <div class="metadata-grid">
          <audio 
            controls 
            :src="audioUrls[f.filename]" 
            style="width: 100%; height: 35px; margin-bottom: 8px;"
          ></audio>
          
          <div class="meta-item">
            <span class="label">Encontrado:</span>
            <span class="val">{{ f.artist ?? '?' }} — {{ f.title ?? '?' }}</span>
            <div class="sub-val">{{ f.album ?? 'Álbum desconhecido' }}</div>
          </div>
          <div class="meta-item highlight" v-if="f.expected_album">
            <span class="label">Esperado:</span>
            <span class="val">{{ f.expected_artist }} — {{ f.title ?? '?' }}</span>
            <div class="sub-val">Álbum: {{ f.expected_album }} (Track {{ f.expected_tracknum }})</div>
          </div>
        </div>

        <div class="actions">
          <n-button 
            type="primary" 
            size="small" 
            secondary 
            @click="handleAccept(f)" 
            :loading="processing[f.filename]"
          >
            Aceitar
          </n-button>
          <n-button 
            type="error" 
            size="small" 
            quaternary 
            @click="handleDelete(f)"
            :disabled="processing[f.filename]"
          >
            Deletar
          </n-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.view { min-height: 100%; padding-bottom: 20px; }
.header { display: flex; align-items: center; justify-content: space-between; padding-right: 16px; }
.section-title { padding: 14px 16px 8px; font-size: 12px; font-weight: 600; opacity: 0.5; text-transform: uppercase; letter-spacing: 0.5px; }
.center { display: flex; align-items: center; justify-content: center; padding: 60px; }
.error { color: #ff3b30; font-size: 14px; }

.list { padding: 8px 12px; display: flex; flex-direction: column; gap: 12px; }
.file-card { 
  background: rgba(128,128,128,0.08); 
  border-radius: 12px; 
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.reason { 
  color: #ff9f0a; 
  font-size: 11px; 
  font-weight: 700; 
  margin-bottom: 4px;
  text-transform: uppercase;
}

.filename { font-size: 12px; opacity: 0.4; word-break: break-all; font-family: monospace; }

.metadata-grid { display: flex; flex-direction: column; gap: 8px; }
.meta-item { font-size: 13px; }
.meta-item .label { display: block; font-size: 10px; opacity: 0.5; text-transform: uppercase; margin-bottom: 2px; }
.meta-item .val { font-weight: 600; }
.meta-item .sub-val { font-size: 12px; opacity: 0.6; }

.highlight { border-top: 1px solid rgba(128,128,128,0.1); pt: 8px; color: var(--info-color, #0a84ff); }

.actions { display: flex; gap: 8px; margin-top: 4px; }
</style>

<style scoped>
.view { min-height: 100%; }
.section-title { padding: 14px 16px 8px; font-size: 13px; font-weight: 600; opacity: 0.5; text-transform: uppercase; letter-spacing: 0.5px; }
.center { display: flex; align-items: center; justify-content: center; padding: 60px; }
.error { color: #ff3b30; font-size: 14px; }
.list { padding: 0 16px; }
.file { padding: 12px 0; border-bottom: 1px solid rgba(128,128,128,0.1); }
.file:last-child { border-bottom: none; }
.file-name { font-size: 14px; font-weight: 500; }
.file-meta { font-size: 12px; opacity: 0.5; margin-top: 3px; }
</style>
