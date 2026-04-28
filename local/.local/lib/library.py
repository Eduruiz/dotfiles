#!/usr/bin/env python3
import os
import re
import json
import subprocess
import logging
import threading
import requests
import unicodedata
import base64
import musicbrainzngs
from mutagen.oggopus import OggOpus
from mutagen.flac import Picture
from beets import config as beets_config
from beets.library import Library as BeetsLibrary

TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
LASTFM_API_KEY = os.environ["LASTFM_API_KEY"]
ACOUSTID_API_KEY = os.environ["ACOUSTID_API_KEY"]

DOWNLOADS = os.environ.get("MUSIC_DOWNLOADS_DIR", "/srv/navidrome/downloads")
REVIEW = os.environ.get("MUSIC_REVIEW_DIR", f"{DOWNLOADS}/review")
ALLOWED_USERS = set(map(int, os.environ.get("TELEGRAM_ALLOWED_USERS", "").split(","))) if os.environ.get("TELEGRAM_ALLOWED_USERS") else set()
LISTENBRAINZ_USER = "duruiz"
RELEASE_PRIORITY = {"Album": 0, "Single": 1, "EP": 2}

os.makedirs(REVIEW, exist_ok=True)
musicbrainzngs.set_useragent("musicbot", "1.0", "contact@musicbot.local")

beets_config.read()
_beets_lib = BeetsLibrary(
    beets_config["library"].as_filename(),
    beets_config["directory"].as_filename(),
)

# Serializes tag_track + _beet_move to avoid concurrent SQLite writes
_import_lock = threading.Lock()


def sanitize(s: str) -> str:
    return re.sub(r"[/\\]", "_", s).replace("..", "_")


def _normalize(s: str) -> str:
    return unicodedata.normalize('NFD', s).encode('ascii', 'ignore').decode().lower()


def _title_variants(title: str) -> list[str]:
    """Return title and versions stripped of feat./parenthetical/slash suffixes.

    Only strips if there's actual content before the suffix — titles that
    start with ( or [ (e.g. '(!!!)') are left as-is.
    """
    variants = [title]
    short = re.split(r'\s+[\(\[]|\s+feat\.|\s+/\s+', title, maxsplit=1)[0].strip()
    if short and short != title:
        variants.append(short)
    return variants


def _artist_items(artist: str) -> list:
    seen = set()
    items = []
    for query in [f'artist:"{artist}"', f'albumartist:"{artist}"']:
        for item in _beets_lib.items(query):
            if item.id not in seen:
                seen.add(item.id)
                items.append(item)
    return items


def already_in_library(artist: str, title: str, mb_albumid: str | None = None) -> bool:
    if mb_albumid:
        # Se temos o ID do álbum, a verificação deve ser rigorosa: artista + título + álbum
        for t in _title_variants(title):
            query = f'mb_albumid:"{mb_albumid}" title:"{t}"'
            if list(_beets_lib.items(query)):
                return True
        return False

    # Fallback para busca genérica se não houver album_id
    for t in _title_variants(title):
        for query in [
            f'title:"{t}" artist:"{artist}"',
            f'title:"{t}" albumartist:"{artist}"',
        ]:
            if list(_beets_lib.items(query)):
                return True
    norm_variants = {_normalize(t) for t in _title_variants(title)}
    return any(_normalize(i.title) in norm_variants for i in _artist_items(artist))


def beet_path(artist: str, title: str) -> str | None:
    for t in _title_variants(title):
        for query in [
            f'title:"{t}" artist:"{artist}"',
            f'title:"{t}" albumartist:"{artist}"',
        ]:
            results = list(_beets_lib.items(query))
            if results:
                return results[0].path.decode()
    norm_variants = {_normalize(t) for t in _title_variants(title)}
    for item in _artist_items(artist):
        if _normalize(item.title) in norm_variants:
            return item.path.decode()
    return None


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


