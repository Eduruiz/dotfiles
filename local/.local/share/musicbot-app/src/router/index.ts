import { createRouter, createWebHashHistory } from 'vue-router'
import { useBackButton } from '@/telegram'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    { path: '/', component: () => import('@/views/FreshReleases.vue') },
    { path: '/review', component: () => import('@/views/ReviewList.vue') },
    { path: '/search', component: () => import('@/views/ReleaseSearch.vue') },
    { path: '/library', component: () => import('@/views/LibrarySearch.vue') },
    { path: '/downloads', component: () => import('@/views/DownloadsList.vue') },
    { path: '/release/:mbid', component: () => import('@/views/ReleaseDetail.vue') },
    { path: '/jobs/:jobId', component: () => import('@/views/DownloadProgress.vue') },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

const ROOT_PATHS = ['/', '/review', '/search', '/library', '/downloads']
const bb = useBackButton()

router.afterEach((to) => {
  if (ROOT_PATHS.includes(to.path)) {
    bb.hide()
  } else {
    bb.show()
  }
})

export default router
