#!/usr/bin/env python3
import hashlib
import hmac
import json
import logging
import shutil
import subprocess
import threading
import time
import uuid
from abc import ABC, abstractmethod
from concurrent.futures import ThreadPoolExecutor
from typing import Literal
from urllib.parse import parse_qs

import re
import musicbrainzngs
import requests as _requests
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from mutagen.oggopus import OggOpus
from pydantic import BaseModel
import os

from library import (
    TOKEN, ALLOWED_USERS, DOWNLOADS, REVIEW,
    _beets_lib, already_in_library, beet_path,
    download_track_for_album, run_beet_import, embed_cover_art,
    fetch_fresh_releases, save_playlist_m3u, sanitize,
)

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="MusicBot API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5743", "https://t.me"],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["X-Telegram-Init-Data", "Content-Type"],
)

import asyncio

_executor = ThreadPoolExecutor(max_workers=10)
_jobs: dict[str, "JobStatus"] = {}
_jobs_lock = threading.Lock()
_import_queue = asyncio.Queue()

async def _import_worker():
    """Worker de background que consome a fila de importação sequencialmente."""
    while True:
        task = await _import_queue.get()
        try:
            await task()
        except Exception as e:
            logging.error(f"[import_worker] Task failed: {e}")
        finally:
            _import_queue.task_done()

# Iniciar o worker ao subir a API
@app.on_event("startup")
async def startup_event():
    asyncio.create_task(_import_worker())


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

def validate_telegram_init_data(init_data: str) -> dict | None:
    parsed = parse_qs(init_data, keep_blank_values=True)
    received_hash = parsed.pop("hash", [None])[0]
    if not received_hash:
        return None
    data_check_string = "\n".join(
        f"{k}={v[0]}" for k, v in sorted(parsed.items())
    )
    secret_key = hmac.new(b"WebAppData", TOKEN.encode(), hashlib.sha256).digest()
    expected = hmac.new(secret_key, data_check_string.encode(), hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected, received_hash):
        return None
    user_raw = parsed.get("user", [None])[0]
    if not user_raw:
        return None
    return json.loads(user_raw)


async def require_telegram_user(
    x_telegram_init_data: str = Header(...),
) -> dict:
    user = validate_telegram_init_data(x_telegram_init_data)
    if not user or user.get("id") not in ALLOWED_USERS:
        raise HTTPException(status_code=403, detail="Forbidden")
    return user


# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------

class TrackStatus(BaseModel):
    position: int
    disc: int
    title: str
    in_library: bool
    path: str | None


class FreshRelease(BaseModel):
    release_mbid: str
    release_name: str
    artist_credit_name: str
    release_date: str
    release_group_primary_type: str
    release_group_secondary_type: str | None
    confidence: int
    in_library: bool


class ReleaseTracksResponse(BaseModel):
    release_id: str
    artist: str
    album: str
    release_date: str
    tracks: list[TrackStatus]
    have: int
    missing: int


class TrackDownloadStatus(BaseModel):
    position: int
    title: str
    status: Literal["pending", "in_library", "downloading", "converting", "importing", "done", "failed", "cancelled"]
    source: str | None = None
    percent: float | None = None
    transfer_id: str | None = None
    slskd_username: str | None = None


class JobStatus(BaseModel):
    job_id: str
    status: Literal["pending", "running", "processing", "done", "failed"]
    release_id: str
    artist: str
    album: str
    total_tracks: int
    tracks: list[TrackDownloadStatus] = []
    processing_tracks: int = 0
    error: str | None = None
    status_message: str | None = None  # Dynamic feedback message


class ReviewFile(BaseModel):
    filename: str
    artist: str | None
    title: str | None
    album: str | None
    duration: float | None
    size_bytes: int
    review_reason: str | None = None
    expected_mbid: str | None = None
    expected_tracknum: str | None = None
    expected_album: str | None = None
    expected_artist: str | None = None


class SearchResult(BaseModel):
    artist: str
    title: str
    album: str
    path: str
    track: int | None
    year: int | None


class DownloadRequest(BaseModel):
    positions: list[int] | None = None


class ReleaseResult(BaseModel):
    release_mbid: str
    release_name: str
    artist_credit_name: str
    release_date: str
    primary_type: str
    secondary_type: str | None
    in_library: bool


# ---------------------------------------------------------------------------
# Download sources
# ---------------------------------------------------------------------------

class DownloadSource(ABC):
    def download_album(self, artist: str, album: str, release_id: str,
                       tracks: list[dict]) -> dict[str, str]:
        """Download all tracks for an album at once.

        Returns a mapping of {title → local_opus_path} for tracks that were
        successfully downloaded. Titles absent from the result will be retried
        via download_track() by the caller.
        """
        return {}

    @abstractmethod
    def download_track(self, artist: str, title: str, album: str,
                       release_id: str) -> tuple[str | None, bool]:
        """Download a single track. Returns (filepath, confirmed)."""


class YtDlpSource(DownloadSource):
    def download_track(self, artist: str, title: str, album: str,
                       release_id: str) -> tuple[str | None, bool]:
        return download_track_for_album(artist, title, album, release_id)


