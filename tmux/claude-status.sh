#!/bin/sh
# Sets tmux window marker color based on Claude Code event.
# Called by Claude Code hooks in ~/.claude/settings.json.
# Usage: claude-status.sh <event>

[ -z "$TMUX" ] && exit 0

case "$1" in
  thinking)
    # Claude is working — amber
    tmux set-option -w window-status-current-style "bg=#b57614,fg=black" ;;
  attention)
    # Needs your input (permission, question) — orange
    tmux set-option -w window-status-current-style "bg=#af3a03,fg=white" ;;
  clear)
    # Done — reset to default
    tmux set-option -w window-status-current-style "bg=white,fg=black" ;;
esac
