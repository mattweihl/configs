#!/usr/bin/env bash

# Links this repo's AI-agent configuration into the places the agent tools
# actually read it from, so a new machine needs one command and a new skill,
# rule, or subagent needs none.
#
# Scope is agentic tooling only -- Claude Code, Codex, Cursor, OpenCode, Pi.
# nvim, tmux, zsh, ghostty, lazygit, and glow are deployed the way they always were (see
# AGENTS.md, "How configs are deployed"); this script does not touch them.
#
# Run `link-agentic-configs`. It is idempotent: it re-links only what is wrong
# or missing, and prints "everything already linked" when there is nothing to
# do. `link-configs` and `link-skills` are kept as aliases for muscle memory.
#
# What gets linked:
#
#   agents/AGENTS.md      -> ~/.claude/CLAUDE.md   (Claude reads CLAUDE.md only)
#                            ~/.codex/AGENTS.md
#                            ~/.config/opencode/AGENTS.md
#                            ~/.pi/agent/AGENTS.md
#   agents/rules/*.md     -> ~/.claude/rules/
#   agents/reference/     not linked -- read on demand by absolute path. A rule
#                         without `paths:` frontmatter loads every session, so
#                         long reference material must not live in rules/.
#   claude/settings.json  -> ~/.claude/settings.json
#   claude/agents/*.md    -> ~/.claude/agents/
#   codex/config.toml     -> /etc/codex/config.toml (via link-codex-config)
#   codex/hooks.json      -> ~/.codex/hooks.json
#   opencode/opencode.jsonc -> ~/.config/opencode/opencode.jsonc
#   claude/statusline.sh  -> referenced by absolute path from settings.json
#   agents/hooks/*.sh     -> shared hooks named by each tool's configuration
#   skills/*/ and plugin skills -> ~/.claude/skills/ and ~/.agents/skills/
#                         The shared ~/.agents root serves Codex, Cursor, and
#                         OpenCode. Skill frontmatter controls invocation.
#                         Codex ships its own bundled skills in
#                         ~/.codex/skills/.system/. That is a real directory,
#                         not a link, so pruning never touches it.
#   cursor/hooks.json     -> ~/.cursor/hooks.json
#   agents/hooks/format-edits.sh -> ~/.cursor/hooks/format-edits.sh
#   pi/settings.json      -> ~/.pi/agent/settings.json
#   pi/keybindings.json   -> ~/.pi/agent/keybindings.json (when present)
#   pi/mcp.json           -> ~/.pi/agent/mcp.json (when present)
#   pi/models.json        -> ~/.pi/agent/models.json (when present)
#   pi/extensions/        -> ~/.pi/agent/extensions/ (when present)
#   pi/prompts/           -> ~/.pi/agent/prompts/ (when present)
#   pi/themes/            -> ~/.pi/agent/themes/ (when present)
#                         Pi also discovers the shared ~/.agents/skills/ root,
#                         so skills are not duplicated under ~/.pi/agent/skills.
#
# Skill source roots are ~/configs/skills, portable plugin skills, and
# ~/code/work-configs/skills (work-specific, absent on some machines).
#
# Pi gets settings, MCP/model/keybinding files, resource directories, shared
# edit formatting, and global instructions in its agent directory. Auth, OAuth
# tokens, session history, generated model catalogs, logs, and bundled helper
# binaries stay in ~/.pi/agent as machine state.
#
# Cursor gets skills, hooks, and MCP servers, and cannot get the rest. It has no
# user-level rules directory and reads AGENTS.md from a project root only, so
# agents/AGENTS.md and agents/rules/ have no home to be linked to. Cursor's User
# Rules live in its settings UI, not on disk -- paste them in by hand, once per
# machine. See AGENTS.md, "Cursor coverage".
#
# Bash shebang, but config.zsh sources this into zsh. Directory contents are
# therefore enumerated with `find`, never a glob: zsh has `nomatch` on by
# default, so a glob that matches nothing aborts the command instead of
# expanding to nothing the way bash does.

CONFIGS_ROOT="${CONFIGS_ROOT:-$HOME/configs}"