class SoulseekSource(DownloadSource):
    _SLSKD_URL = os.environ.get("SLSKD_URL", "http://localhost:5030")
    _SLSKD_USER = os.environ.get("SLSKD_USER", "slskd")
    _SLSKD_PASS = os.environ.get("SLSKD_PASS", "slskd")
    _AUDIO_EXTS = {"flac", "mp3", "ogg", "opus"}

    def _token(self) -> str:
        resp = _requests.post(
            f"{self._SLSKD_URL}/api/v0/session",
            json={"username": self._SLSKD_USER, "password": self._SLSKD_PASS},
            timeout=10,
        )
        resp.raise_for_status()
        return resp.json()["token"]

    def _search(self, token: str, query: str, file_limit: int = 100) -> list[dict]:
        search_id = str(uuid.uuid4())
        _requests.post(
            f"{self._SLSKD_URL}/api/v0/searches",
            headers={"Authorization": f"Bearer {token}"},
            json={"id": search_id, "searchText": query, "fileLimit": file_limit},
            timeout=10,
        ).raise_for_status()

        deadline = time.time() + 30
        while time.time() < deadline:
            r = _requests.get(
                f"{self._SLSKD_URL}/api/v0/searches/{search_id}",
                headers={"Authorization": f"Bearer {token}"},
                timeout=10,
            ).json()
            if "Completed" in r.get("state", "") or "Stopped" in r.get("state", ""):
                break
            time.sleep(1)

        resp = _requests.get(
            f"{self._SLSKD_URL}/api/v0/searches/{search_id}/responses",
            headers={"Authorization": f"Bearer {token}"},
            timeout=10,
        )
        return resp.json() if resp.ok else []

    def _normalize_title(self, s: str) -> str:
        import unicodedata
        s = unicodedata.normalize("NFD", s).encode("ascii", "ignore").decode().lower()
        return re.sub(r"[^\w\s]", "", s).strip()

    def _match_track(self, basename: str, title: str) -> bool:
        return self._normalize_title(title) in self._normalize_title(basename)

    def _ext(self, filename: str) -> str:
        return filename.rsplit(".", 1)[-1].lower() if "." in filename else ""

    def _fmt_rank(self, ext: str) -> int:
        return {"flac": 0, "opus": 1, "ogg": 2, "mp3": 3}.get(ext, 9)

    def _pick_best_peers(self, responses: list[dict],
                         tracks: list[dict], artist: str, max_peers: int = 5) -> list[tuple[str, list[dict]]]:
        """Find peers that have tracks from the album, ordered by quality.

        Returns [(username, [{title, filename, size, ext}, ...]), ...] ordered best to worst.
        Returns up to max_peers candidates.
        """
        norm_artist = self._normalize_title(artist)
        titles = [t["title"] for t in tracks]

        candidates: list[tuple[int, int, int, str, list]] = []  # (matches, fmt, -speed, user, files)

        for resp in responses:
            username = resp.get("username", "")
            upload_speed = resp.get("uploadSpeed", 0) or 0
            free_slots = resp.get("freeUploadSlots", 0) or 0
            queue_length = resp.get("queueLength", 0) or 0
            files = resp.get("files", [])
            
            # Debug: log peer info on first peer
            if not candidates:
                logging.info(f"[slskd] Sample peer data: speed={upload_speed}, free_slots={free_slots}, queue={queue_length}")

            # All files must share a common folder (same album directory)
            # Group files by their parent directory
            by_dir: dict[str, list[dict]] = {}
            for f in files:
                path = f.get("filename", "").replace("\\", "/")
                folder = path.rsplit("/", 1)[0]
                by_dir.setdefault(folder, []).append(f)

            for folder, dir_files in by_dir.items():
                folder_lower = folder.lower()
                # Skip if artist not in path at all
                if norm_artist not in self._normalize_title(folder_lower):
                    continue

                # Try to match each expected track to a file in this folder
                matched: list[dict] = []
                exts_used: set[str] = set()
                for title in titles:
                    for f in dir_files:
                        basename = f["filename"].replace("\\", "/").rsplit("/", 1)[-1]
                        ext = self._ext(basename)
                        if ext not in self._AUDIO_EXTS:
                            continue
                        if self._match_track(basename, title):
                            matched.append({
                                "title": title,
                                "filename": f["filename"],
                                "size": f.get("size", 0) or 0,
                                "ext": ext,
                            })
                            exts_used.add(ext)
                            break

                if matched:
                    # Prefer consistent format (one ext), best format wins
                    fmt = min(self._fmt_rank(e) for e in exts_used)
                    n_matched = len(matched)
                    candidates.append((n_matched, fmt, -upload_speed, username, matched))

        if not candidates:
            return []

        # Sort by: most matches first, then best format, then fastest speed
        candidates.sort(reverse=True)
        
        # Return up to max_peers, converted to (username, files) tuples
        result = [(username, matched) for _, _, _, username, matched in candidates[:max_peers]]
        logging.info(f"[slskd] found {len(result)} peer candidates (showing top {max_peers})")
        for i, (username, matched) in enumerate(result[:3], 1):
            logging.info(f"[slskd]   #{i}: {username!r} with {len(matched)}/{len(titles)} tracks")
        return result

    def _enqueue_many(self, token: str, username: str,
                      files: list[dict]) -> list[tuple[str, str, str]]:
        """Enqueue multiple files from one peer. Returns [(transfer_id, filename, title), ...]."""
        payload = [{"filename": f["filename"], "size": f["size"]} for f in files]
        resp = _requests.post(
            f"{self._SLSKD_URL}/api/v0/transfers/downloads/{username}",
            headers={"Authorization": f"Bearer {token}"},
            json=payload,
            timeout=10,
        )
        resp.raise_for_status()
        enqueued = resp.json().get("enqueued", [])
        title_by_filename = {f["filename"]: f["title"] for f in files}
        return [(e["id"], e["filename"], title_by_filename.get(e["filename"], ""))
                for e in enqueued]

    def cancel_transfer(self, token: str, username: str, transfer_id: str):
        """Cancel a single transfer in slskd."""
        try:
            _requests.delete(
                f"{self._SLSKD_URL}/api/v0/transfers/downloads/{username}/{transfer_id}",
                headers={"Authorization": f"Bearer {token}"},
                params={"remove": "true"},
                timeout=10,
            )
        except Exception as e:
            logging.warning(f"[slskd] cancel failed for {transfer_id}: {e}")

    def poll_transfers(self, token: str, username: str,
                       transfers: list[tuple[str, str, str]]) -> dict[str, tuple[str, str, float]]:
        """Poll all transfers in parallel. Returns {title → ('done'|'failed'|'pending', local_path, percent)}."""
        headers = {"Authorization": f"Bearer {token}"}

        def _poll_one(tid: str, fname: str, title: str) -> tuple[str, tuple[str, str, float]]:
            try:
                r = _requests.get(
                    f"{self._SLSKD_URL}/api/v0/transfers/downloads/{username}/{tid}",
                    headers=headers, timeout=10,
                ).json()
            except Exception:
                return title, ("pending", "", 0.0)
            state = r.get("state", "")
            pct = float(r.get("percentComplete", 0) or 0)
            if "Succeeded" in state:
                return title, ("done", self._locate_file(fname) or "", 100.0)
            if any(s in state for s in ("Cancelled", "Errored", "Rejected", "TimedOut")):
                return title, ("failed", "", pct)
            return title, ("pending", "", pct)

        from concurrent.futures import ThreadPoolExecutor as _TPE
        with _TPE(max_workers=min(len(transfers), 8)) as ex:
            return dict(ex.map(lambda t: _poll_one(*t), transfers))

    def _locate_file(self, slskd_filename: str) -> str | None:
        basename = slskd_filename.replace("\\", "/").rsplit("/", 1)[-1]
        for root, _, files in os.walk("/var/lib/slskd/downloads"):
            if basename in files:
                return os.path.join(root, basename)
        return None

    def _to_opus(self, src: str, artist: str, title: str) -> str | None:
        """Convert downloaded file to opus format with basic tags."""
        try:
            if not os.path.exists(src):
                logging.warning(f"[slskd] Source file does not exist: {src}")
                return None
            
            ext = self._ext(src)
            safe_artist = sanitize(artist)
            safe_title = sanitize(title)
            dest = f"{DOWNLOADS}/{safe_artist} - {safe_title}.opus"

            if ext == "opus":
                os.rename(src, dest)
            else:
                result = subprocess.run(
                    ["ffmpeg", "-y", "-i", src, "-c:a", "libopus", "-b:a", "192k", "-vn", dest],
                    capture_output=True,
                )
                if result.returncode != 0:
                    logging.warning(f"[slskd] ffmpeg failed: {result.stderr.decode()[:200]}")
                    return None
                try:
                    os.remove(src)
                except Exception as e:
                    logging.warning(f"[slskd] Could not remove source file {src}: {e}")

            try:
                f = OggOpus(dest)
                f["artist"] = artist
                f["title"] = title
                f["discnumber"] = "1"
                f["disctotal"] = "1"
                f.save()
            except Exception as e:
                logging.warning(f"[slskd] tag failed for {dest}: {e}")
            
            return dest
        except Exception as e:
            logging.error(f"[slskd] _to_opus failed for {src}: {e}", exc_info=True)
            return None

    def start_album_download(self, artist: str, album: str,
                              tracks: list[dict]) -> tuple[str, str, list[tuple[str, str, str]]] | None:
        """Search and enqueue album tracks. Returns (token, username, [(transfer_id, filename, title)]) or None."""
        try:
            token = self._token()
            query = f"{artist} {album}"
            logging.info(f"[slskd] album search: {query!r}")
            responses = self._search(token, query, file_limit=200)
            if not responses:
                return None
            peers = self._pick_best_peers(responses, tracks, artist, max_peers=5)
            if not peers:
                logging.info("[slskd] no peer with enough album tracks found")
                return None
            username, matched_files = peers[0]  # Try best peer first
            transfers = self._enqueue_many(token, username, matched_files)
            return token, username, transfers
        except Exception as e:
            logging.warning(f"[slskd] start_album_download failed: {e}")
            return None

    def retry_with_next_peer(self, artist: str, album: str,
                             tracks: list[dict], tried_usernames: list[str]) -> tuple[str, str, list[tuple[str, str, str]]] | None:
        """Try next available peer that hasn't been tried yet. Returns same format as start_album_download."""
        try:
            token = self._token()
            query = f"{artist} {album}"
            logging.info(f"[slskd] retry search for next peer (excluding {tried_usernames})")
            responses = self._search(token, query, file_limit=200)
            if not responses:
                return None
            
            peers = self._pick_best_peers(responses, tracks, artist, max_peers=10)
            # Filter out already-tried peers
            available = [(u, f) for u, f in peers if u not in tried_usernames]
            if not available:
                logging.info(f"[slskd] no more peers available (tried: {tried_usernames})")
                return None
            
            username, matched_files = available[0]
            logging.info(f"[slskd] retrying with peer {username!r} ({len(matched_files)} tracks)")
            transfers = self._enqueue_many(token, username, matched_files)
            return token, username, transfers
        except Exception as e:
            logging.warning(f"[slskd] retry_with_next_peer failed: {e}")
            return None

    def download_track(self, artist: str, title: str, album: str,
                       release_id: str) -> tuple[str | None, bool]:
        # Not used for album flow — only fallback for individual tracks
        return None, False


