#!/usr/bin/env python3
import os
import re
import json
import time
import subprocess
import logging
import requests
import pyotp
from mutagen.oggopus import OggOpus
from telegram import Update
from telegram.ext import (
    Application, CommandHandler, MessageHandler, ConversationHandler,
    filters, ContextTypes
)
import musicbrainzngs

TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
DOWNLOADS = "/srv/navidrome/downloads"
REVIEW = "/srv/navidrome/downloads/review"
ALLOWED_USERS = {54647261}
os.makedirs(REVIEW, exist_ok=True)

logging.basicConfig(level=logging.INFO)
musicbrainzngs.set_useragent("musicbot", "1.0", "contact@musicbot.local")

CHOOSING = 1
CONFIRMING_ALBUM = 2
CONFIRMING_PLAYLIST = 3
WAITING_MUSICA_ARTIST = 4
WAITING_MUSICA_TITLE = 5
WAITING_ALBUM_ARTIST = 6
WAITING_ALBUM_TITLE = 7

RELEASE_PRIORITY = {"Album": 0, "Single": 1, "EP": 2}
LASTFM_API_KEY = os.environ["LASTFM_API_KEY"]
ACOUSTID_API_KEY = os.environ["ACOUSTID_API_KEY"]

_SP_TOTP_SECRET = os.environ["SP_TOTP_SECRET"]
_SP_TOTP_VERSION = 61
_SP_GQL_HASH = "bb67e0af06e8d6f52b531f97468ee4acd44cd0f82b988e15c2ea47b1148efc77"


def lastfm_top_tracks(artist: str, limit: int = 10) -> list[dict]:
    resp = requests.get("https://ws.audioscrobbler.com/2.0/", params={
        "method": "artist.getTopTracks",
        "artist": artist,
        "api_key": LASTFM_API_KEY,
        "format": "json",
        "limit": limit,
    }, timeout=10)
    if not resp.ok:
        return []
    tracks = resp.json().get("toptracks", {}).get("track", [])
    return [{"artist": t["artist"]["name"], "title": t["name"], "album": ""} for t in tracks]


def lastfm_top_albums(artist: str, limit: int = 10) -> list[dict]:
    resp = requests.get("https://ws.audioscrobbler.com/2.0/", params={
        "method": "artist.getTopAlbums",
        "artist": artist,
        "api_key": LASTFM_API_KEY,
        "format": "json",
        "limit": limit,
    }, timeout=10)
    if not resp.ok:
        return []
    albums = resp.json().get("topalbums", {}).get("album", [])
    return [{"artist": a["artist"]["name"], "title": a["name"]} for a in albums]