LAC_SKILL_SOURCES=(
  "$CONFIGS_ROOT/skills"
  "$CONFIGS_ROOT/plugins/review-tools/skills"
  "$HOME/code/work-configs/skills"
)

LAC_SKILL_TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
)

LAC_LEGACY_SKILL_TARGETS=(
  "$HOME/.cursor/skills"
  "$HOME/.codex/skills"
  "$HOME/.config/opencode/skills"
)

# MCP servers, registered rather than linked for both Claude Code and Cursor.
# Claude keeps user-scope servers in ~/.claude.json, which is machine state mixed
# with UI counters and is not worth versioning. Cursor's ~/.cursor/mcp.json is a
# plain config file, but Cursor writes to it whenever you add a server from the
# UI, so it is merged into rather than replaced.
#
# Codex is not registered from this table. Its tracked defaults live at the
# lower-precedence system layer, while ~/.codex/config.toml remains machine
# state. OpenCode reads the same Context7 entry from opencode/opencode.jsonc.
#
# Format: name|transport|url
LAC_MCP_SERVERS=(
  "context7|http|https://mcp.context7.com/mcp"
)

_lac_linked=0
_lac_warned=0

# Links src -> dest with one rule: never destroy something that is not ours.
# An existing correct symlink is left alone, a wrong one is repointed, and a
# real file is backed up before it is replaced.
_lac_link() {
  local src="$1" dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  [[ -e "$src" ]] || return 0
  mkdir -p "$dest_dir"

  if [[ -L "$dest" ]]; then
    [[ "$(readlink "$dest")" == "$src" ]] && return 0
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "link-agentic-configs: $dest was a real file; backed up to $backup" >&2
    _lac_warned=$((_lac_warned + 1))
  fi

  ln -s "$src" "$dest"
  echo "linked ${dest/#$HOME/~}"
  _lac_linked=$((_lac_linked + 1))
}

# Removes one link only when it still points at the managed source.
_lac_unlink() {
  local src="$1" dest="$2"
  [[ -L "$dest" ]] || return 0
  [[ "$(readlink "$dest")" == "$src" ]] || return 0

  rm "$dest"
  echo "unlinked ${dest/#$HOME/~}"
  _lac_linked=$((_lac_linked + 1))
}

# Links every top-level file of one extension into a target directory.
_lac_link_files() {
  # _lac_link_files <source-dir> <extension> <target-dir>
  local source_dir="$1" ext="$2" target_dir="$3" file
  [[ -d "$source_dir" ]] || return 0
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    _lac_link "$file" "$target_dir/$(basename "$file")"
  done < <(find "$source_dir" -maxdepth 1 -type f -name "*.$ext" | sort)
}

_lac_link_skills() {
  local source_root target_root skill_file skill_dir skill_name

  for source_root in "${LAC_SKILL_SOURCES[@]}"; do
    [[ -d "$source_root" ]] || continue

    while IFS= read -r skill_file; do
      [[ -n "$skill_file" ]] || continue
      skill_dir="$(dirname "$skill_file")"
      skill_name="$(basename "$skill_dir")"

      for target_root in "${LAC_SKILL_TARGETS[@]}"; do
        _lac_link "$skill_dir" "$target_root/$skill_name"
      done
    done < <(find "$source_root" -mindepth 2 -maxdepth 2 -type f \
      -name SKILL.md | sort)
  done
}

# Removes personal skill links from the old tool-specific roots. Claude keeps
# its own root; Codex, Cursor, and OpenCode now share ~/.agents/skills.
_lac_remove_legacy_skill_links() {
  local target_root entry link_target source_root

  for target_root in "${LAC_LEGACY_SKILL_TARGETS[@]}"; do
    [[ -d "$target_root" ]] || continue

    while IFS= read -r entry; do
      [[ -n "$entry" ]] || continue
      link_target="$(readlink "$entry")"

      for source_root in "${LAC_SKILL_SOURCES[@]}"; do
        case "$link_target" in
          "$source_root"/*)
            rm "$entry"
            echo "unlinked legacy ${entry/#$HOME/~}"
            _lac_linked=$((_lac_linked + 1))
            break
            ;;
        esac
      done
    done < <(find "$target_root" -mindepth 1 -maxdepth 1 -type l | sort)
  done
}

# Removes command links from the old OpenCode workaround. OpenCode now reads
# slash-command and automatic-invocation policy from each skill's metadata.
_lac_remove_legacy_opencode_commands() {
  local source_root command_file link_target

  [[ -d "$HOME/.config/opencode/commands" ]] || return 0
  for source_root in "${LAC_SKILL_SOURCES[@]}"; do
    while IFS= read -r command_file; do
      [[ -n "$command_file" ]] || continue
      link_target="$(readlink "$command_file")"
      case "$link_target" in
        "$source_root"/*/SKILL.md)
          rm "$command_file"
          echo "unlinked legacy ${command_file/#$HOME/~}"
          _lac_linked=$((_lac_linked + 1))
          ;;
      esac
    done < <(find "$HOME/.config/opencode/commands" -maxdepth 1 -type l | sort)
  done
}