_sources: list[DownloadSource] = [SoulseekSource(), YtDlpSource()]


# ---------------------------------------------------------------------------
# Job system
# ---------------------------------------------------------------------------

def _update_job(job_id: str, **kwargs):
    with _jobs_lock:
        job = _jobs.get(job_id)
        if job:
            for k, v in kwargs.items():
                setattr(job, k, v)


def _update_job_processing(job_id: str, delta: int):
    with _jobs_lock:
        job = _jobs.get(job_id)
        if job:
            job.processing_tracks += delta
            if job.status == "running" and job.processing_tracks <= 0:
                job.status = "done"
            elif job.status == "done" and job.processing_tracks > 0:
                job.status = "processing"

def _update_track(job_id: str, position: int, **kwargs):
    with _jobs_lock:
        job = _jobs.get(job_id)
        if not job:
            return
        for t in job.tracks:
            if t.position == position:
                for k, v in kwargs.items():
                    setattr(t, k, v)
                break


def _get_track(job_id: str, position: int) -> TrackDownloadStatus | None:
    with _jobs_lock:
        job = _jobs.get(job_id)
        if not job:
            return None
        for t in job.tracks:
            if t.position == position:
                return t
        return None


_slskd = SoulseekSource()


def _import_track(filepath: str, artist: str, title: str, position: int,
                  job_id: str, mb_context: dict, cover_queue: dict):
    """Import a single track - safe to call from multiple threads."""
    try:
        _update_track(job_id, position, status="importing")
        skipped, mb_albumid = run_beet_import(filepath, artist, mb_context)
        if skipped:
            _update_track(job_id, position, status="failed")
        else:
            _update_track(job_id, position, status="done")
            if mb_albumid:
                final = beet_path(artist, title)
                if final:
                    with _jobs_lock:
                        cover_queue.setdefault(mb_albumid, []).append(final)
    except Exception as e:
        logging.error(f"[job {job_id}] Import failed for track {position}: {e}", exc_info=True)
        _update_track(job_id, position, status="failed")


