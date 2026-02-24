#!/usr/bin/env bash
set -euo pipefail

file="${1-}"

# Prefer macOS `open` when running locally (no SSH).
if command -v open >/dev/null 2>&1 && [ -z "${SSH_CONNECTION-}" ]; then
  open "$file" >/dev/null 2>&1 &
  exit 0
fi

# If we're on a remote host over SSH with no DISPLAY, don't even try to open.
if [ -n "${SSH_CONNECTION-}" ] && [ -z "${DISPLAY-}" ]; then
  # Silently succeed: avoids noisy xdg-open errors on headless servers.
  exit 0
fi

# Otherwise, fall back to xdg-open where available (Linux desktops, etc.).
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$file" >/dev/null 2>&1 &
fi

