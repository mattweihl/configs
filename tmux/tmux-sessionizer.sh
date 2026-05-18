#!/usr/bin/env bash
# tmux-sessionizer: fuzzy-find projects/worktrees and create-or-attach a session
#
# For regular git repos under SEARCH_ROOT, the repo directory is listed.
# For bare git repos under SEARCH_ROOT, each worktree is listed individually.

set -euo pipefail

SEARCH_ROOT="$HOME/code"

if [[ -r "$HOME/configs/zsh/worktree.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/configs/zsh/worktree.sh"
fi

collect_targets() {
  for dir in "$SEARCH_ROOT"/*/; do
    [[ -d "$dir" ]] || continue
    dir="${dir%/}"

    if git -C "$dir" rev-parse --is-bare-repository &>/dev/null; then
      local is_bare
      is_bare=$(git -C "$dir" rev-parse --is-bare-repository 2>/dev/null)
      if [[ "$is_bare" == "true" ]]; then
        # List each worktree path (skip the bare repo root itself)
        git -C "$dir" worktree list --porcelain \
          | awk '/^worktree / { path=$2 }
                 /^bare$/     { bare=1 }
                 /^$/         { if (!bare) print path; bare=0; path="" }
                 END          { if (path && !bare) print path }'
        continue
      fi
    fi

    echo "$dir"
  done
}

selected=$(collect_targets | fzf --prompt="session> " --height=40% --reverse)

[[ -z "$selected" ]] && exit 0

base=$(basename "$selected")
if declare -F wt_session_name_from_path >/dev/null 2>&1; then
  session_name=$(wt_session_name_from_path "$selected")
else
  common_dir=$(git -C "$selected" rev-parse --git-common-dir 2>/dev/null || true)
  git_dir=$(git -C "$selected" rev-parse --git-dir 2>/dev/null || true)
  if [[ -n "$common_dir" && -n "$git_dir" && "$common_dir" != "$git_dir" ]]; then
    session_name=$(echo "${base}__$(basename "$(dirname "$selected")")" | tr './' '__')
  else
    session_name=$(echo "$base" | tr './' '__')
  fi
fi

if ! tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux new-session -ds "$session_name" -c "$selected"
fi

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "=$session_name"
else
  tmux attach-session -t "=$session_name"
fi