def _ytdlp_track(job_id: str, position: int, artist: str, title: str,
                  album: str, release_id: str, mb_context: dict, cover_queue: dict):
    """Download track from YouTube and move to review folder for manual validation."""
    try:
        _update_track(job_id, position, status="downloading", source="YouTube")
        filepath, _ = YtDlpSource().download_track(artist, title, album, release_id)
        if not filepath:
            _update_track(job_id, position, status="failed")
            return
        
        # YouTube downloads go straight to review - we can't trust they're correct
        review_dir = REVIEW
        os.makedirs(review_dir, exist_ok=True)
        
        # Move to review folder
        basename = os.path.basename(filepath)
        review_path = os.path.join(review_dir, basename)
        
        # Add basic tags so it's easier to identify in review
        try:
            f = OggOpus(filepath)
            f["artist"] = artist
            f["title"] = title
            f["album"] = album
            f.save()
        except Exception as e:
            logging.warning(f"[ytdlp] Failed to tag {filepath}: {e}")
        
        shutil.move(filepath, review_path)
        logging.info(f"[job {job_id}] Track {position} from YouTube moved to review: {review_path}")
        
        # Mark as "failed" for now (will be changed to "needs_review" status later)
        # This signals UI to show it needs attention
        _update_track(job_id, position, status="failed")
    except Exception as e:
        logging.error(f"[job {job_id}] YouTube download failed for track {position}: {e}", exc_info=True)
        _update_track(job_id, position, status="failed")


