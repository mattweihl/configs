#!/bin/sh
# Reflects Claude Code's state onto the tmux pane that is running it.
# Called by Claude Code hooks in ~/.claude/settings.json.
#
# Usage: claude-status.sh busy|wait|idle|failed
#
#   busy  agent is working            -> window name shows ●
#   wait  agent needs your input      -> window name shows ◍
#   idle  agent is done / at rest     -> window name shows ✦
#   failed turn ended with an error   -> window name shows ✕
#
# The glyph is rendered by @_claude_glyph in tmux.conf, so it lands in the
# window *name* and is therefore readable from any session's status bar.
#
# State is stored per *pane* (-p), not per window. A window can hold two agents,
# and with a window-scoped option whichever one goes idle first wipes the other's
# state. A window still has only one name, so the name shows the active pane's
# glyph; tmux/claude-agents.sh is where every pane's state is visible at once.

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

# Setting @claude_state does not dirty the window, and tmux only recomputes an
# automatic-rename name when the pane produces *output*. "wait" is precisely the
# state where the agent has gone quiet, so without a nudge that glyph would
# never appear -- the one state you most need to see would be the one that never
# repaints. Re-asserting automatic-rename to the value it already holds dirties
# the window and forces the recompute.
#
# This is not the off/on toggle that races with tmux's rename pass and can
# strand a stale name: writing `on` over `on` is idempotent. Windows reading
# "off" were renamed by hand (tmux clears the flag on rename-window) and are not
# ours to relabel.
if [ "$(tmux show-options -wqv -t "$TMUX_PANE" automatic-rename 2>/dev/null)" != "off" ]; then
  tmux set-option -w -t "$TMUX_PANE" automatic-rename on 2>/dev/null
fi

# Belt and braces: the rename above should dirty the status line on its own, but
# powerline owns the status format here, so force the redraw rather than assume.
tmux refresh-client -S 2>/dev/null

exit 0
