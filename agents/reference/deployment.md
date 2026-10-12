# Agent configuration deployment

Read this file before changing agent instructions, hooks, skills, plugins, or tool settings.

## Commands

`link-agentic-configs` deploys all agent configuration from this repository.

`link-configs` and `link-skills` are aliases for the same command.

Run it after changes under `agents/`, `claude/`, `codex/`, `cursor/`, `opencode/`, `pi/`, `plugins/`, or `skills/`.

After deployment, start a new session. Tools load hooks, rules, settings, and agents at launch.

Run `link-codex-config` once on each machine with administrator access.

That command links `codex/config.toml` to `/etc/codex/config.toml`.

Later repository changes need no administrator access.

## Deployment map

| Repository source | Claude Code | Codex | Cursor | OpenCode | Pi |
| --- | --- | --- | --- | --- | --- |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | User Rules paste | `~/.config/opencode/AGENTS.md` | `~/.pi/agent/AGENTS.md` |
| `agents/rules/*.md` | `~/.claude/rules/` | global pointer | User Rules pointer | global pointer | — |
| `claude/settings.json` | `~/.claude/settings.json` | — | — | — | — |
| `claude/agents/*.md` | `~/.claude/agents/` | — | Claude compatibility | — | — |
| `codex/config.toml` | — | `/etc/codex/config.toml` | — | — | — |
| `codex/hooks.json` | — | `~/.codex/hooks.json` | — | — | — |
| `cursor/hooks.json` | — | — | `~/.cursor/hooks.json` | — | — |
| `opencode/opencode.jsonc` | — | — | — | `~/.config/opencode/opencode.jsonc` | — |
| `pi/settings.json` | — | — | — | — | `~/.pi/agent/settings.json` |
| `pi/keybindings.json`, `pi/models.json` | — | — | — | — | `~/.pi/agent/` when present |
| `pi/extensions/`, `pi/prompts/`, `pi/themes/` | — | — | — | — | `~/.pi/agent/` when present |
| `agents/hooks/format-edits.sh` | settings command | hook command | `~/.cursor/hooks/` | formatter command | Pi extension command |
| `skills/*/`, plugin skills | `~/.claude/skills/` | `~/.agents/skills/` | `~/.agents/skills/` | `~/.agents/skills/` | `~/.agents/skills/` |
| Model Context Protocol servers | `~/.claude.json` | `codex/config.toml` | `~/.cursor/mcp.json` | `opencode/opencode.jsonc` | `pi/mcp.json` |

Claude and Cursor Model Context Protocol servers come from `LAC_MCP_SERVERS`.

Codex, OpenCode, and Pi use tracked configuration files.

The script uses Bash syntax. Zsh can source the script.

The script uses `find` for directory enumeration. Zsh `nomatch` makes unmatched globs fail.

## Source files and machine state

Edit `claude/settings.json` in this repository. It is the live Claude Code settings file.

Claude Code can replace that symlink after a `/config` change.

`link-agentic-configs` backs up the replacement file before restoring the link.

Edit `pi/settings.json` in this repository. It is the live Pi settings file.

Keep Pi credentials, tokens, sessions, logs, generated catalogs, and bundled binaries outside this repository.

`codex/config.toml` contains shared defaults.

The real `~/.codex/config.toml` contains machine preferences, project settings, and trust state.

User settings override the shared defaults.

Keep root `CLAUDE.md` as the single `@AGENTS.md` import.

Claude Code can read `AGENTS.md` directly in supported sessions. The import remains a compatibility fallback.

## Instructions and reference material

`agents/AGENTS.md` contains global user instructions for Claude Code, Codex, OpenCode, and Pi.

Cursor project sessions read the repository `AGENTS.md` files.

Cursor global User Rules still require a manual paste through Customize → Rules.

Files in `agents/rules/` use `paths:` frontmatter for scoped loading.

Rules without `paths:` load unconditionally.

Put long reference material in `agents/reference/`. Nothing deploys that directory as always-loaded context.

Code style uses a path-scoped pointer and a skill.

The skill reference is authoritative for every agent.

Skills load by name or description match.

Manual-only skills use `disable-model-invocation: true` in Claude Code, Cursor, and Pi.

Codex reads each skill's `agents/openai.yaml` policy.

OpenCode reads `opencode/slash` and `opencode/autoinvoke` metadata from `SKILL.md`.

`always-apply` is Cursor frontmatter. Claude Code ignores it.

## Plugins and subagents

`plugins/review-tools/` is the portable source for the review tools package.

The package contains `super-code-review`, `code-style`, and `codebase-design`.

`.claude-plugin/marketplace.json` exposes the package to Claude Code and Codex.

`.cursor-plugin/marketplace.json` exposes the package to Cursor.

Claude Code remote sessions use project skills because plugins are unavailable.

Subagents live in `claude/agents/`.

Set `model:` explicitly. The default `inherit` value uses the session model.

Claude Code supports `skills:` in subagent frontmatter.

Cursor reads compatible agents from `~/.claude/agents/`.

Use `readonly: true` for Cursor read-only enforcement. Claude Code ignores that field.

## Hooks

`agents/hooks/format-edits.sh` formats files that agents edit.

Claude Code sends a file path in JavaScript Object Notation input.

Cursor sends the path in `.file_path`.

Codex sends patch text in `.tool_input.command`.

OpenCode passes a path through its formatter.

The Pi extension passes a path after an `edit` or `write` tool succeeds.

Codex requires trust for each new or changed hook definition.

Review the exact command through `/hooks` before relying on the hook.

## Cursor details

Cursor uses `~/.agents/skills/` as the shared skill root.

Cursor also scans `~/.claude/skills/` for compatibility.

Cursor user hooks run with `~/.cursor/` as their working directory.

Therefore, `cursor/hooks.json` names the formatter as `./hooks/format-edits.sh`.

`~/.cursor/mcp.json` stores remote servers as `{"url": "..."}`.

The deployment script merges entries into that file. It never replaces unrelated entries.

`~/.cursor/cli-config.json` is machine state.

Cursor reads compatible agents from `~/.claude/agents/`.

Put shared commands in `skills/`. Cursor is migrating slash commands to skills.

## OpenCode details

`~/.config/opencode/AGENTS.md` links the global instructions.

`zsh/config.zsh` disables OpenCode compatibility scans because every source is explicit.

`opencode/opencode.jsonc` enables Context7 and the shared formatter.