def _download_album_worker(job_id: str, release_id: str, artist: str,
                           album_title: str, tracks: list[dict]):
    logging.info(f"[job {job_id}] Starting worker for {artist} - {album_title}")
    mb_context = {"release_id": release_id, "album": album_title, "artist": artist}
    cover_queue: dict[str, list[str]] = {}

    # Build initial track list
    track_statuses = []
    for t in tracks:
        status = "in_library" if already_in_library(artist, t["title"], release_id) else "pending"
        track_statuses.append(TrackDownloadStatus(
            position=t["position"], title=t["title"], status=status,
        ))
    _update_job(job_id, status="running", tracks=track_statuses)

    to_fetch = [t for t in tracks if not already_in_library(artist, t["title"], release_id)]
    logging.info(f"[job {job_id}] Need to fetch {len(to_fetch)} tracks")

    tried_peers = []
    max_peer_retries = 3  # Try up to 3 different peers before giving up

    for retry_attempt in range(max_peer_retries):
        try:
            # Start Soulseek album download (first time or retry with next peer)
            if retry_attempt == 0:
                logging.info(f"[job {job_id}] Preparing Soulseek search for {to_fetch}")
                _update_job(job_id, status_message="🔍 Procurando peers no Soulseek...")
                slskd_result = _slskd.start_album_download(artist, album_title, to_fetch)
            else:
                logging.info(f"[job {job_id}] Retry attempt #{retry_attempt + 1}: trying next peer")
                _update_job(job_id, status_message=f"🔄 Tentando peer alternativo ({retry_attempt + 1}/{max_peer_retries})...")
                slskd_result = _slskd.retry_with_next_peer(artist, album_title, to_fetch, tried_peers)

            if slskd_result:
                token, username, transfers = slskd_result
                tried_peers.append(username)
                logging.info(f"[job {job_id}] Soulseek matched {len(transfers)} tracks from peer {username}")
                _update_job(job_id, status_message=f"⬇️ Baixando de '{username}' ({len(transfers)} tracks)")
                # Map title → (transfer_id, filename)
                by_title = {title: (tid, fname) for tid, fname, title in transfers}
                # Update tracks that got a transfer
                for t in to_fetch:
                    title = t["title"]
                    pos = t["position"]
                    if title in by_title:
                        tid, _ = by_title[title]
                        _update_track(job_id, pos, status="downloading", source="Soulseek",
                                      transfer_id=tid, slskd_username=username)

                # Poll until all Soulseek transfers are done or cancelled
                pending_transfers = list(transfers)
                while pending_transfers:
                    logging.info(f"[job {job_id}] Polling Soulseek transfers: {len(pending_transfers)} remaining")
                    time.sleep(3)
                    poll = _slskd.poll_transfers(token, username, pending_transfers)
                    still_pending = []
                    for tid, fname, title in pending_transfers:
                        pos = next((t["position"] for t in tracks if t["title"] == title), None)
                        if pos is None:
                            continue
                        track = _get_track(job_id, pos)
                        if track and track.status == "cancelled":
                            logging.info(f"[job {job_id}] Track {pos} cancelled, removing from Soulseek poll")
                            continue
                        state, local_path, pct = poll.get(title, ("pending", "", 0.0))
                        if state == "done" and local_path:
                            logging.info(f"[job {job_id}] Track {pos} download done, dispatching process task")
                            _update_track(job_id, pos, status="converting", percent=None)
                            
                            # Captura as variáveis atuais para a closure da thread
                            def _process_task(lp=local_path, art=artist, tit=title, p=pos, j=job_id, rid=release_id, alb=album_title, q=cover_queue):
                                try:
                                    ctx = {
                                        "release_id": rid,
                                        "album": alb,
                                        "artist": art,
                                        "position": p,
                                        "title": tit
                                    }
                                    opus = _slskd._to_opus(lp, art, tit)
                                    if opus:
                                        _import_track(opus, art, tit, p, j, ctx, q)
                                    else:
                                        _update_track(j, p, status="failed")
                                except Exception as e:
                                    logging.error(f"[job {j}] Process task failed for track {p}: {e}", exc_info=True)
                                    _update_track(j, p, status="failed")

                            _executor.submit(_process_task)
                        elif state == "failed":
                            logging.info(f"[job {job_id}] Track {pos} download failed in slskd")
                            _update_track(job_id, pos, status="pending", percent=None)  # Mark as pending to retry
                        else:
                            _update_track(job_id, pos, percent=pct)
                            still_pending.append((tid, fname, title))
                    pending_transfers = still_pending
                
                # Check if we still have pending/failed tracks after this peer
                to_fetch = []
                for t in tracks:
                    track = _get_track(job_id, t["position"])
                    if track and track.status in ("pending", "failed"):
                        to_fetch.append(t)
                
                if not to_fetch:
                    # All tracks succeeded! No need to retry
                    logging.info(f"[job {job_id}] All tracks downloaded successfully from peer {username}")
                    _update_job(job_id, status_message="✅ Downloads completos")
                    break
                else:
                    logging.info(f"[job {job_id}] {len(to_fetch)} tracks still pending/failed after peer {username}")
                    _update_job(job_id, status_message=f"⚠️ Peer '{username}' falhou em {len(to_fetch)} tracks")
            else:
                logging.info(f"[job {job_id}] Soulseek found no suitable peer on attempt #{retry_attempt + 1}")
                _update_job(job_id, status_message="❌ Nenhum peer encontrado")
                break  # No more peers available

        except Exception as e:
            logging.error(f"[job {job_id}] Error during Soulseek retry attempt #{retry_attempt + 1}: {e}", exc_info=True)
            break

    # After all Soulseek retries, tracks with status "pending" or "failed" stay as-is
    # User can manually trigger YouTube download via button in UI
    logging.info(f"[job {job_id}] Soulseek phase complete. Tried peers: {tried_peers}")

    if cover_queue:
        logging.info(f"[job {job_id}] Embedding cover art for {len(cover_queue)} albums")
        for mid, paths in cover_queue.items():
            embed_cover_art(mid, paths)

    logging.info(f"[job {job_id}] Worker finished")
    _update_job(job_id, status="done")


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@app.get("/fresh-releases", response_model=list[FreshRelease])
async def get_fresh_releases(
    only_albums: bool = False,
    user: dict = Depends(require_telegram_user),
):
    import asyncio
    loop = asyncio.get_event_loop()
    releases = await loop.run_in_executor(_executor, lambda: fetch_fresh_releases(only_albums))

    result = []
    for r in releases:
        mbid = r.get("release_mbid", "")
        in_lib = bool(list(_beets_lib.items(f'mb_albumid:"{mbid}"'))) if mbid else False
        result.append(FreshRelease(
            release_mbid=mbid,
            release_name=r.get("release_name", ""),
            artist_credit_name=r.get("artist_credit_name", ""),
            release_date=r.get("release_date", ""),
            release_group_primary_type=r.get("release_group_primary_type", ""),
            release_group_secondary_type=r.get("release_group_secondary_type"),
            confidence=r.get("confidence", 0),
            in_library=in_lib,
        ))
    return result


