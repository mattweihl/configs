#!/usr/bin/env bash

# Shared worktree helpers used by both shell commands and tmux scripts.
# Keep this file shell-compatible (bash + zsh) so tmux-sessionizer can source it.

_wt_sanitize_name() {
  local value="$1"
  value="${value//\//__}"
  value="${value//./_}"
  value="${value//:/_}"
  value="${value// /_}"
  printf '%s\n' "$value"
}

wt_branch_to_dir() {
  local branch="$1"
  _wt_sanitize_name "$branch"
}

wt_session_name_from_path() {
  local input_path="$1"
  local abs_path
  abs_path="$(cd "$input_path" 2>/dev/null && pwd -P)" || return 1

  local base_name parent_name common_dir git_dir
  base_name="$(basename "$abs_path")"
  parent_name="$(basename "$(dirname "$abs_path")")"
  common_dir="$(git -C "$abs_path" rev-parse --git-common-dir 2>/dev/null || true)"
  git_dir="$(git -C "$abs_path" rev-parse --git-dir 2>/dev/null || true)"

  if [[ -n "$common_dir" && -n "$git_dir" && "$common_dir" != "$git_dir" ]]; then
    _wt_sanitize_name "${base_name}__${parent_name}"
    return 0
  fi

  _wt_sanitize_name "$base_name"
}

wt_enter_tmux_session_for_path() {
  local worktree_path="$1"
  local session_name
  session_name="$(wt_session_name_from_path "$worktree_path")" || return 1

  if ! command -v tmux >/dev/null 2>&1; then
    echo "error: tmux is not installed or not on PATH" >&2
    return 1
  fi

  if [[ -n "${TMUX:-}" ]]; then
    if ! tmux has-session -t "=$session_name" 2>/dev/null; then
      tmux new-session -ds "$session_name" -c "$worktree_path"
    fi
    tmux switch-client -t "=$session_name"
  else
    tmux new-session -A -s "$session_name" -c "$worktree_path"
  fi
}

_wt_find_worktree_for_branch() {
  local repo_root="$1"
  local branch="$2"

  git -C "$repo_root" worktree list --porcelain \
    | awk -v wanted_branch="refs/heads/$branch" '
        /^worktree / { path=$2 }
        /^branch /   { if ($2 == wanted_branch) { print path; exit } }
      '
}

_wt_resolve_base_ref() {
  local repo_root="$1"
  local base_branch="$2"
  local base_remote_ref="refs/remotes/origin/$base_branch"
  local base_local_ref="refs/heads/$base_branch"

  if git -C "$repo_root" show-ref --verify --quiet "$base_remote_ref"; then
    printf 'origin/%s\n' "$base_branch"
    return 0
  fi

  if git -C "$repo_root" show-ref --verify --quiet "$base_local_ref"; then
    printf '%s\n' "$base_branch"
    return 0
  fi

  return 1
}

_wt_ensure_branch_tracks_origin() {
  local repo_path="$1"
  local branch="$2"
  local remote_ref="origin/$branch"

  if [[ -z "$repo_path" || -z "$branch" ]]; then
    return 1
  fi

  if ! git -C "$repo_path" show-ref --verify --quiet "refs/remotes/$remote_ref"; then
    return 0
  fi

  git -C "$repo_path" branch --set-upstream-to "$remote_ref" "$branch" >/dev/null 2>&1 || true
}