def acoustid_lookup(filepath: str) -> dict | None:
    """Fingerprint a file and query AcoustID like Picard does.

    Returns dict with mb_albumid, mb_trackid, tracknumber, artist, album, title
    or None if no confident match found.
    """
    try:
        proc = subprocess.run(
            ["fpcalc", "-json", "-length", "120", filepath],
            capture_output=True, text=True, timeout=30
        )
        if proc.returncode != 0:
            return None
        fp_data = json.loads(proc.stdout)
    except Exception as e:
        logging.warning(f"[acoustid] fpcalc failed: {e}")
        return None

    fingerprint = fp_data.get("fingerprint")
    duration = fp_data.get("duration")
    if not fingerprint or not duration:
        return None

    try:
        resp = requests.post(
            "https://api.acoustid.org/v2/lookup",
            data={
                "client": ACOUSTID_API_KEY,
                "meta": "recordings releasegroups releases tracks compress sources",
                "fingerprint": fingerprint,
                "duration": int(duration),
            },
            timeout=15,
        )
        if not resp.ok:
            return None
        data = resp.json()
    except Exception as e:
        logging.warning(f"[acoustid] lookup failed: {e}")
        return None

    results = data.get("results", [])
    if not results:
        return None

    # Pick highest score result
    best_result = max(results, key=lambda r: r.get("score", 0.0))
    best_acoustid_score = best_result.get("score", 0.0)
    recordings = best_result.get("recordings", [])

    if not recordings or best_acoustid_score < 0.75:
        logging.info(f"[acoustid] No confident match (score={best_acoustid_score:.2f})")
        return None

    best_recording = recordings[0]
    logging.info(f"[acoustid] Match score={best_acoustid_score:.2f} id={best_recording.get('id')}")

    mb_trackid = best_recording.get("id")
    rec_title = best_recording.get("title", "")
    rec_artists = best_recording.get("artists", [])
    rec_artist = rec_artists[0].get("name", "") if rec_artists else ""

    # AcoustID response nests releases inside releasegroups
    # Structure: recording.releasegroups[].{id, title, type, releases[]}
    rg_best, rel_best = _pick_best_rg_release(best_recording.get("releasegroups", []))
    if not rel_best:
        logging.info("[acoustid] No suitable release found")
        return None

    mb_albumid = rel_best.get("id")
    album_title = rg_best.get("title", "")

    # Cross-reference with MusicBrainz to get the mb_releasetrackid and tracknumber.
    # The recording ID from AcoustID is not the same as mb_releasetrackid.
    mb_releasetrackid = None
    tracknumber = None
    try:
        release = musicbrainzngs.get_release_by_id(mb_albumid, includes=["recordings"])
        for medium in release["release"].get("medium-list", []):
            for track in medium.get("track-list", []):
                if track["recording"]["id"] == mb_trackid:
                    mb_releasetrackid = track["id"]
                    tracknumber = int(track["position"])
                    break
            if mb_releasetrackid:
                break
    except Exception as e:
        logging.warning(f"[acoustid] MB release lookup failed: {e}")

    return {
        "mb_albumid": mb_albumid,
        "mb_trackid": mb_releasetrackid or mb_trackid,
        "tracknumber": tracknumber,
        "artist": rec_artist,
        "album": album_title,
        "title": rec_title,
        "score": best_acoustid_score,
    }


def _pick_best_rg_release(releasegroups: list[dict]) -> tuple[dict, dict]:
    """Pick the best (releasegroup, release) pair from AcoustID data.

    Prefers Album > EP > Single, earliest date.
    Returns (rg, release) or ({}, {}) if nothing suitable found.
    """
    TYPE_ORDER = {"Album": 0, "EP": 1, "Single": 2, "Compilation": 3}

    candidates = []
    for rg in releasegroups:
        rg_type = rg.get("type", "")
        type_rank = TYPE_ORDER.get(rg_type, 9)
        for rel in rg.get("releases", []):
            date = rel.get("date", {})
            date_str = f"{date.get('year', 9999):04d}-{date.get('month', 99):02d}-{date.get('day', 99):02d}"
            candidates.append((type_rank, date_str, rg, rel))

    if not candidates:
        return {}, {}

    candidates.sort(key=lambda x: (x[0], x[1]))
    _, _, best_rg, best_rel = candidates[0]
    return best_rg, best_rel


def auth(update: Update) -> bool:
    return update.effective_user.id in ALLOWED_USERS


def best_release(r: dict) -> dict:
    releases = r.get("release-list", [])
    official = [
        rel for rel in releases
        if rel.get("status") == "Official"
        and rel.get("release-group", {}).get("primary-type") in RELEASE_PRIORITY
    ]
    official.sort(key=lambda x: (
        RELEASE_PRIORITY.get(x.get("release-group", {}).get("primary-type", ""), 9),
        x.get("date", "9999")
    ))
    return official[0] if official else (releases[0] if releases else {})


def recording_sort_key(r: dict) -> tuple:
    rel = best_release(r)
    ptype = rel.get("release-group", {}).get("primary-type", "")
    status = rel.get("status", "")
    score = RELEASE_PRIORITY.get(ptype, 9) if status == "Official" else 9
    return (score, rel.get("date", "9999"))


