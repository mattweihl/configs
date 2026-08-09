#!/bin/sh
# Claude Code status line. Renders inside the Claude pane.
#
# This is not the tmux status bar -- tmux-powerline owns that, and the window
# name carries the ●/◍/✦ glyph from tmux/claude-status.sh. The two answer
# different questions: the glyph says which pane wants you, this says what the
# agent in front of you is running on.
#
# Claude Code passes session JSON on stdin. Fields used here are documented at
# https://code.claude.com/docs/en/statusline
#
#   Opus·high  configs  main*  [████░░░░░░] 38%  $0.42

command -v jq >/dev/null 2>&1 || { echo "statusline: jq not found"; exit 0; }

payload="$(cat)"

# used_percentage is a `number | null`, not an integer -- it arrives fractional.
# Floor it in jq: the shell arithmetic and `[ -ge ]` tests below are integer-only
# and abort the whole script on "38.7".
eval "$(printf '%s' "$payload" | jq -r '
  @sh "model=\(.model.display_name // "?")
       effort=\(.effort.level // "")
       dir=\(.workspace.current_dir // .cwd // "")
       worktree=\(.workspace.git_worktree // "")
       pct=\(.context_window.used_percentage // 0 | floor)
       cost=\(.cost.total_cost_usd // 0)"
')"

dim='\033[2m'; reset='\033[0m'
cyan='\033[36m'; green='\033[32m'; yellow='\033[33m'; red='\033[31m'

# Context bar. The number that matters is how much room is left, so colour it
# by remaining headroom rather than printing a bare percentage.
filled=$(( (pct + 5) / 10 ))
[ "$filled" -gt 10 ] && filled=10
[ "$filled" -lt 0 ] && filled=0

bar=''
i=0
while [ "$i" -lt 10 ]; do
  if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
  i=$((i + 1))
done

if   [ "$pct" -ge 85 ]; then ctx_color="$red"
elif [ "$pct" -ge 60 ]; then ctx_color="$yellow"
else                         ctx_color="$green"
fi

# Git: branch plus a single `*` for dirty. Anything more is noise at this size,
# and lazygit is a keystroke away.
#
# --no-optional-locks because this runs on every status line repaint: without it
# `git status` takes the index lock and races the editor you are typing in.
branch=''
if [ -n "$dir" ] && [ -d "$dir" ]; then
  branch="$(git --no-optional-locks -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [ -n "$branch" ] && [ -n "$(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null | head -1)" ]; then
    branch="${branch}*"
  fi
fi

label="$model"
[ -n "$effort" ] && label="${model}·${effort}"

# In a worktree the directory basename is the sanitized branch name, which is
# long and already shown by the branch field. Prefer the worktree name.
name="$(basename "${dir:-?}")"
[ -n "$worktree" ] && name="$worktree"

printf "${cyan}%s${reset}  %s" "$label" "$name"
[ -n "$branch" ] && printf "  ${dim}%s${reset}" "$branch"
printf "  ${ctx_color}[%s]${reset} %s%%" "$bar" "$pct"
printf "  ${dim}\$%.2f${reset}\n" "$cost"
