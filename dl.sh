#!/usr/bin/env bash
# Usage: ./dl.sh <url> [extra yt-dlp args]
# Triggers the workflow, waits, downloads result into ./downloads
set -euo pipefail
URL="$1"; shift || true
ARGS="${*:-}"
REPO="$(gh api user --jq .login)/ytdlp-remote"

gh workflow run main.yml --repo "$REPO" -f url="$URL" -f args="$ARGS"
sleep 5
RUN_ID="$(gh run list --repo "$REPO" --workflow main.yml --limit 1 --json databaseId --jq '.[0].databaseId')"
gh run watch "$RUN_ID" --repo "$REPO" --exit-status
gh run download "$RUN_ID" --repo "$REPO" -n download -D downloads
echo "Saved to ./downloads"
