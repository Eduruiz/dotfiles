#!/usr/bin/env python3
"""Integration tests for musicbot.py — run before committing."""
import os
import sys
import re
import glob
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")

# Load secrets from service file
service = open("/home/eduruiz/.config/systemd/user/musicbot.service").read()
for key in ("LASTFM_API_KEY", "ACOUSTID_API_KEY", "SP_TOTP_SECRET", "TELEGRAM_BOT_TOKEN"):
    m = re.search(rf"Environment={key}=(.+)", service)
    if m:
        os.environ[key] = m.group(1).strip()

sys.path.insert(0, os.path.dirname(__file__))
from musicbot import (
    acoustid_lookup, tag_track, _beet_move, embed_cover_art,
    download_track, download_track_for_album, beet_path,
    DOWNLOADS, REVIEW,
)
from mutagen.oggopus import OggOpus
import subprocess

PASS = "\033[32mPASS\033[0m"
FAIL = "\033[31mFAIL\033[0m"
results = []


def check(name: str, ok: bool, detail: str = ""):
    status = PASS if ok else FAIL
    print(f"  [{status}] {name}" + (f" — {detail}" if detail else ""))
    results.append((name, ok))


def cleanup_downloads():
    for f in glob.glob(f"{DOWNLOADS}/*.opus"):
        os.remove(f)


def beet_remove(artist: str):
    subprocess.run(["beet", "remove", f"artist:{artist}"],
                   input="y\n", text=True, capture_output=True)


# ---------------------------------------------------------------------------
print("\n==> Test 1: acoustid_lookup — known track (Tame Impala - Love/Paranoia)")
fp = download_track("Tame Impala", "Love/Paranoia", "Currents")
if fp:
    match = acoustid_lookup(fp)
    check("score >= 0.75", match is not None and match["score"] >= 0.75,
          f"score={match['score']:.2f}" if match else "no match")
    check("correct album", match and match.get("album") == "Currents",
          match.get("album") if match else "")
    check("tracknumber set", match and match.get("tracknumber") is not None,
          str(match.get("tracknumber")) if match else "")
    cleanup_downloads()
else:
    check("download failed", False)

# ---------------------------------------------------------------------------
print("\n==> Test 2: tag_track — AcoustID writes tags and albumartist")
fp = download_track("Tame Impala", "Love/Paranoia", "Currents")
if fp:
    mb_albumid = tag_track(fp)
    f = OggOpus(fp)
    check("mb_albumid returned", mb_albumid is not None)
    check("albumartist written", bool(f.get("albumartist", [""])[0]))
    check("tracknumber written", bool(f.get("tracknumber", [""])[0]))
    check("album written", bool(f.get("album", [""])[0]))
    cleanup_downloads()
else:
    check("download failed", False)

# ---------------------------------------------------------------------------
print("\n==> Test 3: full import flow — tag + beet move + cover art")
fp = download_track("Tame Impala", "Love/Paranoia", "Currents")
if fp:
    f = OggOpus(fp)
    f["artist"] = "Tame Impala"
    f["title"] = "Love/Paranoia"
    f.save()
    mb_albumid = tag_track(fp)
    _beet_move(fp)
    final = beet_path("Tame Impala", "Love/Paranoia")
    check("file moved to library", final is not None and os.path.exists(final or ""),
          final or "not found")
    if final and mb_albumid:
        embed_cover_art(mb_albumid, [final])
        f2 = OggOpus(final)
        check("cover art embedded", "metadata_block_picture" in f2)
    beet_remove("Tame Impala")
    if final and os.path.exists(final):
        os.remove(final)
    cleanup_downloads()
else:
    check("download failed", False)

# ---------------------------------------------------------------------------
print("\n==> Test 4: download_track_for_album — candidate matching (Head Hunters)")
HEAD_HUNTERS_RELEASE = "78edc505-ea7b-3212-ab93-46277bb4a66d"

fp, confirmed = download_track_for_album(
    "Herbie Hancock", "Chameleon", "Head Hunters", HEAD_HUNTERS_RELEASE
)
check("Chameleon confirmed on first try", confirmed, f"filepath={fp}")
cleanup_downloads()

fp, confirmed = download_track_for_album(
    "Herbie Hancock", "Watermelon Man", "Head Hunters", HEAD_HUNTERS_RELEASE
)
check("Watermelon Man confirmed (may need retry)", confirmed, f"filepath={fp}")
cleanup_downloads()

# ---------------------------------------------------------------------------
passed = sum(1 for _, ok in results if ok)
total = len(results)
print(f"\n==> {passed}/{total} passed")
if passed < total:
    sys.exit(1)
