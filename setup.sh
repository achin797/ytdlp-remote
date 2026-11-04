#!/usr/bin/env bash
# Run on YOUR machine. Needs: gh (logged in), yt-dlp, git.
# Usage: ./setup.sh [browser]   browser = firefox|chrome|brave|edge (default firefox)
set -euo pipefail
BROWSER="${1:-firefox}"
REPO="ytdlp-remote"

echo "== Exporting YouTube cookies from $BROWSER =="
echo "Tip: log in to YouTube in a private window first, export, then close it (don't log out)."
yt-dlp --cookies-from-browser "$BROWSER" --cookies all-cookies.txt \
  --skip-download -q "https://www.youtube.com/watch?v=dQw4w9WgXcQ" || true

# Keep only YouTube/Google cookies (keeps the secret small)
{ echo "# Netscape HTTP Cookie File"; grep -E '(youtube\.com|google\.com)' all-cookies.txt || true; } > cookies.txt
rm -f all-cookies.txt
grep -q youtube cookies.txt || { echo "No YouTube cookies found. Log in to YouTube in $BROWSER."; exit 1; }

echo "== Creating private repo =="
gh repo view "$REPO" >/dev/null 2>&1 || gh repo create "$REPO" --private --source . --push
git push -u origin main 2>/dev/null || true

echo "== Uploading cookies as secret =="
base64 < cookies.txt | tr -d '\n' | gh secret set YT_COOKIES --repo "$(gh api user --jq .login)/$REPO"
rm -f cookies.txt

echo "Done. Download with:  ./dl.sh <url> [extra yt-dlp args]"