@app.get("/release/{mbid}/tracks", response_model=ReleaseTracksResponse)
async def get_release_tracks(
    mbid: str,
    user: dict = Depends(require_telegram_user),
):
    import asyncio
    loop = asyncio.get_event_loop()

    def _fetch():
        return musicbrainzngs.get_release_by_id(mbid, includes=["recordings", "artists"])

    try:
        data = await loop.run_in_executor(_executor, _fetch)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

    release = data["release"]
    album_title = release.get("title", "")
    artist_credits = release.get("artist-credit", [])
    artist = artist_credits[0].get("artist", {}).get("name", "") if artist_credits else ""

    release_in_lib = bool(list(_beets_lib.items(f'mb_albumid:"{mbid}"')))

    tracks = []
    global_pos = 0
    for medium in release.get("medium-list", []):
        disc = int(medium.get("position", 1))
        for track in medium.get("track-list", []):
            global_pos += 1
            title = track["recording"]["title"]
            
            # Verificação precisa por faixa + album_id
            in_lib = already_in_library(artist, title, mbid)
            path = beet_path(artist, title) if in_lib else None

            tracks.append(TrackStatus(
                position=global_pos,
                disc=disc,
                title=title,
                in_library=in_lib,
                path=path,
            ))

    have = sum(1 for t in tracks if t.in_library)
    return ReleaseTracksResponse(
        release_id=mbid,
        artist=artist,
        album=album_title,
        release_date=release.get("date", ""),
        tracks=tracks,
        have=have,
        missing=len(tracks) - have,
    )


@app.post("/release/{mbid}/download")
async def start_download(
    mbid: str,
    body: DownloadRequest = DownloadRequest(),
    user: dict = Depends(require_telegram_user),
):
    import asyncio
    loop = asyncio.get_event_loop()

    def _fetch():
        return musicbrainzngs.get_release_by_id(mbid, includes=["recordings", "artists"])

    try:
        data = await loop.run_in_executor(_executor, _fetch)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

    release = data["release"]
    album_title = release.get("title", "")
    artist_credits = release.get("artist-credit", [])
    artist = artist_credits[0].get("artist", {}).get("name", "") if artist_credits else ""

    all_tracks = []
    global_pos = 0
    for medium in release.get("medium-list", []):
        for track in medium.get("track-list", []):
            global_pos += 1
            all_tracks.append({
                "title": track["recording"]["title"],
                "position": global_pos,
            })

    if body.positions:
        pos_set = set(body.positions)
        tracks = [t for t in all_tracks if t["position"] in pos_set]
    else:
        tracks = all_tracks

    job_id = str(uuid.uuid4())
    job = JobStatus(
        job_id=job_id,
        status="pending",
        release_id=mbid,
        artist=artist,
        album=album_title,
        total_tracks=len(tracks),
    )
    with _jobs_lock:
        _jobs[job_id] = job

    _executor.submit(_download_album_worker, job_id, mbid, artist, album_title, tracks)
    return {"job_id": job_id, "artist": artist, "album": album_title, "total_tracks": len(tracks)}


@app.get("/jobs/{job_id}", response_model=JobStatus)
async def get_job(
    job_id: str,
    user: dict = Depends(require_telegram_user),
):
    with _jobs_lock:
        job = _jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job


@app.delete("/jobs/{job_id}")
async def cancel_job(
    job_id: str,
    user: dict = Depends(require_telegram_user),
):
    """Cancel an entire job and all its downloads."""
    with _jobs_lock:
        job = _jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    
    if job.status in ("completed", "cancelled"):
        return {"ok": True, "message": f"Job already {job.status}"}
    
    # Cancel all active Soulseek transfers
    for track in job.tracks:
        if track.status == "downloading" and track.transfer_id and track.slskd_username:
            try:
                token = _slskd._token()
                _slskd.cancel_transfer(token, track.slskd_username, track.transfer_id)
                logging.info(f"[cancel] Cancelled Soulseek transfer {track.transfer_id} for track {track.position}")
            except Exception as e:
                logging.warning(f"[cancel] Failed to cancel transfer {track.transfer_id}: {e}")
        
        # Mark all non-completed tracks as cancelled
        if track.status not in ("done", "in_library"):
            _update_track(job_id, track.position, status="cancelled")
    
    _update_job(job_id, status="cancelled", status_message="❌ Cancelado pelo usuário")
    logging.info(f"[cancel] Job {job_id} cancelled by user")
    
    return {"ok": True, "message": "Job cancelled"}