def import_track(filepath: str, artist: str = "") -> bool:
    """Try AcoustID-assisted import. Falls back to standard beet import.

    Returns True if imported successfully, False if sent to review.
    """
    match = acoustid_lookup(filepath)

    if match and match.get("mb_albumid"):
        logging.info(f"[import] AcoustID match: {match['artist']} - {match['title']} "
                     f"album={match['album']} score={match['score']:.2f}")
        f = OggOpus(filepath)
        f["musicbrainz_albumid"] = match["mb_albumid"]
        f["musicbrainz_trackid"] = match["mb_trackid"]
        if match.get("tracknumber"):
            f["tracknumber"] = str(match["tracknumber"])
        if match.get("album"):
            f["album"] = match["album"]
        if match.get("title"):
            f["title"] = match["title"]
        if match.get("artist"):
            f["artist"] = match["artist"]
        f.save()

        # --singletons: import as individual track, no album completeness check
        # --noautotag: trust the tags we just wrote (mb_albumid, mb_trackid, album, title)
        subprocess.run(
            ["beet", "import", "--quiet", "--singletons", "--noautotag", filepath],
            capture_output=True, text=True
        )
        if os.path.exists(filepath):
            os.rename(filepath, f"{REVIEW}/{os.path.basename(filepath)}")
            return False
        return True

    # Fallback: standard beet import
    subprocess.run(
        ["beet", "import", "--quiet", os.path.dirname(filepath)],
        capture_output=True, text=True
    )
    if os.path.exists(filepath):
        os.rename(filepath, f"{REVIEW}/{os.path.basename(filepath)}")
        return False
    return True


def run_beet_import(filepath: str, artist: str = "") -> list[str]:
    """Import a single downloaded file. Returns list of skipped filenames."""
    skipped = []
    ok = import_track(filepath, artist)
    if not ok:
        skipped.append(os.path.basename(filepath))

    subprocess.run(["find", DOWNLOADS, "-type", "f", "!", "-path", f"{REVIEW}/*",
                    "!", "-name", "*.opus", "-delete"])

    query = f"artist:{artist}" if artist else ""
    subprocess.run(["beet", "fetchart"] + ([query] if query else []), capture_output=True)
    subprocess.run(
        ["beet", "embedart"] + ([query] if query else []),
        input="y\n", text=True, capture_output=True
    )
    return skipped


def sanitize(s: str) -> str:
    return re.sub(r"[/\\]", "_", s).replace("..", "_")


def download_track(artist: str, title: str, album: str = "") -> str | None:
    """Download a track and write basic tags. Returns the file path or None."""
    safe_artist = sanitize(artist)
    safe_title = sanitize(title)
    outfile = f"{DOWNLOADS}/{safe_artist} - {safe_title}.opus"

    search_title = re.sub(r"[^\w\s]", " ", title).strip() or re.sub(r"[^\w\s]", " ", album).strip() or title

    subprocess.run([
        "yt-dlp",
        "--extract-audio", "--audio-format", "opus", "--audio-quality", "192K",
        "--match-filter", "!is_live & duration < 600",
        "--output", outfile,
        "--no-playlist",
        f"ytsearch3:{artist} {search_title} audio"
    ], capture_output=True)

    opus_files = [f for f in os.listdir(DOWNLOADS) if f.endswith(".opus")]
    if not opus_files:
        return None

    subprocess.run(["find", DOWNLOADS, "-type", "f", "!", "-name", "*.opus", "-delete"])

    actual = f"{DOWNLOADS}/{opus_files[0]}"
    if actual != outfile:
        os.rename(actual, outfile)

    f = OggOpus(outfile)
    f["artist"] = artist
    f["title"] = title
    f.save()
    return outfile


