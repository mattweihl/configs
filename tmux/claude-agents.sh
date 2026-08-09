#!/bin/sh
# Lists every Claude Code agent -- pane-bound or not -- and jumps to the one you
# pick. Bound to <prefix> a in tmux.conf (opens in a popup).
#
# Two sources, because an agent is not always a pane:
#
#   panes       Which panes count as Claude, and how a state reads, are defined
#               once in tmux.conf as @_claude_pane / @_claude_label /
#               @_claude_title. This script evaluates those formats instead of
#               re-implementing them, so the picker can never drift from what
#               the window names show. That includes the column padding:
#               #{p10:} / #{p20:} pad by display width, which printf cannot do
#               once a glyph or a `…` is in the string.
#
#   background  `claude agents --json` reports sessions the daemon owns. These
#               have no pane, so `list-panes` cannot see them and the
#               window-name glyph cannot represent them. They were invisible
#               here until this script asked for them separately -- which is
#               how a background session ends up feeling lost: it is running,
#               `claude --resume` refuses it *because* it is still running, and
#               nothing in tmux pointed at it.
#
# The two sources overlap: attaching to a background agent from a pane puts a
# Claude client in that pane, so the same session is both. They also disagree --
# a background session's hooks get no $TMUX_PANE, claude-status.sh never runs
# for it, and @claude_state stays frozen at whatever the pane last held.
#
# Rather than merge two disagreeing rows at display time, this script repairs
# the disagreement at the source: it writes the daemon's live state onto the
# pane with `set-option -p @claude_state` before listing panes. tmux then
# renders that row like any other, and the *window-name glyph* -- which was
# telling the same lie -- becomes correct too. The state is only as fresh as the
# last time you opened this picker, which is still better than never.
#
# Rows that survive with no pane are detached. Those print the daemon's own
# state verbatim (`working`, `done`, `failed`, ...) rather than being squeezed
# into the pane vocabulary. A daemon agent really can be `failed`, and there is
# no glyph for that; collapsing it to `idle` would hide the one row you need.
#
# Picking a pane switches to it. Picking a detached background agent opens the
# agent view in a new window, filtered to that agent's directory, because no CLI
# flag attaches to one background session directly.

set -e

tab="$(printf '\t')"

# tmux formats treat `#` as an escape introducer, so any text interpolated into
# one has to double it or a name containing `#` truncates the row.
tmux_literal() {
  printf '%s' "$1" | sed 's/#/##/g'
}

# --- background agents -------------------------------------------------------

# jq is already required by claude/statusline.sh. Without it the picker degrades
# to panes only rather than failing outright.
#
# Prefer .state (the daemon's job lifecycle: working / done / failed) over
# .status (idle / busy), and pass whatever comes back through untouched. A
# state this script has not seen before should read as itself; mapping the
# unknown onto a default is how `failed` ends up looking like `idle`.
background=''
if command -v claude >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  background="$(claude agents --json 2>/dev/null | jq -r --arg tab "$tab" '
    # Interactive sessions are already on screen as panes.
    map(select(.kind == "background"))
    | .[]
    | [ (.name // .id // "?"),
        (.cwd // ""),
        (.state // .status // "unknown")
      ] | join($tab)
  ' 2>/dev/null || true)"
fi

pane_titles="$(tmux list-panes -a -f '#{E:@_claude_pane}' \
  -F "#{pane_id}${tab}#{E:@_claude_title}" 2>/dev/null || true)"

# Finds the pane hosting a named agent. tmux carries the name as the pane title.
pane_for_agent() {
  printf '%s\n' "$pane_titles" \
    | awk -F"$tab" -v want="$1" '$2 == want { print $1; exit }'
}

# Renders a detached row. tmux has no pane to render it from, so hand it the
# text and let it pad anyway -- same widths, same display-width arithmetic as
# the pane rows, which printf cannot reproduce once a `…` is in the string.
detached_row() {
  # detached_row <name> <cwd> <state>
  tmux display-message -p "#{p10:#{l:$(tmux_literal "$3")}} #{p20:#{=/19/…:#{l:$(tmux_literal "$1")}}} [bg] $(tmux_literal "$(basename "${2:-?}")")"
}

# Squeezes a daemon state into the three values @claude_state can hold.
pane_state_for() {
  case "$1" in
    working|running|busy)                        printf 'busy\n' ;;
    waiting|blocked|requires_action|needs_input) printf 'wait\n' ;;
    *)                                           printf 'idle\n' ;;
  esac
}

# Pushes live state onto panes, then prints a row for every agent left without
# one. Kept as a function because a comment inside a command substitution is a
# parsing hazard -- an apostrophe or a paren in one can end the substitution.
reconcile_background() {
  printf '%s\n' "$background" | while IFS="$tab" read -r name cwd state; do
    [ -n "$name" ] || continue

    pane="$(pane_for_agent "$name")"
    if [ -n "$pane" ]; then
      tmux set-option -p -t "$pane" @claude_state "$(pane_state_for "$state")" \
        2>/dev/null || true
      continue
    fi

    printf 'bg\t%s\t%s\n' "$cwd" "$(detached_row "$name" "$cwd" "$state")"
  done
}

detached="$(reconcile_background)"

# --- panes -------------------------------------------------------------------

# Listed *after* the write-back above, so merged rows show the live state.
# Field 1 is the row kind, field 2 the jump target -- a pane id rather than a
# "session:window.pane" string, which is ambiguous if a session name has a dot.
# Truncate the session name to 19 so the `…` lands inside the 20-cell column.
panes="$(tmux list-panes -a -f '#{E:@_claude_pane}' \
  -F "pane${tab}#{pane_id}${tab}#{p10:#{E:@_claude_label}} #{p20:#{=/19/…:#{session_name}}} #{E:@_claude_title}" \
  2>/dev/null || true)"

agents="$(printf '%s\n%s\n' "$panes" "$detached" | grep -v '^[[:space:]]*$' || true)"

if [ -z "$agents" ]; then
  echo "No Claude Code agents found, in tmux or in the background."
  printf 'Press any key to close...'
  read -r _ 2>/dev/null || true
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  choice="$(printf '%s\n' "$agents" | fzf --with-nth=3.. --delimiter="$tab" \
    --prompt='claude > ' --height=100% --reverse --no-multi)" || exit 0
else
  choice="$(printf '%s\n' "$agents" | head -1)"
fi

[ -z "$choice" ] && exit 0

kind="$(printf '%s' "$choice" | cut -f1)"
target="$(printf '%s' "$choice" | cut -f2)"

case "$kind" in
  pane)
    tmux switch-client -t "$target"
    tmux select-window -t "$target"
    tmux select-pane -t "$target"
    ;;
  bg)
    # --cwd narrows the agent view to agents started under this directory, so
    # the one you picked is the one in front of you. Pass it as a separate
    # argv entry: quoting it into the command string breaks on an apostrophe.
    tmux new-window -n agents -c "$target" claude agents --cwd "$target"
    ;;
esac