@app.post("/jobs/{job_id}/tracks/{position}/use-ytdlp")
async def cancel_slskd_use_ytdlp(
    job_id: str,
    position: int,
    user: dict = Depends(require_telegram_user),
):
    with _jobs_lock:
        job = _jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    track = _get_track(job_id, position)
    if not track:
        raise HTTPException(status_code=404, detail="Track not found")
    if track.status not in ("pending", "downloading"):
        raise HTTPException(status_code=400, detail=f"Track is {track.status}, cannot switch")

    # Cancel Soulseek transfer if active
    if track.transfer_id and track.slskd_username:
        try:
            token = _slskd._token()
            _slskd.cancel_transfer(token, track.slskd_username, track.transfer_id)
        except Exception as e:
            logging.warning(f"[cancel] slskd cancel failed: {e}")

    _update_track(job_id, position, status="cancelled", transfer_id=None, slskd_username=None)

    # Kick off yt-dlp in the background
    track_info = next((t for t in job.tracks if t.position == position), None)
    if track_info:
        mb_context = {"release_id": job.release_id, "album": job.album, "artist": job.artist}
        _executor.submit(
            _ytdlp_track, job_id, position, job.artist, track_info.title,
            job.album, job.release_id, mb_context, {}
        )

    return {"ok": True}


@app.get("/search/releases", response_model=list[ReleaseResult])
async def search_releases(
    q: str,
    type: str | None = None,
    user: dict = Depends(require_telegram_user),
):
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Query must be at least 2 characters")

    import asyncio
    loop = asyncio.get_event_loop()

    def _search():
        kwargs: dict = {"release": q, "limit": 25}
        if type:
            kwargs["type"] = type

        results = musicbrainzngs.search_releases(**kwargs)
        releases = results.get("release-list", [])

        # Deduplicate by (title, artist, date) — keep first occurrence
        seen = set()
        out = []
        for r in releases:
            artist = r.get("artist-credit-phrase", "")
            name = r.get("title", "")
            date = r.get("date", "")
            key = (name.lower(), artist.lower(), date[:4])
            if key in seen:
                continue
            seen.add(key)

            release_mbid = r.get("id", "")
            rg = r.get("release-group", {})
            primary_type = rg.get("primary-type", "")
            secondary_list = rg.get("secondary-type-list", [])
            secondary_type = secondary_list[0] if secondary_list else None
            in_lib = bool(list(_beets_lib.items(f'mb_albumid:"{release_mbid}"'))) if release_mbid else False

            out.append(ReleaseResult(
                release_mbid=release_mbid,
                release_name=name,
                artist_credit_name=artist,
                release_date=date,
                primary_type=primary_type,
                secondary_type=secondary_type,
                in_library=in_lib,
            ))
        return out

    return await loop.run_in_executor(_executor, _search)


@app.get("/search/artists", response_model=list[ReleaseResult])
async def search_by_artist(
    q: str,
    user: dict = Depends(require_telegram_user),
):
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Query must be at least 2 characters")

    import asyncio
    loop = asyncio.get_event_loop()

    def _search():
        artist_results = musicbrainzngs.search_artists(artist=q, limit=5)
        artists = artist_results.get("artist-list", [])
        if not artists:
            return []

        best_artist = artists[0]
        artist_id = best_artist.get("id", "")
        artist_name = best_artist.get("name", "")

        results = musicbrainzngs.search_releases(arid=artist_id, limit=50, primarytype="Album")
        releases = results.get("release-list", [])

        seen = set()
        out = []
        for r in sorted(releases, key=lambda r: r.get("date", "9999")):
            name = r.get("title", "")
            date = r.get("date", "")
            key = (name.lower(), date[:4])
            if key in seen:
                continue
            seen.add(key)

            release_mbid = r.get("id", "")
            rg = r.get("release-group", {})
            primary_type = rg.get("primary-type", "")
            secondary_list = rg.get("secondary-type-list", [])
            secondary_type = secondary_list[0] if secondary_list else None
            in_lib = bool(list(_beets_lib.items(f'mb_albumid:"{release_mbid}"'))) if release_mbid else False

            out.append(ReleaseResult(
                release_mbid=release_mbid,
                release_name=name,
                artist_credit_name=artist_name,
                release_date=date,
                primary_type=primary_type,
                secondary_type=secondary_type,
                in_library=in_lib,
            ))
        return out

    return await loop.run_in_executor(_executor, _search)


@app.get("/review", response_model=list[ReviewFile])
async def get_review(user: dict = Depends(require_telegram_user)):
    files = []
    for filename in os.listdir(REVIEW):
        if not filename.endswith(".opus"):
            continue
        filepath = os.path.join(REVIEW, filename)
        try:
            f = OggOpus(filepath)
            artist = (f.get("artist") or [None])[0]
            title = (f.get("title") or [None])[0]
            album = (f.get("album") or [None])[0]
            duration = f.info.length if f.info else None
            
            # Lê as tags de review injetadas
            reason = (f.get("review_reason") or [None])[0]
            expected_mbid = (f.get("expected_mbid") or [None])[0]
            expected_tracknum = (f.get("expected_tracknum") or [None])[0]
            expected_album = (f.get("expected_album") or [None])[0]
            expected_artist = (f.get("expected_artist") or [None])[0]
        except Exception:
            artist = title = album = duration = reason = expected_mbid = expected_tracknum = expected_album = expected_artist = None
            
        size_bytes = os.stat(filepath).st_size
        files.append(ReviewFile(
            filename=filename,
            artist=artist,
            title=title,
            album=album,
            duration=duration,
            size_bytes=size_bytes,
            review_reason=reason,
            expected_mbid=expected_mbid,
            expected_tracknum=expected_tracknum,
            expected_album=expected_album,
            expected_artist=expected_artist,
        ))
    return sorted(files, key=lambda f: f.filename)


