#!/usr/bin/env bash

# Shared worktree helpers and the cwt/rwt commands, used by both interactive
# shells and tmux scripts. Keep this file shell-compatible (bash + zsh).

# Default root for newly-created worktrees. Generic/personal usage lands here.
# Machine- or repo-specific configs (e.g. work config) can override WT_ROOT to
# point elsewhere; per-command arguments still take precedence (wt_resolve_root).
WT_DEFAULT_ROOT="${WT_DEFAULT_ROOT:-$HOME/code/worktrees}"
WT_ROOT="${WT_ROOT:-$WT_DEFAULT_ROOT}"

# Per-stage timing logs for cwt/rwt, useful for diagnosing slow git/yarn
# stages. Enabled by default; disable with WT_TIMING=0.
WT_TIMING="${WT_TIMING:-1}"

_wt_log_stage() {
  local label="$1"
  local start="$2"
  [[ "$WT_TIMING" == 0 ]] && return 0
  echo "wt: $label took $(( $(date +%s) - start ))s" >&2
}

# Resolve the worktrees root, precedence: explicit arg > $WT_ROOT > $WT_DEFAULT_ROOT.
wt_resolve_root() {
  local explicit="${1:-}"
  if [[ -n "$explicit" ]]; then
    printf '%s\n' "$explicit"
  elif [[ -n "${WT_ROOT:-}" ]]; then
    printf '%s\n' "$WT_ROOT"
  else
    printf '%s\n' "$WT_DEFAULT_ROOT"
  fi
}

