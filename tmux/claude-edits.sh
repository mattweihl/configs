#!/bin/sh
# Picks from the files Claude edited in this pane and opens one in nvim.
#
# Bound to `<prefix> e` in tmux.conf. Runs inside a display-popup, and nvim
# runs there too: this is a peek at what the agent changed, not a workspace.
# Close the popup to return to the agent, untouched and un-resized.
#
# Usage: claude-edits.sh <pane-id>
#
# The list is appended by claude/hooks/format-edits.sh on every Edit/Write and
# cleared per pane by the SessionStart hook in claude/settings.json. Reading it
# per pane is the point: `git status` shows one worktree's changes, whoever
# made them, while this shows one agent's.

set -u

pane="${1:-}"
[ -n "$pane" ] || { echo 'claude-edits: no pane id given'; sleep 2; exit 1; }

list="$HOME/.cache/claude-edits/$pane"

# The popup closes the instant this exits, so a message needs to hold the
# window open long enough to be read.
if [ ! -s "$list" ]; then
  echo 'No edits recorded for this pane yet.'
  sleep 2
  exit 0
fi

# Newest first, one row per file. `tac` is GNU-only and this has to work on a
# stock macOS, so reverse in awk: walk the lines backwards and keep the first
# sighting of each path, which is its most recent edit.
selection="$(
  awk '{ line[NR] = $0 }
       END { for (i = NR; i > 0; i--) if (!seen[line[i]]++) print line[i] }' "$list" |
    fzf --prompt='edited > ' \
      --height=100% \
      --preview 'git diff --color=always -- {} 2>/dev/null | head -200'
)" || exit 0

[ -n "$selection" ] || exit 0

exec nvim "$selection"
