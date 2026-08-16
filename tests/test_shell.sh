#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/configs-shell.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  [ "$1" = "$2" ] || fail "expected '$2', got '$1'"
}

assert_contains() {
  case "$1" in
    *"$2"*) ;;
    *) fail "expected output to contain '$2'" ;;
  esac
}

test_worktrees() {
  local remote="$test_root/remote repo.git"
  local source_repo="$test_root/source repo"
  local worktrees="$test_root/worktree root"

  git init --bare -q "$remote"
  git init -q "$source_repo"
  git -C "$source_repo" config user.name Test
  git -C "$source_repo" config user.email test@example.com
  printf 'base\n' >"$source_repo/file.txt"
  git -C "$source_repo" add file.txt
  git -C "$source_repo" commit -qm initial
  git -C "$source_repo" branch -M main
  git -C "$source_repo" remote add origin "$remote"
  git -C "$source_repo" push -qu origin main

  # shellcheck source=../zsh/worktree.sh
  source "$repo_dir/zsh/worktree.sh"
  WT_TIMING=0

  wt_ensure_worktree "$source_repo" "feature/space-path" main "$worktrees" >/dev/null
  local created="$worktrees/feature__space-path"
  assert_eq "$WT_LAST_WORKTREE_PATH" "$created"
  [ -d "$created" ] || fail "worktree path with spaces was not created"

  git -C "$source_repo" remote set-url origin "$test_root/missing remote.git"
  wt_ensure_worktree "$source_repo" "feature/space-path" main "$worktrees" >/dev/null \
    || fail "existing worktree fetched before reuse"
  assert_eq "$WT_LAST_WORKTREE_CREATED" 0

  if wt_ensure_worktree "$source_repo" another-branch main "$worktrees" >/dev/null 2>&1; then
    fail "fetch failure did not propagate"
  fi

  git -C "$source_repo" remote set-url origin "$remote"
  wt_post_create_hook() { return 7; }
  local hook_rc=0
  wt_ensure_worktree "$source_repo" hook-failure main "$worktrees" >/dev/null 2>&1 || hook_rc=$?
  assert_eq "$hook_rc" 7
  assert_eq "$WT_LAST_WORKTREE_CREATED" 1
  [ -d "$WT_LAST_WORKTREE_PATH" ] || fail "failed post-create hook removed the worktree"
  git -C "$source_repo" worktree remove --force "$WT_LAST_WORKTREE_PATH"
  git -C "$source_repo" branch -D hook-failure >/dev/null
  unset -f wt_post_create_hook

  if wt_ensure_worktree "$source_repo" 'bad..branch' main "$worktrees" >/dev/null 2>&1; then
    fail "git worktree add failure did not propagate"
  fi
  assert_eq "$WT_LAST_WORKTREE_CREATED" 0
  assert_eq "$WT_LAST_WORKTREE_PATH" ""

  printf 'dirty\n' >"$created/dirty file.txt"
  wt_remove_worktree "$source_repo" "$created" "" --keep-session
  [ ! -e "$created" ] || fail "forced worktree removal did not remove dirty worktree"

  local prompt_output
  prompt_output="$(printf 'n\n' | bash -c 'source "$1"; remove-worktree "one path" two' _ "$repo_dir/zsh/worktree.sh")"
  assert_contains "$prompt_output" "one path, two"
  prompt_output="$(printf 'n\n' | zsh -f -c 'source "$1"; remove-worktree "one path" two' _ "$repo_dir/zsh/worktree.sh")"
  assert_contains "$prompt_output" "one path, two"
}