# Resolve the target repo, precedence: explicit arg > $WT_REPO > current git toplevel.
wt_resolve_repo() {
  local explicit="${1:-}"
  if [[ -n "$explicit" ]]; then
    printf '%s\n' "$explicit"
  elif [[ -n "${WT_REPO:-}" ]]; then
    printf '%s\n' "$WT_REPO"
  else
    git rev-parse --show-toplevel 2>/dev/null
  fi
}

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
  local max_len="${WT_DIR_MAX_LEN:-60}"
  local sanitized
  sanitized="$(_wt_sanitize_name "$branch")"
  if [[ ${#sanitized} -gt $max_len ]]; then
    sanitized="$(printf '%.*s' "$max_len" "$sanitized")"
    sanitized="${sanitized%_}"
  fi
  printf '%s\n' "$sanitized"
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
  local base_branch="${3:-${WT_BASE_BRANCH:-main}}"
  local worktrees_dir="${4:-}"

  WT_LAST_WORKTREE_CREATED=0
  WT_LAST_WORKTREE_PATH=""

  if [[ -z "$repo_root" || -z "$branch" ]]; then
    echo "usage: wt_ensure_worktree <repo-root> <branch> [base-branch] [worktrees-dir]" >&2
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

  local stage_start
  stage_start=$(date +%s)
  if git -C "$repo_root" remote get-url origin >/dev/null 2>&1; then
    git -C "$repo_root" fetch origin --prune
  fi
  _wt_log_stage "fetch" "$stage_start"

  stage_start=$(date +%s)
  git -C "$repo_root" worktree prune
  _wt_log_stage "worktree prune" "$stage_start"

  local existing_worktree
  existing_worktree="$(_wt_find_worktree_for_branch "$repo_root" "$branch")"
  if [[ -n "$existing_worktree" ]]; then
    _wt_ensure_branch_tracks_origin "$existing_worktree" "$branch"
    WT_LAST_WORKTREE_PATH="$existing_worktree"
    WT_LAST_WORKTREE_CREATED=0
    printf '%s\n' "$existing_worktree"
    return 0
  fi

  local target_dir target_path resolved_root
  target_dir="$(wt_branch_to_dir "$branch")"
  resolved_root="$(wt_resolve_root "$worktrees_dir")"
  mkdir -p "$resolved_root"
  target_path="$resolved_root/$target_dir"

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

  stage_start=$(date +%s)
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
  _wt_log_stage "worktree add" "$stage_start"

  WT_LAST_WORKTREE_PATH="$target_path"
  WT_LAST_WORKTREE_CREATED=1

  if typeset -f wt_post_create_hook >/dev/null 2>&1; then
    stage_start=$(date +%s)
    wt_post_create_hook "$target_path" "$branch" "$base_branch"
    _wt_log_stage "post-create hook" "$stage_start"
  fi

  printf '%s\n' "$target_path"
}

wt_remove_worktree() {
  local repo_root="$1"
  local worktree_name="$2"
  shift 2 || true

  local worktrees_dir=""
  if [[ $# -gt 0 && "$1" != --* ]]; then
    worktrees_dir="$1"
    shift
  fi

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
    echo "usage: wt_remove_worktree <repo-root> <worktree-name-or-path> [worktrees-dir] [--keep-session]" >&2
    return 1
  fi

  repo_root="$(cd "$repo_root" 2>/dev/null && pwd -P)" || {
    echo "error: repo root '$repo_root' does not exist" >&2
    return 1
  }

  local resolve_dir
  resolve_dir="$(wt_resolve_root "$worktrees_dir")"
  local worktree_path
  if [[ "$worktree_name" == /* ]]; then
    worktree_path="$worktree_name"
  else
    worktree_path="$resolve_dir/$worktree_name"
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

  local stage_start
  stage_start=$(date +%s)
  git -C "$repo_root" worktree remove --force "$worktree_path"
  _wt_log_stage "worktree remove" "$stage_start"

  if [[ -n "$wt_branch" ]]; then
    stage_start=$(date +%s)
    if ! git -C "$repo_root" branch -d "$wt_branch" 2>/dev/null; then
      echo "warning: force deleting branch '$wt_branch' (unmerged)." >&2
      git -C "$repo_root" branch -D "$wt_branch"
    fi
    _wt_log_stage "branch delete" "$stage_start"
  fi

  if [[ "$keep_session" -eq 0 && -n "$session_name" ]] && command -v tmux >/dev/null 2>&1; then
    if tmux has-session -t "=$session_name" 2>/dev/null; then
      tmux kill-session -t "=$session_name"
      echo "Killed tmux session '$session_name'."
    fi
  fi
}

create-worktree() {
  local branch="" base_branch="" repo="" root=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        shift
        [[ -z "${1:-}" ]] && { echo "error: --repo requires a path" >&2; return 1; }
        repo="$1"
        ;;
      --repo=*)
        repo="${1#--repo=}"
        ;;
      --root)
        shift
        [[ -z "${1:-}" ]] && { echo "error: --root requires a path" >&2; return 1; }
        root="$1"
        ;;
      --root=*)
        root="${1#--root=}"
        ;;
      --base)
        shift
        [[ -z "${1:-}" ]] && { echo "error: --base requires a branch name" >&2; return 1; }
        base_branch="$1"
        ;;
      --base=*)
        base_branch="${1#--base=}"
        ;;
      -h|--help)
        echo "usage: create-worktree <branch> [base-branch] [--repo <path>] [--root <dir>] [--base <base-branch>]"
        return 0
        ;;
      *)
        if [[ -z "$branch" ]]; then
          branch="$1"
        elif [[ -z "$base_branch" ]]; then
          base_branch="$1"
        else
          echo "error: unexpected argument '$1'" >&2
          return 1
        fi
        ;;
    esac
    shift
  done

  if [[ -z "$branch" ]]; then
    echo "usage: create-worktree <branch> [base-branch] [--repo <path>] [--root <dir>] [--base <base-branch>]" >&2
    return 1
  fi

  local repo_root
  repo_root="$(wt_resolve_repo "$repo")"
  if [[ -z "$repo_root" ]]; then
    echo "error: could not resolve repo; pass --repo or run from inside a git repo" >&2
    return 1
  fi

  wt_ensure_worktree "$repo_root" "$branch" "$base_branch" "$root" >/dev/null || return 1

  if [[ -z "$WT_LAST_WORKTREE_PATH" ]]; then
    echo "error: failed to resolve worktree path" >&2
    return 1
  fi

  printf '%s\n' "$WT_LAST_WORKTREE_PATH"
}
alias cwt='create-worktree'

remove-worktree() {
  local -a names=()
  local repo="" root="" keep_session_flag=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        shift
        [[ -z "${1:-}" ]] && { echo "error: --repo requires a path" >&2; return 1; }
        repo="$1"
        ;;
      --repo=*)
        repo="${1#--repo=}"
        ;;
      --root)
        shift
        [[ -z "${1:-}" ]] && { echo "error: --root requires a path" >&2; return 1; }
        root="$1"
        ;;
      --root=*)
        root="${1#--root=}"
        ;;
      --keep-session|--no-kill-session)
        keep_session_flag="--keep-session"
        ;;
      -h|--help)
        echo "usage: remove-worktree <work-tree-dir> [<work-tree-dir>...] [--repo <path>] [--root <dir>] [--keep-session]"
        return 0
        ;;
      *)
        names+=("$1")
        ;;
    esac
    shift
  done

  if (( ${#names[@]} == 0 )); then
    echo "usage: remove-worktree <work-tree-dir> [<work-tree-dir>...] [--repo <path>] [--root <dir>] [--keep-session]" >&2
    return 1
  fi

  if (( ${#names[@]} == 1 )); then
    printf "Remove worktree '%s'? [y/N] " "${names[1]}"
  else
    printf "Remove %d worktrees (%s)? [y/N] " "${#names[@]}" "${(j:, :)names}"
  fi
  read -r confirm
  [[ "$confirm" != [yY] ]] && { echo "Aborted."; return 0; }

  local repo_root
  repo_root="$(wt_resolve_repo "$repo")"
  if [[ -z "$repo_root" ]]; then
    echo "error: could not resolve repo; pass --repo or run from inside a git repo" >&2
    return 1
  fi

  local name rc=0
  for name in "${names[@]}"; do
    wt_remove_worktree "$repo_root" "$name" "$root" $keep_session_flag || rc=$?
  done
  return $rc
}
alias rwt='remove-worktree'

_rwt_worktree_completion() {
  local -a candidates
  local current_path
  local common_dir

  current_path="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
  current_path="$(cd "$current_path" 2>/dev/null && pwd -P)" || return 1
  common_dir="$(git rev-parse --git-common-dir 2>/dev/null)" || return 1
  common_dir="$(cd "$common_dir" 2>/dev/null && pwd -P)" || return 1

  candidates=(
    $(
      git --git-dir "$common_dir" worktree list --porcelain 2>/dev/null \
        | awk -v current="$current_path" '
            /^worktree / {
              path=$2
              gsub(/^[ \t]+|[ \t]+$/, "", path)
              if (path != current) {
                n=split(path, parts, "/")
                print parts[n]
              }
            }
          ' \
        | sort -u
    )
  )

  (( ${#candidates[@]} == 0 )) && return 1

  local -a selected remaining
  selected=(${words[2,-1]})
  remaining=(${candidates:|selected})

  (( ${#remaining[@]} == 0 )) && return 1
  _describe 'worktree' remaining
}

_cwt_branch_completion() {
  local -a candidates
  local -a existing_branches
  local repo_root
  repo_root="$(wt_resolve_repo)" || return 1
  [[ -z "$repo_root" ]] && return 1

  existing_branches=(
    $(
      git -C "$repo_root" worktree list --porcelain 2>/dev/null \
        | awk '/^branch / { sub("refs/heads/", "", $2); print $2 }'
    )
  )

  candidates=(
    $(
      git -C "$repo_root" branch -r --format='%(refname:short)' 2>/dev/null \
        | sed 's|^origin/||' \
        | grep -v '^HEAD$' \
        | while read -r branch; do
            local skip=0
            for existing in "${existing_branches[@]}"; do
              [[ "$branch" == "$existing" ]] && skip=1 && break
            done
            (( skip == 0 )) && echo "$branch"
          done \
        | sort -u
    )
  )

  (( ${#candidates[@]} == 0 )) && return 1
  _describe 'branch' candidates
}

if typeset -f compdef >/dev/null 2>&1; then
  compdef _rwt_worktree_completion remove-worktree
  compdef _rwt_worktree_completion rwt
  compdef _cwt_branch_completion create-worktree
  compdef _cwt_branch_completion cwt
fi