wt_ensure_worktree() {
  local repo_root="$1"
  local branch="$2"
  local base_branch="${3:-main}"

  WT_LAST_WORKTREE_CREATED=0
  WT_LAST_WORKTREE_PATH=""

  if [[ -z "$repo_root" || -z "$branch" ]]; then
    echo "usage: wt_ensure_worktree <repo-root> <branch> [base-branch]" >&2
    return 1
  fi

  repo_root="$(cd "$repo_root" 2>/dev/null && pwd -P)" || {
    echo "error: repo root '$repo_root' does not exist" >&2
    return 1
  }

  if ! git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: '$repo_root' is not a git repository" >&2
    return 1
  fi

  if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
    git -C "$repo_root" fetch origin --prune
  fi

  git -C "$repo_root" worktree prune

  local existing_worktree
  existing_worktree="$(_wt_find_worktree_for_branch "$repo_root" "$branch")"
  if [[ -n "$existing_worktree" ]]; then
    _wt_ensure_branch_tracks_origin "$existing_worktree" "$branch"
    WT_LAST_WORKTREE_PATH="$existing_worktree"
    WT_LAST_WORKTREE_CREATED=0
    printf '%s\n' "$existing_worktree"
    return 0
  fi

  local target_dir target_path
  target_dir="$(wt_branch_to_dir "$branch")"
  target_path="$repo_root/$target_dir"

  if [[ -e "$target_path" ]]; then
    echo "error: target path already exists: $target_path" >&2
    return 1
  fi

  local remote_branch_ref="refs/remotes/origin/$branch"
  local local_branch_ref="refs/heads/$branch"

  if git -C "$repo_root" show-ref --verify --quiet "$local_branch_ref" \
     && git -C "$repo_root" show-ref --verify --quiet "$remote_branch_ref"; then
    if [[ -z "$(_wt_find_worktree_for_branch "$repo_root" "$branch")" ]]; then
      if git -C "$repo_root" merge-base --is-ancestor "$local_branch_ref" "origin/$branch" 2>/dev/null; then
        git -C "$repo_root" branch -f "$branch" "origin/$branch"
      else
        echo "warning: local '$branch' has diverged from origin, using local as-is" >&2
      fi
    fi
  fi

  if git -C "$repo_root" show-ref --verify --quiet "$local_branch_ref"; then
    git -C "$repo_root" worktree add "$target_path" "$branch"
    _wt_ensure_branch_tracks_origin "$target_path" "$branch"
  elif git -C "$repo_root" show-ref --verify --quiet "$remote_branch_ref"; then
    git -C "$repo_root" worktree add --track -b "$branch" "$target_path" "origin/$branch"
    _wt_ensure_branch_tracks_origin "$target_path" "$branch"
  else
    local base_ref
    base_ref="$(_wt_resolve_base_ref "$repo_root" "$base_branch")" || {
      echo "error: base branch '$base_branch' not found locally or on origin" >&2
      return 1
    }

    git -C "$repo_root" worktree add -b "$branch" "$target_path" "$base_ref"
    # When base_ref is a remote-tracking branch (for example origin/develop),
    # Git can auto-configure the new branch's upstream to that base branch.
    # Clear it so first push sets upstream to origin/<new-branch> instead.
    git -C "$target_path" branch --unset-upstream >/dev/null 2>&1 || true
  fi

  WT_LAST_WORKTREE_PATH="$target_path"
  WT_LAST_WORKTREE_CREATED=1

  if typeset -f wt_post_create_hook >/dev/null 2>&1; then
    wt_post_create_hook "$target_path" "$branch" "$base_branch"
  fi

  printf '%s\n' "$target_path"
}

wt_remove_worktree() {
  local repo_root="$1"
  local worktree_name="$2"
  shift 2 || true

  local keep_session=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --keep-session|--no-kill-session)
        keep_session=1
        ;;
      *)
        echo "error: unknown option '$1'" >&2
        return 1
        ;;
    esac
    shift
  done

  if [[ -z "$repo_root" || -z "$worktree_name" ]]; then
    echo "usage: wt_remove_worktree <repo-root> <worktree-name-or-path> [--keep-session]" >&2
    return 1
  fi

  repo_root="$(cd "$repo_root" 2>/dev/null && pwd -P)" || {
    echo "error: repo root '$repo_root' does not exist" >&2
    return 1
  }

  local worktree_path
  if [[ "$worktree_name" == /* ]]; then
    worktree_path="$worktree_name"
  else
    worktree_path="$repo_root/$worktree_name"
  fi

  worktree_path="$(cd "$worktree_path" 2>/dev/null && pwd -P)" || {
    echo "error: worktree path '$worktree_name' not found" >&2
    return 1
  }

  local session_name=""
  if [[ "$keep_session" -eq 0 ]]; then
    session_name="$(wt_session_name_from_path "$worktree_path" 2>/dev/null || true)"
  fi

  local wt_branch
  wt_branch="$(git -C "$repo_root" worktree list --porcelain \
    | awk -v wt="$worktree_path" '
        /^worktree / { path=$2 }
        /^branch /   { if (path == wt) { sub("refs/heads/", "", $2); print $2; exit } }
      ')"

  git -C "$repo_root" worktree remove "$worktree_path"

  if [[ -n "$wt_branch" ]]; then
    if ! git -C "$repo_root" branch -d "$wt_branch" 2>/dev/null; then
      echo "warning: branch '$wt_branch' has unmerged changes." >&2
      printf "Force delete branch '%s'? [y/N] " "$wt_branch"
      read -r confirm
      if [[ "$confirm" == [yY] ]]; then
        git -C "$repo_root" branch -D "$wt_branch"
      else
        echo "Kept branch '$wt_branch'."
      fi
    fi
  fi

  if [[ "$keep_session" -eq 0 && -n "$session_name" ]] && command -v tmux >/dev/null 2>&1; then
    if tmux has-session -t "=$session_name" 2>/dev/null; then
      tmux kill-session -t "=$session_name"
      echo "Killed tmux session '$session_name'."
    fi
  fi
}