@app.post("/review/{filename}/accept")
async def accept_review(filename: str, user: dict = Depends(require_telegram_user)):
    src = os.path.join(REVIEW, filename)
    if not os.path.exists(src):
        raise HTTPException(status_code=404, detail="File not found")
        
    try:
        f = OggOpus(src)
        
        # Lê as tags esperadas (do MusicBrainz que você clicou)
        expected_mbid = (f.get("expected_mbid") or [None])[0]
        expected_tracknum = (f.get("expected_tracknum") or [None])[0]
        expected_album = (f.get("expected_album") or [None])[0]
        
        # Lê os metadados ATUAIS (do Soulseek - devem ser mantidos)
        current_artist = (f.get("artist") or [""])[0]
        current_title = (f.get("title") or [""])[0]
        current_album = (f.get("album") or [""])[0]
        
        if not expected_mbid:
            raise Exception("No expected_mbid found in file tags")
        
        # ESTRATÉGIA: Manter metadados do Soulseek, sobrescrever apenas IDs e números
        f["musicbrainz_albumid"] = expected_mbid  # Força o ID do álbum correto
        
        # Sobrescreve tracknumber apenas se temos um valor válido esperado
        if expected_tracknum and str(expected_tracknum).isdigit():
            f["tracknumber"] = str(int(expected_tracknum))
        
        # Sobrescreve album name APENAS se o atual estava vazio OU era realmente diferente
        # (quando nome bate mas ID difere, mantemos o nome do Soulseek)
        if not current_album and expected_album:
            f["album"] = expected_album
        
        # NÃO sobrescreve artist/title - confia no Soulseek
        # artist e title já estão corretos vindos do Soulseek
        
        # Limpa tags de review
        for k in ["review_reason", "expected_mbid", "expected_tracknum", "expected_album", "expected_artist"]:
            if k in f: del f[k]
        f.save()
        
        logging.info(f"[review] Accepted {filename}: mbid={expected_mbid}, artist={current_artist}, title={current_title}")
        
        # Importa para o beets
        from library import run_beet_import
        # Passa contexto com o mbid correto para evitar re-validação
        skipped, _ = run_beet_import(src, current_artist, {"release_id": expected_mbid})
        if skipped:
            raise Exception("Beets import skipped the file")
        
        # IMPORTANTE: Atualiza status do job se houver um job ativo para este álbum
        # Isso previne que o worker faça fallback para YouTube achando que falhou
        if expected_tracknum:
            with _jobs_lock:
                for job_id, job in _jobs.items():
                    if job.release_id == expected_mbid and job.status in ("running", "processing"):
                        for track in job.tracks:
                            if track.title == current_title and track.position == int(expected_tracknum):
                                if track.status == "failed":
                                    logging.info(f"[review] Updated job {job_id} track {track.position} status: failed → done")
                                    track.status = "done"
                                break
                        break
            
        return {"ok": True}
    except Exception as e:
        logging.error(f"[review] Accept failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/review/{filename}/delete")
async def delete_review(filename: str, user: dict = Depends(require_telegram_user)):
    src = os.path.join(REVIEW, filename)
    if not os.path.exists(src):
        raise HTTPException(status_code=404, detail="File not found")
    os.remove(src)
    return {"ok": True}


_stream_tokens = {} # {token: (filename, expiry)}

@app.get("/review/stream-token")
async def get_stream_token(user: dict = Depends(require_telegram_user)):
    import secrets
    import time
    token = secrets.token_urlsafe(32)
    _stream_tokens[token] = time.time() + 60 # Expira em 1 minuto
    return {"token": token}

@app.get("/review/{filename}/stream")
async def stream_review(filename: str, token: str):
    import time
    if _stream_tokens.get(token, 0) < time.time():
        raise HTTPException(status_code=403, detail="Invalid or expired token")
        
    from starlette.responses import FileResponse
    path = os.path.join(REVIEW, filename)
    if not os.path.exists(path):
        raise HTTPException(status_code=404)
    return FileResponse(path, media_type="audio/ogg")


@app.get("/library/search", response_model=list[SearchResult])
async def search_library(
    q: str,
    user: dict = Depends(require_telegram_user),
):
    if len(q) < 2:
        raise HTTPException(status_code=400, detail="Query must be at least 2 characters")
    try:
        items = list(_beets_lib.items(q))[:50]
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid query: {e}")
    return [
        SearchResult(
            artist=i.artist,
            title=i.title,
            album=i.album,
            path=i.path.decode(),
            track=i.track or None,
            year=i.year or None,
        )
        for i in items
    ]
