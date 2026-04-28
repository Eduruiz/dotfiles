<script setup lang="ts">
import { ref, computed } from 'vue'
import { NSpin, NCheckbox } from 'naive-ui'
import { useFreshStore, type ExpandedRelease, type ReleaseItem } from '@/stores/fresh'

const props = defineProps<{ release: ReleaseItem }>()
const store = useFreshStore()

const imgError = ref(false)
const coverUrl = `https://coverartarchive.org/release/${props.release.release_mbid}/front-250`

const expanded = computed(() => store.expanded[props.release.release_mbid] as ExpandedRelease | undefined)
const isOpen = computed(() => store.isExpanded(props.release.release_mbid))

function toggle() {
  store.toggleExpand(props.release.release_mbid)
}

function toggleTrack(position: number, inLibrary: boolean) {
  if (inLibrary) return
  store.toggleTrack(props.release.release_mbid, position)
}

function initials(name: string) {
  return name.split(' ').slice(0, 2).map((w) => w[0]).join('').toUpperCase()
}

const displayDate = computed(() =>
  expanded.value?.release_date || props.release.release_date
)

function formatDate(d: string) {
  if (!d) return ''
  const [y, m, day] = d.split('-')
  return day ? `${day}/${m}/${y}` : m ? `${m}/${y}` : y
}
</script>

<template>
  <div class="card-wrap" :class="{ open: isOpen }">
    <div class="card" @click="toggle">
      <div class="cover">
        <img v-if="!imgError" :src="coverUrl" loading="lazy" @error="imgError = true" />
        <div v-else class="cover-placeholder">{{ initials(release.artist_credit_name) }}</div>
      </div>
      <div class="info">
        <div class="artist">{{ release.artist_credit_name }}</div>
        <div class="name">{{ release.release_name }}</div>
        <div class="meta">
          {{ release.type_label }}
          <span v-if="displayDate"> · {{ formatDate(displayDate) }}</span>
        </div>
      </div>
      <div class="right">
        <span v-if="release.in_library" class="badge in-lib">✓</span>
        <span class="chevron" :class="{ rotated: isOpen }">›</span>
      </div>
    </div>

    <div v-if="isOpen" class="tracks">
      <div v-if="expanded?.loading" class="tracks-loading"><n-spin size="small" /></div>
      <div v-else-if="expanded?.error" class="tracks-error">{{ expanded.error }}</div>
      <div v-else-if="expanded?.tracks.length" class="tracklist">
        <div
          v-for="track in expanded.tracks"
          :key="track.position"
          class="track"
          :class="{ 'in-library': track.in_library, 'selectable': !track.in_library }"
          @click.stop="toggleTrack(track.position, track.in_library)"
        >
          <span class="track-num">{{ track.position }}</span>
          <span class="track-title">{{ track.title }}</span>
          <span class="track-check">
            <span v-if="track.in_library" class="check-lib">✓</span>
            <n-checkbox
              v-else
              :checked="expanded?.selected.includes(track.position)"
              @click.stop
              @update:checked="toggleTrack(track.position, false)"
            />
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.card-wrap {
  border-bottom: 1px solid rgba(128,128,128,0.1);
}
.card-wrap.open {
  border-bottom-color: rgba(128,128,128,0.2);
}

.card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  cursor: pointer;
  transition: opacity 0.15s;
}
.card:active { opacity: 0.7; }

.cover {
  width: 52px;
  height: 52px;
  border-radius: 6px;
  overflow: hidden;
  flex-shrink: 0;
  background: rgba(128,128,128,0.15);
}
.cover img { width: 100%; height: 100%; object-fit: cover; }
.cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 600;
  color: rgba(128,128,128,0.6);
}

.info { flex: 1; min-width: 0; }
.artist { font-size: 13px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.name { font-size: 13px; opacity: 0.8; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-top: 2px; }
.meta { font-size: 11px; opacity: 0.5; margin-top: 3px; }

.right { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.badge { font-size: 12px; padding: 2px 6px; border-radius: 10px; }
.in-lib { background: rgba(52, 199, 89, 0.2); color: #34c759; }

.chevron {
  font-size: 18px;
  opacity: 0.4;
  transition: transform 0.2s;
  display: inline-block;
  transform: rotate(0deg);
}
.chevron.rotated { transform: rotate(90deg); }

.tracks {
  background: rgba(128,128,128,0.04);
}

.tracks-loading {
  display: flex;
  justify-content: center;
  padding: 20px;
}

.tracks-error {
  color: #ff3b30;
  font-size: 13px;
  padding: 12px 16px;
}

.tracklist { padding: 0 16px; }

.track {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid rgba(128,128,128,0.08);
  font-size: 13px;
}
.track:last-child { border-bottom: none; }
.track.selectable { cursor: pointer; }
.track.selectable:active { opacity: 0.6; }
.track.in-library { opacity: 0.5; }

.track-num { width: 20px; text-align: right; opacity: 0.4; font-size: 11px; flex-shrink: 0; }
.track-title { flex: 1; }
.track-check { flex-shrink: 0; display: flex; align-items: center; }
.check-lib { color: #34c759; font-size: 13px; }
</style>