def already_in_library(artist: str, title: str) -> bool:
    result = subprocess.run(
        ["beet", "ls", f"artist:{artist}"],
        capture_output=True, text=True
    ).stdout
    return title.lower() in result.lower()


def beet_path(artist: str, title: str) -> str | None:
    result = subprocess.run(
        ["beet", "ls", "-p", f"artist:{artist}", f"title:{title}"],
        capture_output=True, text=True
    ).stdout.strip()
    # pick the first matching path
    for line in result.splitlines():
        if line.strip():
            return line.strip()
    return None


def save_playlist_m3u(name: str, paths: list[str]):
    safe_name = sanitize(name)
    m3u_path = f"/srv/navidrome/music/{safe_name}.m3u"
    with open(m3u_path, "w", encoding="utf-8") as f:
        f.write("#EXTM3U\n")
        for p in paths:
            f.write(p + "\n")


def spotify_token() -> str | None:
    try:
        totp = pyotp.TOTP(_SP_TOTP_SECRET)
        code = totp.now()
        resp = requests.get(
            "https://open.spotify.com/api/token",
            params={
                "reason": "init",
                "productType": "web-player",
                "totp": code,
                "totpVer": str(_SP_TOTP_VERSION),
                "totpServer": code,
            },
            headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"},
            timeout=10,
        )
        if resp.ok:
            return resp.json().get("accessToken")
    except Exception as e:
        logging.warning(f"[Spotify] token failed: {e}")
    return None


def spotify_playlist_tracks(url: str) -> tuple[list[dict], str]:
    match = re.search(r"playlist/([A-Za-z0-9]+)", url)
    if not match:
        return [], "Playlist"
    playlist_id = match.group(1)

    token = spotify_token()
    if not token:
        return [], "Playlist"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "App-Platform": "WebPlayer",
        "Spotify-App-Version": "1.0.0",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    }

    tracks = []
    offset = 0
    playlist_name = "Playlist"

    while True:
        payload = {
            "variables": {
                "uri": f"spotify:playlist:{playlist_id}",
                "offset": offset,
                "limit": 100,
                "enableWatchFeedEntrypoint": False,
            },
            "operationName": "fetchPlaylist",
            "extensions": {
                "persistedQuery": {"version": 1, "sha256Hash": _SP_GQL_HASH}
            },
        }

        resp = requests.post(
            "https://api-partner.spotify.com/pathfinder/v2/query",
            headers=headers,
            json=payload,
            timeout=15,
        )
        if not resp.ok:
            break

        data = resp.json()
        playlist_data = data.get("data", {}).get("playlistV2", {})

        if offset == 0:
            playlist_name = playlist_data.get("name", "Playlist") or "Playlist"

        content = playlist_data.get("content", {})
        items = content.get("items", [])
        if not items:
            break

        for item in items:
            v2 = item.get("itemV2", {}).get("data", {})
            uri = v2.get("uri", "")
            if not uri.startswith("spotify:track:"):
                continue
            title = v2.get("name") or "Unknown"
            artists = [
                a.get("profile", {}).get("name")
                for a in v2.get("artists", {}).get("items", [])
                if a.get("profile", {}).get("name")
            ]
            artist = artists[0] if artists else "Unknown"
            album = v2.get("albumOfTrack", {}).get("name") or ""
            tracks.append({"artist": artist, "title": title, "album": album})

        if not content.get("pagingInfo", {}).get("nextOffset"):
            break
        offset += 100
        time.sleep(0.1)

    return tracks, playlist_name


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return
    await update.message.reply_text(
        "Comandos disponíveis:\n\n"
        "🎵 /musica Artista - Título\n"
        "💿 /album Artista - Nome do Álbum\n"
        "🎧 /playlist URL do Spotify\n"
        "🔗 /youtube URL"
    )