def _pick_best_rg_release(releasegroups: list[dict]) -> tuple[dict, dict]:
    """Pick the best (releasegroup, release) pair from AcoustID data.

    Prefers Album > EP > Single > Compilation, earliest date within each tier.
    If studio albums exist, compilations are excluded entirely.
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

    best_rank = candidates[0][0]
    compilation_rank = TYPE_ORDER["Compilation"]
    if best_rank < compilation_rank:
        candidates = [c for c in candidates if c[0] < compilation_rank]

    _, _, best_rg, best_rel = candidates[0]
    return best_rg, best_rel


def acoustid_lookup(filepath: str) -> dict | None:
    """Fingerprint a file and query AcoustID like Picard does."""
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

    rg_best, rel_best = _pick_best_rg_release(best_recording.get("releasegroups", []))
    if not rel_best:
        logging.info("[acoustid] No suitable release found")
        return None

    mb_albumid = rel_best.get("id")
    album_title = rg_best.get("title", "")

    mb_releasetrackid = None
    tracknumber = None
    try:
        release = musicbrainzngs.get_release_by_id(mb_albumid, includes=["recordings"])
        title_match_track = None
        for medium in release["release"].get("medium-list", []):
            for track in medium.get("track-list", []):
                if track["recording"]["id"] == mb_trackid:
                    mb_releasetrackid = track["id"]
                    tracknumber = int(track["position"])
                    break
                if (title_match_track is None and
                        track["recording"]["title"].lower() == rec_title.lower()):
                    title_match_track = track
            if mb_releasetrackid:
                break
        if not mb_releasetrackid and title_match_track:
            logging.info("[acoustid] recording ID mismatch, matched by title instead")
            mb_releasetrackid = title_match_track["id"]
            tracknumber = int(title_match_track["position"])
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


def tag_track(filepath: str, mb_context: dict | None = None) -> str | None:
    """Write tags and validate against context. Returns mb_albumid if valid match, else None."""
    try:
        f = OggOpus(filepath)
    except Exception as e:
        logging.error(f"[tag] Failed to open {filepath}: {e}")
        return None

    # 1. Coletar o que já existe (Soulseek tags)
    artist = (f.get("artist") or [""])[0]
    title = (f.get("title") or [""])[0]
    album = (f.get("album") or [""])[0]
    albumid = (f.get("musicbrainz_albumid") or [None])[0]
    tracknum = (f.get("tracknumber") or [None])[0]

    # 2. Fallback para AcoustID se faltar info essencial
    if not artist or not title:
        match = acoustid_lookup(filepath)
        if match and match.get("score", 0) > 0.7:
            artist = artist or match.get("artist")
            title = title or match.get("title")
            album = album or match.get("album")
            albumid = albumid or match.get("mb_albumid")
            tracknum = tracknum or (str(match["tracknumber"]) if match.get("tracknumber") else None)
            logging.info(f"[tag] AcoustID identified: {artist} - {title} (Score: {match['score']})")

    # 3. Validação contra o Contexto do Bot
    if mb_context and mb_context.get("release_id"):
        expected_id = mb_context["release_id"]
        expected_pos = str(mb_context.get("position", ""))
        expected_album = mb_context.get("album", "")
        
        # Se chegamos aqui sem ARTISTA ou TÍTULO identificados (nem tag, nem AcoustID), 
        # não podemos confiar que o arquivo é o que o bot espera.
        if not artist or not title:
            logging.warning(f"[tag] IDENTIFICATION FAILURE: No tags or AcoustID match for {filepath}. Sending to review.")
            return None
        
        # Validação de conflitos
        reason = None
        
        # Validar albumid se presente
        if albumid and albumid != expected_id:
            if album.lower() == expected_album.lower():
                reason = f"ID do Álbum diferente, mas nome bate ('{album}')"
            else:
                reason = f"Conflito de Álbum: esperado '{expected_album}', encontrado '{album}'"
        
        # Validar tracknumber se presente - com proteção contra valores inválidos
        if tracknum and expected_pos and expected_pos != "None":
            try:
                track_int = int(str(tracknum).strip() or "0")
                expected_int = int(str(expected_pos).strip() or "0")
                if track_int > 0 and expected_int > 0 and track_int != expected_int:
                    reason = f"Conflito de Faixa: esperada {expected_pos}, encontrada {tracknum}"
            except (ValueError, TypeError):
                logging.warning(f"[tag] Invalid tracknumber format: tracknum={tracknum!r}, expected={expected_pos!r}")
        
        # Se há conflito, enviar para review
        if reason:
            logging.warning(f"[tag] REVIEW REQUIRED: {reason} for {filepath}")
            f["review_reason"] = reason
            if expected_id: f["expected_mbid"] = expected_id
            if expected_pos and expected_pos != "None": f["expected_tracknum"] = expected_pos
            if expected_album: f["expected_album"] = expected_album
            if mb_context.get("artist"): f["expected_artist"] = mb_context["artist"]
            f.save()
            return None
        
        # Tudo certo: Forçamos as tags do álbum solicitado
        f["musicbrainz_albumid"] = expected_id
        if expected_pos and expected_pos != "None":
            f["tracknumber"] = expected_pos
        f["artist"] = mb_context.get("artist") or artist
        f["album"] = expected_album or album
        f["title"] = mb_context.get("title") or title
        f.save()
        return expected_id

    # Sem contexto (download avulso), salvamos o que encontramos
    if artist and title:
        f["artist"] = artist
        f["title"] = title
        f["album"] = album
        if albumid: f["musicbrainz_albumid"] = albumid
        if tracknum: f["tracknumber"] = tracknum
        f.save()
        return albumid

    return None


def embed_cover_art(mb_albumid: str, filepaths: list[str]):
    """Fetch cover art from Cover Art Archive and embed it in all given opus files."""
    try:
        resp = requests.get(
            f"https://coverartarchive.org/release/{mb_albumid}/front",
            timeout=15, allow_redirects=True
        )
        if not resp.ok or not resp.content:
            try:
                rg = musicbrainzngs.get_release_by_id(mb_albumid, includes=["release-groups"])
                rg_id = rg["release"].get("release-group", {}).get("id")
                if rg_id:
                    resp = requests.get(
                        f"https://coverartarchive.org/release-group/{rg_id}/front",
                        timeout=15, allow_redirects=True
                    )
            except Exception:
                pass
        if not resp.ok or not resp.content:
            logging.warning(f"[art] no cover found for {mb_albumid}")
            return
        pic = Picture()
        pic.type = 3
        pic.mime = resp.headers.get("Content-Type", "image/jpeg").split(";")[0]
        pic.data = resp.content
        encoded = base64.b64encode(pic.write()).decode("ascii")
        for fp in filepaths:
            try:
                f = OggOpus(fp)
                f["metadata_block_picture"] = [encoded]
                f.save()
            except Exception as e:
                logging.warning(f"[art] failed to embed in {fp}: {e}")
        logging.info(f"[art] embedded cover for {mb_albumid} in {len(filepaths)} file(s)")
    except Exception as e:
        logging.warning(f"[art] cover fetch failed for {mb_albumid}: {e}")


def _beet_move(filepath: str):
    """Importa o arquivo usando a API do Beets de forma não bloqueante e estável."""
    from beets.library import Item
    try:
        # Cria o item no banco de dados do Beets
        item = Item.from_path(filepath.encode())
        item.add(lib=_beets_lib)
        # Move o arquivo para a estrutura configurada no beets
        # Note: item.move() sem parâmetros faz um move (não copy) por padrão
        item.move()
        item.store()
        logging.info(f"[beet] Successfully imported {filepath} via API")
    except Exception as e:
        logging.error(f"[beet] Failed to import {filepath} via API: {e}")
        # Se falhar na API, fallback para mover manualmente para o review
        dest = f"{REVIEW}/{os.path.basename(filepath)}"
        if os.path.exists(filepath):
            os.rename(filepath, dest)


def run_beet_import(filepath: str, artist: str = "", mb_context: dict | None = None) -> tuple[list[str], str | None]:
    """Tag then move a single downloaded file. Returns (skipped_list, mb_albumid)."""
    with _import_lock:
        mb_albumid = tag_track(filepath, mb_context)
        
        # Se houve falha na identificação ou conflito (retornou None mas tinha contexto)
        if mb_context and not mb_albumid:
            dest = f"{REVIEW}/{os.path.basename(filepath)}"
            logging.info(f"[import] Mismatch or identification failure, moving to review: {dest}")
            os.rename(filepath, dest)
            subprocess.run(["find", DOWNLOADS, "-maxdepth", "1", "-type", "f", "!", "-path", f"{REVIEW}/*", "-delete"])
            return [os.path.basename(filepath)], None

        # Move o arquivo para a biblioteca usando Beets
        _beet_move(filepath)

    skipped = []
    if os.path.exists(f"{REVIEW}/{os.path.basename(filepath)}"):
        skipped.append(os.path.basename(filepath))

    # Limpa lixo residual do diretório de downloads
    subprocess.run(["find", DOWNLOADS, "-maxdepth", "1", "-type", "f", "!", "-path", f"{REVIEW}/*", "-delete"])
    return skipped, mb_albumid


def download_track(artist: str, title: str, album: str = "", candidate: int = 1) -> str | None:
    """Download a track and write basic tags. Returns the file path or None."""
    safe_artist = sanitize(artist)
    safe_title = sanitize(title)
    outfile = f"{DOWNLOADS}/{safe_artist} - {safe_title}.opus"

    search_title = re.sub(r"[^\w\s]", " ", title).strip() or re.sub(r"[^\w\s]", " ", album).strip() or title

    subprocess.run([
        "yt-dlp",
        "--extract-audio", "--audio-format", "opus", "--audio-quality", "192K",
        "--match-filter", "!is_live & duration < 1800",
        "--output", outfile,
        "--no-playlist",
        f"ytsearch{candidate}:{artist} {search_title} audio",
        "--playlist-items", str(candidate),
    ], capture_output=True)

    opus_files = [f for f in os.listdir(DOWNLOADS)
                  if f.endswith(".opus") and not f.startswith(".")]
    if not opus_files:
        return None

    subprocess.run(["find", DOWNLOADS, "-maxdepth", "1", "-type", "f",
                    "!", "-path", f"{REVIEW}/*", "!", "-name", "*.opus", "-delete"])

    actual = f"{DOWNLOADS}/{opus_files[0]}"
    if actual != outfile:
        os.rename(actual, outfile)

    f = OggOpus(outfile)
    f["artist"] = artist
    f["title"] = title
    f["discnumber"] = "1"
    f["disctotal"] = "1"
    f.save()
    return outfile


def _release_group_id(release_id: str) -> str | None:
    try:
        r = musicbrainzngs.get_release_by_id(release_id, includes=["release-groups"])
        return r["release"].get("release-group", {}).get("id")
    except Exception:
        return None


def download_track_for_album(artist: str, title: str, album: str,
                              release_id: str) -> tuple[str | None, bool]:
    """Download the best matching candidate for a specific album release.

    Tries up to 3 yt-dlp candidates. Returns (filepath, confirmed).
    """
    expected_rg = _release_group_id(release_id)
    logging.info(f"[download] expected release group: {expected_rg}")

    for candidate in range(1, 4):
        filepath = download_track(artist, title, album, candidate)
        if not filepath:
            continue
        match = acoustid_lookup(filepath)
        if match and match.get("mb_albumid"):
            candidate_rg = _release_group_id(match["mb_albumid"])
            if expected_rg and candidate_rg == expected_rg:
                logging.info(f"[download] candidate {candidate} confirmed (rg={candidate_rg})")
                return filepath, True
        logging.info(f"[download] candidate {candidate} not matched, trying next")
        os.remove(filepath)

    logging.warning(f"[download] no candidate matched release group for '{title}', using first")
    filepath = download_track(artist, title, album, candidate=1)
    return filepath, False


def save_playlist_m3u(name: str, paths: list[str]):
    safe_name = sanitize(name)
    m3u_path = os.path.join(beet_path(), f"{safe_name}.m3u")
    with open(m3u_path, "w", encoding="utf-8") as f:
        f.write("#EXTM3U\n")
        for p in paths:
            f.write(p + "\n")


def fetch_fresh_releases(only_albums: bool = False) -> list[dict]:
    resp = requests.get(
        f"https://api.listenbrainz.org/1/user/{LISTENBRAINZ_USER}/fresh_releases",
        timeout=15,
    )
    if not resp.ok:
        return []
    releases = resp.json().get("payload", {}).get("releases", [])
    if only_albums:
        releases = [r for r in releases if r.get("release_group_primary_type") in ("Album", "EP")]
    releases.sort(key=lambda r: -r.get("confidence", 0))
    return releases