# Removes symlinks whose target no longer exists. Without this, deleting a skill
# or rule from the repo leaves a dangling link that the tool still tries to load.
_lac_prune() {
  local dir="$1" entry
  [[ -d "$dir" ]] || return 0
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    rm "$entry"
    echo "pruned dangling ${entry/#$HOME/~}"
  done < <(find "$dir" -maxdepth 1 -type l ! -exec test -e {} \; -print)
}

# chmod over a directory of scripts, without a glob the caller has to expand.
_lac_make_executable() {
  # _lac_make_executable <dir> <extension>
  [[ -d "$1" ]] || return 0
  find "$1" -maxdepth 1 -type f -name "*.$2" -exec chmod +x {} +
}

_lac_register_claude_mcp() {
  command -v claude >/dev/null 2>&1 || return 0
  command -v jq >/dev/null 2>&1 || return 0

  local entry name transport url
  for entry in "${LAC_MCP_SERVERS[@]}"; do
    IFS='|' read -r name transport url <<<"$entry"

    # Read ~/.claude.json rather than `claude mcp list`, which health-checks
    # every server over the network and would stall an interactive shell.
    # jq is already a hard dependency of claude/statusline.sh.
    if jq -e --arg n "$name" '.mcpServers | has($n)' "$HOME/.claude.json" \
      >/dev/null 2>&1; then
      continue
    fi

    if claude mcp add --scope user --transport "$transport" "$name" "$url" >/dev/null 2>&1; then
      echo "registered mcp server $name (claude, user scope)"
      _lac_linked=$((_lac_linked + 1))
    else
      echo "link-agentic-configs: failed to register mcp server $name" >&2
      _lac_warned=$((_lac_warned + 1))
    fi
  done
}

# Adds each server to ~/.cursor/mcp.json, leaving every other key alone. There is
# no `cursor mcp add`, so this edits the file -- which means never overwriting
# an entry that is already there, and never touching the file when nothing is
# missing. A malformed file is left for the user to fix, not replaced.
_lac_register_cursor_mcp() {
  command -v jq >/dev/null 2>&1 || return 0

  local config="$HOME/.cursor/mcp.json"
  local entry name transport url tmp

  mkdir -p "$HOME/.cursor"
  [[ -e "$config" ]] || echo '{"mcpServers":{}}' >"$config"

  for entry in "${LAC_MCP_SERVERS[@]}"; do
    IFS='|' read -r name transport url <<<"$entry"

    # Cursor addresses a remote server by url alone. A stdio server needs a
    # command and args instead, which this table has no column for.
    if [[ "$transport" != "http" && "$transport" != "sse" ]]; then
      echo "link-agentic-configs: mcp server $name is $transport; add it to ~/.cursor/mcp.json by hand" >&2
      _lac_warned=$((_lac_warned + 1))
      continue
    fi

    if jq -e --arg n "$name" '.mcpServers | has($n)' "$config" >/dev/null 2>&1; then
      continue
    fi

    tmp="$(mktemp)" || continue
    if jq --arg n "$name" --arg u "$url" '.mcpServers[$n] = {url: $u}' \
      "$config" >"$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
      mv "$tmp" "$config"
      echo "registered mcp server $name (cursor, user scope)"
      _lac_linked=$((_lac_linked + 1))
    else
      rm -f "$tmp"
      echo "link-agentic-configs: failed to register mcp server $name for cursor" >&2
      _lac_warned=$((_lac_warned + 1))
    fi
  done
}