async def handle_musica(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return
    text = " ".join(context.args)
    if not text:
        await update.message.reply_text("Qual artista?")
        return WAITING_MUSICA_ARTIST
    if " - " not in text:
        await update.message.reply_text("Formato: Artista - Título")
        return WAITING_MUSICA_ARTIST

    artist, title = text.split(" - ", 1)
    await update.message.reply_text(f"🔍 Buscando {artist} - {title}...")

    try:
        result = musicbrainzngs.search_recordings(artist=artist, recording=title, limit=10)
        recordings = sorted(result.get("recording-list", []), key=recording_sort_key)[:5]
        if not recordings:
            await update.message.reply_text("❌ Não encontrei no MusicBrainz.")
            return ConversationHandler.END

        lines = []
        results = []
        for i, r in enumerate(recordings, 1):
            rtitle = r.get("title", "?")
            rartist = r.get("artist-credit-phrase", artist)
            rel = best_release(r)
            ralbum = rel.get("title", "?")
            rdate = rel.get("date", "")[:4]
            info = f"{ralbum}, {rdate}" if rdate else ralbum
            lines.append(f"{i}. {rartist} - {rtitle} ({info})")
            results.append({"artist": rartist, "title": rtitle, "album": ralbum})

        context.user_data["pending"] = {"type": "track", "results": results}
        await update.message.reply_text("\n".join(lines) + "\n\nQual número? (0 para cancelar)")
        return CHOOSING

    except Exception as e:
        await update.message.reply_text(f"❌ Erro: {e}")
        return ConversationHandler.END


async def handle_album(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return
    text = " ".join(context.args)
    if not text:
        await update.message.reply_text("Qual artista?")
        return WAITING_ALBUM_ARTIST
    if " - " not in text:
        await update.message.reply_text("Formato: Artista - Nome do Álbum")
        return WAITING_ALBUM_ARTIST

    artist, album = text.split(" - ", 1)
    await update.message.reply_text(f"🔍 Buscando {album}...")

    try:
        result = musicbrainzngs.search_releases(artist=artist, release=album, limit=5)
        releases = result.get("release-list", [])
        if not releases:
            await update.message.reply_text("❌ Álbum não encontrado.")
            return

        lines = []
        for i, r in enumerate(releases, 1):
            rtitle = r.get("title", "?")
            rdate = r.get("date", "")[:4]
            rformat = r.get("medium-list", [{}])[0].get("format", "?") if r.get("medium-list") else "?"
            info = f"{rformat}, {rdate}" if rdate else rformat
            lines.append(f"{i}. {artist} - {rtitle} ({info})")

        context.user_data["pending"] = {
            "type": "album",
            "artist": artist,
            "results": [{"release_id": r["id"], "title": r.get("title", "?")} for r in releases]
        }
        context.user_data["pending_lines"] = lines
        await update.message.reply_text("\n".join(lines) + "\n\nQual número? (0 para cancelar)")
        return CHOOSING

    except Exception as e:
        await update.message.reply_text(f"❌ Erro: {e}")


async def waiting_musica_artist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END
    context.user_data["musica_artist"] = update.message.text.strip()
    await update.message.reply_text("Qual música? (. para ver as mais tocadas do artista)")
    return WAITING_MUSICA_TITLE


async def waiting_musica_title(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END
    artist = context.user_data.pop("musica_artist", "")
    title = update.message.text.strip()

    if title == ".":
        await update.message.reply_text(f"🔍 Buscando top músicas de {artist}...")
        tracks = lastfm_top_tracks(artist)
        if not tracks:
            await update.message.reply_text("❌ Artista não encontrado no Last.fm.")
            return ConversationHandler.END
        lines = []
        for i, t in enumerate(tracks, 1):
            lines.append(f"{i}. {t['artist']} - {t['title']}")
        context.user_data["pending"] = {"type": "track", "results": tracks}
        await update.message.reply_text("\n".join(lines) + "\n\nQual número? (0 para cancelar)")
        return CHOOSING

    context.args = f"{artist} - {title}".split()
    return await handle_musica(update, context)


async def waiting_album_artist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END
    context.user_data["album_artist"] = update.message.text.strip()
    await update.message.reply_text("Qual álbum? (. para ver os mais populares do artista)")
    return WAITING_ALBUM_TITLE


async def waiting_album_title(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END
    artist = context.user_data.pop("album_artist", "")
    title = update.message.text.strip()

    if title == ".":
        await update.message.reply_text(f"🔍 Buscando álbuns de {artist}...")
        albums = lastfm_top_albums(artist)
        if not albums:
            await update.message.reply_text("❌ Artista não encontrado no Last.fm.")
            return ConversationHandler.END
        lines = []
        results = []
        for i, a in enumerate(albums, 1):
            lines.append(f"{i}. {a['artist']} - {a['title']}")
            results.append({"release_id": None, "title": a["title"], "artist": a["artist"]})
        context.user_data["pending"] = {"type": "album", "artist": artist, "results": results}
        context.user_data["pending_lines"] = lines
        await update.message.reply_text("\n".join(lines) + "\n\nQual número? (0 para cancelar)")
        return CHOOSING

    context.args = f"{artist} - {title}".split()
    return await handle_album(update, context)


async def handle_playlist(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return
    args = context.args
    if not args or "spotify.com/playlist" not in args[0]:
        await update.message.reply_text("Formato: /playlist https://open.spotify.com/playlist/...")
        return

    url = args[0]
    msg = await update.message.reply_text("🔍 Buscando playlist no Spotify...")

    try:
        tracks, playlist_name = spotify_playlist_tracks(url)

        if not tracks:
            await msg.edit_text("❌ Não consegui buscar a playlist. Verifique a URL.")
            return

        context.user_data["pending_playlist"] = {
            "name": playlist_name,
            "tracks": tracks,
        }

        lines = [f"🎧 *{playlist_name}* - {len(tracks)} faixas:\n"]
        for i, t in enumerate(tracks, 1):
            lines.append(f"{i}. {t['artist']} - {t['title']}")
        lines.append("\nConfirma o download? (sim/não)")

        full_text = "\n".join(lines)
        chunks = [full_text[i:i+4096] for i in range(0, len(full_text), 4096)]
        await msg.edit_text(chunks[0], parse_mode="Markdown")
        for chunk in chunks[1:]:
            await update.message.reply_text(chunk, parse_mode="Markdown")
        return CONFIRMING_PLAYLIST

    except Exception as e:
        await msg.edit_text(f"❌ Erro: {e}")


async def handle_playlist_confirm(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END

    text = update.message.text.strip().lower()
    pending = context.user_data.pop("pending_playlist", None)

    if not pending or text not in ("sim", "não", "nao", "s", "n"):
        await update.message.reply_text("Responde sim ou não.")
        return CONFIRMING_PLAYLIST

    if text in ("não", "nao", "n"):
        await update.message.reply_text("Cancelado.")
        return ConversationHandler.END

    tracks = pending["tracks"]
    playlist_name = pending["name"]
    total = len(tracks)
    failed = []
    playlist_paths = []

    await update.message.reply_text(f"⬇️ Baixando *{playlist_name}* ({total} faixas)...", parse_mode="Markdown")

    for i, track in enumerate(tracks, 1):
        artist, title, album = track["artist"], track["title"], track["album"]
        if already_in_library(artist, title):
            await update.message.reply_text(f"⏭️ [{i}/{total}] {artist} - {title} (já existe)")
        else:
            await update.message.reply_text(f"⬇️ [{i}/{total}] {artist} - {title}")
            filepath = download_track(artist, title, album)
            if not filepath:
                failed.append(f"{artist} - {title}")
                continue
            skipped = run_beet_import(filepath, artist)
            if skipped:
                failed.append(f"{artist} - {title} (review)")
        path = beet_path(artist, title)
        if path:
            playlist_paths.append(path)

    if playlist_paths:
        save_playlist_m3u(playlist_name, playlist_paths)

    msg = f"✅ *{playlist_name}* concluída!"
    if failed:
        msg += f"\n❌ Falhas ({len(failed)}): {', '.join(failed[:5])}"
        if len(failed) > 5:
            msg += f" e mais {len(failed) - 5}"
    await update.message.reply_text(msg, parse_mode="Markdown")
    return ConversationHandler.END


async def handle_youtube(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return
    args = context.args
    if not args:
        await update.message.reply_text("Formato: /youtube URL")
        return

    url = args[0]
    msg = await update.message.reply_text("⬇️ Baixando...")
    subprocess.run([
        "yt-dlp",
        "--extract-audio", "--audio-format", "opus", "--audio-quality", "192K",
        "--embed-metadata",
        "--parse-metadata", "title:(?P<artist>.+?) - (?P<title>.+)",
        "--output", f"{DOWNLOADS}/%(artist)s - %(title)s.%(ext)s",
        url
    ], capture_output=True)
    subprocess.run(["find", DOWNLOADS, "-type", "f", "!", "-name", "*.opus", "-delete"])
    await msg.edit_text("📚 Importando para a biblioteca...")
    opus_files = [f"{DOWNLOADS}/{f}" for f in os.listdir(DOWNLOADS) if f.endswith(".opus")]
    for fp in opus_files:
        import_track(fp)
    subprocess.run(["find", DOWNLOADS, "-type", "f", "!", "-path", f"{REVIEW}/*", "-delete"])
    subprocess.run(["beet", "fetchart"], capture_output=True)
    subprocess.run(["beet", "embedart"], input="y\n", text=True, capture_output=True)
    await msg.edit_text("✅ Feito!")


async def handle_choice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END

    text = update.message.text.strip()
    if not text.isdigit():
        await update.message.reply_text("Manda só o número.")
        return CHOOSING

    n = int(text)
    if n == 0:
        await update.message.reply_text("Cancelado.")
        context.user_data.pop("pending", None)
        return ConversationHandler.END

    pending = context.user_data.get("pending")
    if not pending or n > len(pending["results"]):
        await update.message.reply_text("Número inválido.")
        return ConversationHandler.END

    chosen = pending["results"][n - 1]

    if pending["type"] == "track":
        context.user_data.pop("pending", None)

    if pending["type"] == "track":
        artist, title, album = chosen["artist"], chosen["title"], chosen["album"]
        if already_in_library(artist, title):
            await update.message.reply_text(f"✅ {artist} - {title} já está na biblioteca.")
            return ConversationHandler.END

        msg = await update.message.reply_text(f"⬇️ Baixando {artist} - {title}...")
        filepath = download_track(artist, title, album)
        await msg.edit_text("📚 Importando para a biblioteca...")
        if filepath:
            skipped = run_beet_import(filepath, artist)
            if skipped:
                await msg.edit_text(f"⚠️ {artist} - {title} salvo em review (sem match).")
            else:
                await msg.edit_text(f"✅ {artist} - {title} adicionado!")
        else:
            await msg.edit_text("❌ Não consegui baixar.")

    elif pending["type"] == "album":
        artist = pending["artist"]
        release_id = chosen.get("release_id")
        album_title = chosen["title"]
        try:
            if not release_id:
                result = musicbrainzngs.search_releases(artist=artist, release=album_title, limit=1)
                releases = result.get("release-list", [])
                if not releases:
                    await update.message.reply_text("❌ Álbum não encontrado no MusicBrainz.")
                    return ConversationHandler.END
                release_id = releases[0]["id"]
            release = musicbrainzngs.get_release_by_id(release_id, includes=["recordings"])
            tracks = []
            for medium in release["release"].get("medium-list", []):
                for track in medium.get("track-list", []):
                    tracks.append(track["recording"]["title"])

            lines = [f"💿 *{album_title}* - {len(tracks)} faixas:\n"]
            for i, t in enumerate(tracks, 1):
                lines.append(f"{i}. {t}")
            lines.append("\nConfirma o download? (sim/não/voltar)")

            context.user_data["pending_album"] = {
                "artist": artist,
                "album_title": album_title,
                "tracks": tracks,
            }

            await update.message.reply_text("\n".join(lines), parse_mode="Markdown")
            return CONFIRMING_ALBUM

        except Exception as e:
            await update.message.reply_text(f"❌ Erro: {e}")

    return ConversationHandler.END


async def handle_album_confirm(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not auth(update):
        return ConversationHandler.END

    text = update.message.text.strip().lower()

    if text in ("voltar", "v"):
        previous = context.user_data.get("pending")
        if previous:
            lines = context.user_data.get("pending_lines", [])
            await update.message.reply_text("\n".join(lines) + "\n\nQual número? (0 para cancelar)")
        else:
            await update.message.reply_text("Nada pra voltar.")
        return CHOOSING

    pending = context.user_data.pop("pending_album", None)

    if not pending or text not in ("sim", "não", "nao", "s", "n"):
        await update.message.reply_text("Responde sim, não ou voltar.")
        return CONFIRMING_ALBUM

    if text in ("não", "nao", "n"):
        await update.message.reply_text("Cancelado.")
        return ConversationHandler.END

    artist = pending["artist"]
    album_title = pending["album_title"]
    tracks = pending["tracks"]

    await update.message.reply_text(f"⬇️ Baixando *{album_title}*...", parse_mode="Markdown")

    failed = []
    for i, title in enumerate(tracks, 1):
        if already_in_library(artist, title):
            await update.message.reply_text(f"⏭️ [{i}/{len(tracks)}] {title} (já existe)")
            continue
        await update.message.reply_text(f"⬇️ [{i}/{len(tracks)}] {title}")
        filepath = download_track(artist, title, album_title)
        if not filepath:
            failed.append(title)
            continue
        skipped = run_beet_import(filepath, artist)
        if skipped:
            failed.append(f"{title} (review)")

    msg = f"✅ *{album_title}* baixado!"
    if failed:
        msg += f"\n⚠️ Review manual: {', '.join(failed)}"
    await update.message.reply_text(msg, parse_mode="Markdown")
    return ConversationHandler.END


async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data.pop("pending", None)
    context.user_data.pop("pending_playlist", None)
    await update.message.reply_text("Cancelado.")
    return ConversationHandler.END


def main():
    app = Application.builder().token(TOKEN).build()

    conv = ConversationHandler(
        entry_points=[
            CommandHandler("musica", handle_musica),
            CommandHandler("album", handle_album),
            CommandHandler("playlist", handle_playlist),
        ],
        states={
            WAITING_MUSICA_ARTIST: [MessageHandler(filters.TEXT & ~filters.COMMAND, waiting_musica_artist)],
            WAITING_MUSICA_TITLE: [MessageHandler(filters.TEXT & ~filters.COMMAND, waiting_musica_title)],
            WAITING_ALBUM_ARTIST: [MessageHandler(filters.TEXT & ~filters.COMMAND, waiting_album_artist)],
            WAITING_ALBUM_TITLE: [MessageHandler(filters.TEXT & ~filters.COMMAND, waiting_album_title)],
            CHOOSING: [MessageHandler(filters.TEXT & ~filters.COMMAND, handle_choice)],
            CONFIRMING_ALBUM: [MessageHandler(filters.TEXT & ~filters.COMMAND, handle_album_confirm)],
            CONFIRMING_PLAYLIST: [MessageHandler(filters.TEXT & ~filters.COMMAND, handle_playlist_confirm)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    )

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("youtube", handle_youtube))
    app.add_handler(conv)
    app.run_polling()


if __name__ == "__main__":
    main()
