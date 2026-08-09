#!/bin/sh
# Lists every pane running Claude Code across all tmux sessions and jumps to
# the one you pick. Bound to <prefix> a in tmux.conf (opens in a popup).
#
# Which panes count as Claude, and how a state reads, are defined once in
# tmux.conf as @_claude_pane / @_claude_label / @_claude_title. This script
# evaluates those formats instead of re-implementing them, so the picker can
# never drift from what the window names show.

set -e

tab="$(printf '\t')"

# Field 1 is the pane id -- an unambiguous jump target, unlike a
# "session:window.pane" string, which is ambiguous if a session name has a dot.
# Everything after the tab is display text.
agents="$(tmux list-panes -a -f '#{E:@_claude_pane}' \
  -F "#{pane_id}${tab}#{p10:#{E:@_claude_label}} #{p20:#{=/20/…:#{session_name}}} #{E:@_claude_title}")"

if [ -z "$agents" ]; then
  echo "No Claude Code panes found in any tmux session."
  printf 'Press any key to close...'
  read -r _ 2>/dev/null || true
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  choice="$(printf '%s\n' "$agents" | fzf --with-nth=2.. --delimiter="$tab" \
    --prompt='claude > ' --height=100% --reverse --no-multi)" || exit 0
else
  choice="$(printf '%s\n' "$agents" | head -1)"
fi

[ -z "$choice" ] && exit 0

pane="$(printf '%s' "$choice" | cut -f1)"
tmux switch-client -t "$pane"
tmux select-window -t "$pane"
tmux select-pane -t "$pane"