link-agentic-configs() {
  _lac_linked=0
  _lac_warned=0

  # Shared, tool-agnostic instructions. Claude Code reads CLAUDE.md and never
  # AGENTS.md, so the Claude side is a rename, not a copy.
  _lac_link "$CONFIGS_ROOT/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
  _lac_link "$CONFIGS_ROOT/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
  _lac_link "$CONFIGS_ROOT/agents/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  _lac_link "$CONFIGS_ROOT/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"

  _lac_prune "$HOME/.claude/rules"
  _lac_link_files "$CONFIGS_ROOT/agents/rules" md "$HOME/.claude/rules"

  _lac_link "$CONFIGS_ROOT/claude/settings.json" "$HOME/.claude/settings.json"
  _lac_link "$CONFIGS_ROOT/codex/hooks.json" "$HOME/.codex/hooks.json"
  _lac_link "$CONFIGS_ROOT/opencode/opencode.jsonc" \
    "$HOME/.config/opencode/opencode.jsonc"

  _lac_link "$CONFIGS_ROOT/pi/settings.json" "$HOME/.pi/agent/settings.json"
  _lac_link "$CONFIGS_ROOT/pi/keybindings.json" "$HOME/.pi/agent/keybindings.json"
  _lac_link "$CONFIGS_ROOT/pi/mcp.json" "$HOME/.pi/agent/mcp.json"
  _lac_link "$CONFIGS_ROOT/pi/models.json" "$HOME/.pi/agent/models.json"
  _lac_link "$CONFIGS_ROOT/pi/extensions" "$HOME/.pi/agent/extensions"
  _lac_link "$CONFIGS_ROOT/pi/prompts" "$HOME/.pi/agent/prompts"
  _lac_link "$CONFIGS_ROOT/pi/themes" "$HOME/.pi/agent/themes"

  _lac_prune "$HOME/.claude/agents"
  _lac_link_files "$CONFIGS_ROOT/claude/agents" md "$HOME/.claude/agents"

  chmod +x "$CONFIGS_ROOT/claude/statusline.sh" 2>/dev/null
  _lac_make_executable "$CONFIGS_ROOT/agents/hooks" sh

  # Cursor runs a user hook from ~/.cursor/, and its docs spell the path
  # relative to that directory. So the script is linked next to hooks.json
  # rather than named by an absolute path the way settings.json names it.
  _lac_link "$CONFIGS_ROOT/cursor/hooks.json" "$HOME/.cursor/hooks.json"
  _lac_link "$CONFIGS_ROOT/agents/hooks/format-edits.sh" \
    "$HOME/.cursor/hooks/format-edits.sh"

  _lac_remove_legacy_skill_links

  local target_root
  for target_root in "${LAC_SKILL_TARGETS[@]}"; do
    _lac_prune "$target_root"
  done
  _lac_link_skills
  _lac_remove_legacy_opencode_commands

  _lac_register_claude_mcp
  _lac_register_cursor_mcp

  ((_lac_linked == 0)) && echo "link-agentic-configs: everything already linked"
  ((_lac_warned > 0)) && echo "link-agentic-configs: finished with $_lac_warned warning(s)" >&2
  return 0
}

# Links shared Codex defaults into the system configuration layer. Creating or
# changing this link needs administrator access; editing its repo target does not.
link-codex-config() {
  local src="$CONFIGS_ROOT/codex/config.toml"
  local dest="/etc/codex/config.toml"
  local backup

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "link-codex-config: already linked"
    return 0
  fi

  sudo mkdir -p /etc/codex || return 1

  if [[ -L "$dest" ]]; then
    sudo rm "$dest" || return 1
  elif [[ -e "$dest" ]]; then
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    sudo mv "$dest" "$backup" || return 1
    echo "link-codex-config: $dest was a real file; backed up to $backup" >&2
  fi

  sudo ln -s "$src" "$dest" || return 1
  echo "linked $dest"
}

# Previous names; some notes and muscle memory still use them.
link-configs() { link-agentic-configs "$@"; }
link-skills() { link-agentic-configs "$@"; }
