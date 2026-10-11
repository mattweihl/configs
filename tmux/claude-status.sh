#!/bin/sh
# Reflects Claude Code's state onto the tmux pane that is running it.
# Called by Claude Code hooks in ~/.claude/settings.json.
#
# Usage: claude-status.sh busy|wait|idle|failed
#
#   busy    agent is working
#   wait    agent needs your input
#   idle    agent is done or at rest
#   failed  turn ended with an error
#
# State is stored per *pane* (-p), not per window. A window can hold two agents,
# and with a window-scoped option whichever one goes idle first wipes the other's
# state. The claude_waiting powerline segment reads this state.

command -v tmux >/dev/null 2>&1 || exit 0
tmux has-session 2>/dev/null || exit 0

# tmux sets TMUX_PANE in every pane, and Claude Code plus the hook processes it
# spawns inherit it. If it is absent we are not running inside a pane (e.g. a
# background session), and there is no pane whose state is ours to change.
# Don't try to recover the pane by walking the process tree: for a background
# session that climbs into the *parent* agent's pane and marks a window that
# isn't ours.
[ -n "${TMUX_PANE:-}" ] || exit 0

# Always write the state, including "idle" -- never unset it. tmux resolves
# options pane -> window -> session -> global, so unsetting would fall through
# to whatever an outer scope happens to hold and could pin the glyph on a stale
# value. Writing every state keeps the pane authoritative about itself.
case "$1" in
  busy|wait|idle|failed)
    tmux set-option -p -t "$TMUX_PANE" @claude_state "$1" 2>/dev/null
    ;;
  *)
    printf 'claude-status: unknown state "%s" (want busy|wait|idle|failed)\n' "$1" >&2
    exit 2
    ;;
esac

# Powerline owns the status format, so force a redraw after changing the state.
tmux refresh-client -S 2>/dev/null

exit 0