test_formatter_trust() {
  local home="$test_root/formatter home"
  local project="$test_root/trusted project"
  local file="$project/file with spaces.js"
  local direct_file="$project/direct file.js"
  local codex_file_one="$project/codex one.js"
  local codex_file_two="$project/codex two.js"
  mkdir -p "$home" "$project/node_modules/.bin"
  git init -q "$project"
  printf '{}\n' >"$project/.prettierrc"
  printf 'original\n' >"$file"
  printf 'original\n' >"$direct_file"
  printf 'original\n' >"$codex_file_one"
  printf 'original\n' >"$codex_file_two"
  cat >"$project/node_modules/.bin/prettier" <<'SCRIPT'
#!/bin/sh
printf 'formatted\n' >>"$4"
SCRIPT
  chmod +x "$project/node_modules/.bin/prettier"

  local payload
  payload="$(jq -n --arg path "$file" '{tool_response: {filePath: $path}}')"
  printf '%s' "$payload" | HOME="$home" TMUX_PANE='%7' sh "$repo_dir/claude/hooks/format-edits.sh"
  assert_eq "$(cat "$file")" original
  assert_eq "$(cat "$home/.cache/claude-edits/%7")" "$file"

  git -C "$project" config --local agent.formatEditsTrusted true
  printf '%s' "$payload" | HOME="$home" TMUX_PANE='%7' sh "$repo_dir/claude/hooks/format-edits.sh"
  assert_contains "$(cat "$file")" formatted

  HOME="$home" sh "$repo_dir/claude/hooks/format-edits.sh" "$direct_file"
  assert_contains "$(cat "$direct_file")" formatted

  payload="$(jq -n --arg cwd "$project" --arg command '*** Begin Patch
*** Update File: codex one.js
*** Add File: codex two.js
*** End Patch' '{cwd: $cwd, tool_input: {command: $command}}')"
  printf '%s' "$payload" | HOME="$home" sh "$repo_dir/claude/hooks/format-edits.sh"
  assert_contains "$(cat "$codex_file_one")" formatted
  assert_contains "$(cat "$codex_file_two")" formatted
}

test_agentic_links() {
  local home="$test_root/agentic home"
  mkdir -p "$home"

  local output
  output="$(HOME="$home" CONFIGS_ROOT="$repo_dir" bash -c '
    source "$1"
    _lac_register_claude_mcp() { :; }
    _lac_register_cursor_mcp() { :; }
    link-agentic-configs >/dev/null

    [ "$(readlink "$HOME/.claude/CLAUDE.md")" = "$CONFIGS_ROOT/agents/AGENTS.md" ]
    [ "$(readlink "$HOME/.codex/AGENTS.md")" = "$CONFIGS_ROOT/agents/AGENTS.md" ]
    [ "$(readlink "$HOME/.config/opencode/AGENTS.md")" = "$CONFIGS_ROOT/agents/AGENTS.md" ]
    [ "$(readlink "$HOME/.agents/skills/ask")" = "$CONFIGS_ROOT/skills/ask" ]
    [ "$(readlink "$HOME/.config/opencode/commands/ask.md")" = "$CONFIGS_ROOT/skills/ask/SKILL.md" ]
    [ ! -e "$HOME/.config/opencode/commands/diagnosing-bugs.md" ]
    [ ! -e "$HOME/.codex/skills/ask" ]

    link-agentic-configs
  ' _ "$repo_dir/zsh/link-agentic-configs.sh")"
  assert_contains "$output" "everything already linked"
}

test_skill_policies() {
  local manual_skill_names denied_skill_names
  manual_skill_names="$(for skill_file in "$repo_dir"/skills/*/SKILL.md; do
    if grep -Eq '^disable-model-invocation:[[:space:]]*true[[:space:]]*$' "$skill_file"; then
      basename "${skill_file%/SKILL.md}"
    fi
  done | sort)"
  denied_skill_names="$(jq -r '
    .permission.skill
    | to_entries[]
    | select(.value == "deny")
    | .key
  ' "$repo_dir/opencode/opencode.jsonc" | sort)"
  assert_eq "$denied_skill_names" "$manual_skill_names"

  while IFS= read -r skill_name; do
    [ -n "$skill_name" ] || continue
    grep -Eq 'allow_implicit_invocation:[[:space:]]*false' \
      "$repo_dir/skills/$skill_name/agents/openai.yaml" \
      || fail "manual skill lacks Codex policy: $skill_name"
  done <<<"$manual_skill_names"
}

