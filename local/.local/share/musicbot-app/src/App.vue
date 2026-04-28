<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NConfigProvider, NMessageProvider, NDialogProvider, darkTheme } from 'naive-ui'
import { useTelegramTheme } from './telegram'
import { useJobsStore } from './stores/jobs'

const { themeOverrides, isDark } = useTelegramTheme()
const route = useRoute()
const router = useRouter()
const jobsStore = useJobsStore()

onMounted(() => {
  jobsStore.init()
})

const ROOT_PATHS = ['/', '/review', '/search', '/library', '/downloads']
const showNav = computed(() => {
  // Show nav on root paths OR on job detail pages
  return ROOT_PATHS.includes(route.path) || route.path.startsWith('/jobs/')
})

const tabs = [
  { icon: '🆕', label: 'Fresh', path: '/' },
  { icon: '🔍', label: 'Buscar', path: '/search' },
  { icon: '📚', label: 'Biblioteca', path: '/library' },
  { icon: '⬇️', label: 'Downloads', path: '/downloads' },
  { icon: '📋', label: 'Review', path: '/review' },
]
</script>

<template>
  <n-config-provider
    :theme="isDark ? darkTheme : null"
    :theme-overrides="themeOverrides"
  >
    <n-message-provider>
      <n-dialog-provider>
        <div class="app">
          <main class="content">
            <router-view />
        </main>
        <nav v-if="showNav" class="bottom-nav">
          <button
            v-for="tab in tabs"
            :key="tab.path"
            class="nav-item"
            :class="{ active: route.path === tab.path }"
            @click="router.push(tab.path)"
          >
            <span class="nav-icon">{{ tab.icon }}</span>
            <span class="nav-label">{{ tab.label }}</span>
          </button>
        </nav>
      </div>
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<style>
* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  -webkit-font-smoothing: antialiased;
  background-color: var(--tg-theme-bg-color, #fff);
  color: var(--tg-theme-text-color, #000);
}

.app {
  display: flex;
  flex-direction: column;
  height: 100dvh;
  overflow: hidden;
}

.content {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  min-height: 0;
}

.bottom-nav {
  display: flex;
  flex-shrink: 0;
  border-top: 1px solid rgba(128,128,128,0.15);
  background: var(--tg-theme-bg-color, #fff);
  padding-bottom: env(safe-area-inset-bottom);
}

.nav-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  padding: 8px 4px;
  background: none;
  border: none;
  cursor: pointer;
  color: inherit;
  opacity: 0.45;
  transition: opacity 0.15s;
  min-width: 0;
}

.nav-item.active { opacity: 1; }

.nav-icon { font-size: 20px; line-height: 1; }
.nav-label { font-size: 10px; font-weight: 500; white-space: nowrap; }
</style>
