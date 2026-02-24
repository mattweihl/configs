#!/usr/bin/env bash
set -euo pipefail

# Text to copy is passed from lazygit; accept all args so spaces are preserved.
text="$*"

# Case 1 & 3: running locally on macOS (with or without local tmux).
if command -v pbcopy >/dev/null 2>&1 && [ -z "${SSH_CONNECTION-}" ]; then
  printf '%s' "$text" | pbcopy
  exit 0
fi

# Cases 2 & 4: over SSH (remote host), or no pbcopy available.
# Use OSC 52 so the remote host can talk to the local terminal clipboard.

# Base64-encode without newlines (portable: works on BSD and GNU base64).
b64_text="$(printf '%s' "$text" | base64 | tr -d '\n')"

# Allow overriding the TTY if needed, default to /dev/tty.
tty_device="${LAZYGIT_TTY:-/dev/tty}"

if [ -n "${TMUX-}" ]; then
  # Inside tmux on the remote: wrap the OSC 52 sequence so tmux passes it through.
  printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$b64_text" >"$tty_device"
else
  # Not in tmux on the remote: send plain OSC 52.
  printf '\033]52;c;%s\a' "$b64_text" >"$tty_device"
fi