test_nvm_resolution() {
  local home="$test_root/nvm home"
  mkdir -p "$home/.nvm/alias" "$home/.nvm/versions/node/v18.2.0/bin" \
    "$home/.nvm/versions/node/v20.10.0/bin" "$home/.nvm/versions/node/v20.9.0/bin"
  printf 'stable\n' >"$home/.nvm/alias/default"
  printf 'v18.2.0\n' >"$home/.nvm/alias/stable"
  cat >"$home/.nvm/nvm.sh" <<'SCRIPT'
nvm() { printf 'local-nvm:%s\n' "$*"; }
SCRIPT

  local output
  output="$(HOME="$home" zsh -f -c '
    source "$1"
    source "$1"
    node_bin="$HOME/.nvm/versions/node/v18.2.0/bin"
    count=0
    for entry in "${(@s/:/)PATH}"; do
      [ "$entry" = "$node_bin" ] && count=$((count + 1))
    done
    printf "selected=%s count=%s\n" "${PATH%%:*}" "$count"
    printf "opencode=%s\n" "$OPENCODE_DISABLE_CLAUDE_CODE"
    nvm --version
  ' _ "$repo_dir/zsh/config.zsh")"
  assert_contains "$output" "selected=$home/.nvm/versions/node/v18.2.0/bin count=1"
  assert_contains "$output" "opencode=1"
  assert_contains "$output" "local-nvm:--version"

  mkdir -p "$home/.nvm/alias/lts" "$home/.nvm/versions/node/v24.15.0/bin"
  printf 'lts/*\n' >"$home/.nvm/alias/default"
  printf 'lts/krypton\n' >"$home/.nvm/alias/lts/*"
  printf 'v24.15.0\n' >"$home/.nvm/alias/lts/krypton"
  output="$(HOME="$home" zsh -f -c 'source "$1"; printf "%s\n" "${PATH%%:*}"' _ "$repo_dir/zsh/config.zsh")"
  assert_eq "$output" "$home/.nvm/versions/node/v24.15.0/bin"

  rm -rf "$home/.nvm/versions/node/v24.15.0" "$home/.nvm/alias/lts"
  rm -f "$home/.nvm/alias/default"
  output="$(HOME="$home" zsh -f -c 'source "$1"; printf "%s\n" "${PATH%%:*}"' _ "$repo_dir/zsh/config.zsh")"
  assert_eq "$output" "$home/.nvm/versions/node/v20.10.0/bin"
}

test_statusline_cache() {
  local home="$test_root/status home"
  local project="$test_root/status project"
  local fake_bin="$test_root/fake bin"
  local calls="$test_root/git calls"
  mkdir -p "$home" "$project" "$fake_bin"
  cat >"$fake_bin/git" <<SCRIPT
#!/bin/sh
printf 'call\n' >>"$calls"
case "\$*" in
  *rev-parse*) printf 'main\n' ;;
  *status*) printf ' M file\n' ;;
esac
SCRIPT
  chmod +x "$fake_bin/git"

  local payload
  payload="$(jq -n --arg dir "$project" '{session_id: "test-session", model: {display_name: "Test"}, workspace: {current_dir: $dir}}')"
  printf '%s' "$payload" | HOME="$home" PATH="$fake_bin:$PATH" sh "$repo_dir/claude/statusline.sh" >/dev/null
  printf '%s' "$payload" | HOME="$home" PATH="$fake_bin:$PATH" sh "$repo_dir/claude/statusline.sh" >/dev/null
  assert_eq "$(wc -l <"$calls" | tr -d ' ')" 2

  local cache_file
  cache_file="$home/.cache/claude-statusline/test-session.json"
  jq -e --arg dir "$project" '.directory == $dir and .branch == "main*"' "$cache_file" >/dev/null \
    || fail "status line cache is not valid Git JSON"
  local cache_mode
  cache_mode="$(stat -f '%Lp' "$cache_file" 2>/dev/null || stat -c '%a' "$cache_file")"
  assert_eq "$cache_mode" 600
}

test_lazygit_schema() {
  assert_contains "$(cat "$repo_dir/lazygit/config.yml")" 'open: "~/configs/lazygit/scripts/lazygit-open.sh {{filename}}"'
  assert_contains "$(cat "$repo_dir/lazygit/config.yml")" 'openLink: "~/configs/lazygit/scripts/lazygit-open.sh {{link}}"'
  assert_contains "$(cat "$repo_dir/lazygit/config.yml")" 'copyToClipboardCmd:'
  if command -v lazygit >/dev/null 2>&1; then
    lazygit --use-config-file "$repo_dir/lazygit/config.yml" --config >/dev/null
  fi
}

test_worktrees
test_formatter_trust
test_agentic_links
test_skill_policies
test_nvm_resolution
test_statusline_cache
test_lazygit_schema

printf 'All shell tests passed.\n'
