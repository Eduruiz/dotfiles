import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { expandApp, ready, useBackButton } from './telegram'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.mount('#app')

expandApp()
ready()

const bb = useBackButton()
bb.onClick(() => router.back())

import { useJobsStore } from './stores/jobs'
useJobsStore().resumeActiveJobs()
