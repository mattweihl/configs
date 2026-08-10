# Configs

Personal dotfiles for macOS/Linux. Cloned to `~/configs` (lowercase).

This file is the single source of truth for agents working on this repo.
`CLAUDE.md` imports it; do not duplicate content there.

## Structure

```
agents/           Cross-tool agent instructions (user-level)
                    AGENTS.md   always loaded, every session
                    rules/      path-scoped, loaded when a matching file is read
                    reference/  never loaded; read on demand by absolute path
claude/           Claude Code config: settings.json, subagents, hooks, statusline
cursor/           Cursor config: hooks.json (skills and MCP are not files here)
ghostty/          Ghostty terminal config + custom icons
glow/             Glow markdown viewer config
iterm2/           iTerm2 profile, keymaps, color themes (legacy/backup)
lazygit/          Lazygit config + helper scripts
nvim/             Neovim config (Lua, lazy.nvim)
skills/           Agent skills, shared between Claude Code and Cursor
tmux/             tmux config + Claude Code integration scripts
zsh/              zsh config (config.zsh) + worktree and linking helpers
```

Note the two `AGENTS.md` files, which are not the same thing:

- `./AGENTS.md` (this file) describes **the repo** to an agent working on it.
- `agents/AGENTS.md` describes **the user** to every agent on the machine. It is
  linked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.

## How configs are deployed

- `link-agentic-configs` (from `zsh/link-agentic-configs.sh`) deploys everything
  agent-related. Each tool gets only what it can read, which is not the same set:

  | Repo | Claude Code | Codex | Cursor |
  | --- | --- | --- | --- |
  | `agents/AGENTS.md` | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | — |
  | `agents/rules/*.md` | `~/.claude/rules/` | — | — |
  | `claude/settings.json` | `~/.claude/settings.json` | — | — |
  | `claude/agents/*.md` | `~/.claude/agents/` | — | — |
  | `claude/hooks/format-edits.sh` | named by `settings.json` | — | `~/.cursor/hooks/` |
  | `cursor/hooks.json` | — | — | `~/.cursor/hooks.json` |
  | `skills/*/` | `~/.claude/skills/` | — | `~/.cursor/skills/` |
  | MCP servers | `~/.claude.json` | — | `~/.cursor/mcp.json` |

  MCP servers are registered, not linked, from the single `LAC_MCP_SERVERS`
  table in the script. Codex is left out of that: its servers live in a
  `[mcp_servers.*]` table in `~/.codex/config.toml`, which is hand-maintained
  and not in this repo. The script covers agentic tooling only; the entries
  below are deployed by hand. `link-configs` and `link-skills` are aliases
  for it.
- The script is bash but zsh sources it, so it enumerates directories with
  `find`, never a glob. zsh has `nomatch` on by default: a glob matching
  nothing aborts the command instead of expanding to nothing.
- `nvim/` → symlinked to `~/.config/nvim/`
- `lazygit/` → symlinked to platform-specific lazygit config path
- `tmux/tmux.conf` → sourced from `~/.tmux.conf` wrapper file (not symlinked)
- `tmux/tmux-powerline/` → symlinked to `~/.config/tmux-powerline/`, so
  `config.sh`, `themes/`, and `segments/` are all live from the repo
- `zsh/config.zsh` → sourced from `~/.zshrc` wrapper file (not symlinked)
- `glow/` → symlinked to `~/Library/Preferences/glow/` (macOS) or `~/.config/glow/` (Linux)

`~/.claude/settings.json` is a symlink into this repo, but Claude Code writes to
that path itself when you change theme or model through `/config`. If it ever
replaces the symlink with a real file, `link-configs` backs the file up and
relinks, and prints where the backup went — diff it to recover the change.

## Agent configuration

- `claude/settings.json` in this repo **is** the live `~/.claude/settings.json`.
  Edit it here, not there.
- After changing anything under `agents/`, `claude/`, or `skills/`, run
  `link-agentic-configs` and start a new session. Hooks, rules, settings, and
  subagents are all read at launch.
- `CLAUDE.md` at the repo root contains a single `@AGENTS.md` import and nothing
  else. Claude Code reads `CLAUDE.md` and never `AGENTS.md`, so that import is
  what lets one file serve both Claude and Codex. Do not add content to it.
- `agents/AGENTS.md` is always loaded, in every session, in every project. Keep
  it short; the docs recommend staying under 200 lines.
- `agents/rules/*.md` use `paths:` frontmatter and load only when the agent
  reads a matching file. Long or language-specific guidance goes here. A rule
  with no `paths:` field loads unconditionally — put reference material in
  `agents/reference/` instead, which nothing links or preloads.
- Skills load on demand, by name or by description match. A skill with
  `disable-model-invocation: true` is user-invocable only — it stays in the `/`
  menu but the model never loads it on its own. Do not use that flag for
  anything meant to apply automatically; use a rule.
- `always-apply` is Cursor frontmatter. Claude Code ignores it.
- Code style ships as both, deliberately. The rule fires automatically on code
  being written; the `code-style` skill is invoked against code the agent is
  only reading, such as a pull request. `agents/rules/code-style.md` is the
  single source of truth — the skill points at it and copies nothing.
- Subagents live in `claude/agents/`. Set `model:` explicitly — it defaults to
  `inherit`, which silently runs cheap mechanical work on the session's model.
- Unrecognized agent frontmatter keys are dropped without a warning. There is
  no `skills:` field: an agent that must read a skill needs an explicit
  instruction to `Read` the file by path. Verify a frontmatter key exists
  before relying on it, because nothing will tell you it did not.
- `claude/hooks/format-edits.sh` runs prettier/ruff/terraform on files an agent
  writes, because agent edits never pass through nvim's format-on-save. One
  script serves both agents. It stays under `claude/` despite that: the path is
  named by `claude/settings.json` and by the link script, so the directory is a
  historical name, not a scope. It reads the path from the
  hook's **stdin JSON**, and the two agents spell it differently: Claude
  uses `.tool_response.filePath` (falling back to `.tool_input.file_path` /
  `.tool_input.notebook_path`), Cursor's `afterFileEdit` payload is a flat
  `.file_path`. There is no `CLAUDE_FILE_PATHS` environment variable — a hook
  written against one silently formats nothing.
- prettier and ruff only run when the project has a matching config file, so a
  repo that never opted into them does not get a whole-file reformat from one
  agent edit. terraform has no such gate: `terraform fmt` is the one canonical
  HCL style. It is also stdin-only — `terraform fmt <file>` is rejected,
  because the positional argument is a directory.

## Cursor coverage

Cursor reads skills, hooks, and MCP servers from the home directory. It reads
instructions from a project only. That split is the whole story:

- `~/.cursor/skills/` is a documented global skill root, alongside
  `~/.agents/skills/`. A `SKILL.md` needs `name` (matching the folder) and
  `description`; the optional `paths:` field scopes a skill to matching files,
  which is the closest thing Cursor has to a path-scoped rule.
- `~/.cursor/hooks.json` holds user hooks. A user hook runs with `~/.cursor/` as
  its working directory, so `cursor/hooks.json` names the script as
  `./hooks/format-edits.sh` and the link script puts a symlink there. Do not
  switch it to an absolute path to match `claude/settings.json` — the two are
  resolved differently.
- `~/.cursor/mcp.json` takes a remote server as `{"url": ...}`. It is merged,
  never linked or overwritten: Cursor writes to that file when you add a server
  through the UI.
- **Instructions do not reach Cursor at all.** There is no user-level rules
  directory, `AGENTS.md` is read from a project root and its subdirectories,
  and User Rules live in Cursor's settings UI rather than on disk — the docs
  say to re-enter them by hand on a new machine. So `agents/AGENTS.md` and
  `agents/rules/` are Claude/Codex-only, and the Cursor equivalent is a manual
  paste into Customize → Rules, once per machine.
- `~/.cursor/cli-config.json` is `cursor-agent`'s own state (model, permissions,
  sandbox). It is not linked; treat it as machine state.
- Cursor is migrating slash commands to skills — it ships a `/migrate-to-skills`
  command. Do not add a `~/.cursor/commands/` link; put shared behaviour in
  `skills/`, which both agents already load.

## tmux + Claude Code

- Claude Code panes are detected in `tmux.conf` by their process name: the
  launcher execs a version-named binary, so `pane_current_command` is e.g.
  `2.1.226`. `automatic-rename-format` substitutes Claude's own OSC title.
- `tmux/claude-status.sh` is driven by hooks in `claude/settings.json` and sets
  a per-pane `@claude_state` that renders as a glyph in the window name:
  `●` working, `◍` needs input, `✦` idle. It then re-asserts `automatic-rename`
  on the window: tmux only recomputes an auto-name when the pane emits output,
  and `◍` is by definition the moment the agent has gone quiet, so the glyph
  would otherwise never repaint.
- `<prefix> a` opens `tmux/claude-agents.sh`, an fzf picker over every Claude
  agent — panes from `list-panes`, plus daemon-owned background sessions from
  `claude agents --json`, which have no pane and are otherwise unreachable from
  tmux. The two sources overlap when a background agent is attached to a pane,
  and they disagree, because that session's frozen `@claude_state` is exactly
  the value not to trust. The script repairs the disagreement at the source: it
  writes the daemon's live state onto the pane with `set-option -p` *before*
  listing panes, so tmux renders the row — and the window-name glyph, which was
  telling the same lie — correctly. State is only as fresh as the last time you
  opened the picker. Picking a detached agent opens the agent view in a new
  window.
- Detached rows print the daemon's own state verbatim (`working`, `done`,
  `failed`). Do not fold those into the pane vocabulary: a daemon agent can be
  `failed`, there is no glyph for that, and a catch-all `else idle` hides the
  one row you needed to see.
- The `@_claude_*` formats in `tmux.conf` (pane match, glyph, label, title) are
  the single source of truth; `claude-agents.sh` evaluates them via
  `list-panes -f` rather than reimplementing the matching. Column padding is
  part of that: `#{p10:}` / `#{p20:}` pad by display width, which `printf
  "%-10s"` cannot do once a glyph or a `…` is in the string. Detached rows have
  no pane to render from, so they go through `display-message -p` with
  `#{l:...}` — same formats, same arithmetic.
- Any text interpolated into a tmux format must have its `#` doubled, or the
  row truncates at that character.
- The glyph in the window name and `claude/statusline.sh` inside the pane answer
  different questions: the glyph says *which* pane wants you, the status line
  says what the agent in front of you is running on.
- The glyph is scoped to the session you are attached to, because it renders in
  a window *name*. The `claude_waiting` powerline segment
  (`tmux/tmux-powerline/segments/`) closes that gap: it lists every *other*
  session holding a `wait` pane, and prints nothing — which makes powerline drop
  the segment entirely — when there are none. It filters with `list-panes -f`
  against `@claude_state` rather than restating the state vocabulary.
- The theme's per-window `λ`/`✦`/`$` prefix tests `@_claude_pane`, not
  `#{m:claude,#{pane_current_command}}`. The literal match silently never fired:
  `pane_current_command` is the version string. Anything that needs to know "is
  this a Claude pane" goes through that format.
- `<prefix> e` opens `tmux/claude-edits.sh`, an fzf picker over the files the
  agent in *that pane* has edited, newest first. `claude/hooks/format-edits.sh`
  appends each path to `~/.cache/claude-edits/<pane-id>` before its formatter
  gates, so the list covers every edit and not just the reformatted ones. The
  `SessionStart` hook clears it, matched to `startup` only — a resume or a
  compact keeps the history it had.
- Do not build that path with `#{s/%//:pane_id}`. tmux substitution works on
  other characters but leaves the leading `%` of a pane id in place, so the
  binding passes `#{pane_id}` verbatim as an argument and the file is named
  `%3`, not `3`.
- `$TMPDIR` is not usable as a handoff point between a hook and the tmux server:
  on macOS it is per-process-context, and the two can resolve it differently.
  `~/.cache` is shared by definition.
- Popups sit over the agent pane instead of splitting it: `<prefix> g` for
  lazygit, `M-t` for a shell, both starting in `#{pane_current_path}`. A Claude
  pane reflows badly when it loses columns, so nothing that is transient should
  cost it width. `<prefix> t` is the clock, which is why lazygit is on `g`.
- Only agents launched inside a pane drive the glyph. `claude-status.sh` targets
  `$TMUX_PANE`, and background / daemon-resumed sessions don't inherit it, so
  their hooks exit as a no-op. Don't try to recover the pane by walking the
  process tree: such a session's ancestry either reaches no pane at all, or
  reaches the *parent* agent's pane and marks a window that isn't its own.
- Diagnostic: a pane whose window *name* tracks Claude's title live but whose
  glyph is stuck on `✦` is the case above, not a broken hook. The title arrives
  as an OSC escape on the tty (no env needed); the state needs `$TMUX_PANE`.
  Same pane, two channels — verify with `tmux list-panes -a -F
  '#{pane_id} [#{@claude_state}] #{window_name}'`.
- `claude --resume` refuses a session that is still running in the background
  ("That session is still running as a background agent"). That is correct
  behaviour, not a broken session: the daemon owns it, and a second client
  cannot attach. Reach it with `<prefix> a` or `claude agents`, or stop it there
  first. `~/.claude/daemon.log` records which sessions are background and why,
  as `bg claimed-spare <id> (<reason>)`.

## Neovim

- `init.lua` loads `core/` (options, keymaps, autocmds), then `lazy.setup("plugins")` auto-discovers `lua/plugins/*.lua`
- 2 spaces default indent, 4 for Python (autocmd)

## Worktree + tmux workflow

- Shared helpers live in `~/configs/zsh/worktree.sh` and are sourced from `~/configs/zsh/config.zsh`.
- Work-repo wrappers stay in `~/code/configs/config.zsh` so repo-specific paths are not baked into shared dotfiles.
- `,cwt <branch> [base-branch]` creates/reuses the worktree, runs bootstrap steps, and enters tmux by default.
- `,cwt --no-tmux <branch> [base-branch]` creates/reuses without attaching/switching tmux.
- `,rwt <worktree>` removes the worktree and kills its matching tmux session when present.
- `,rwt --keep-session <worktree>` (or `--no-kill-session`) removes without killing tmux.

## Conventions

- All config files should work on both macOS and Linux where possible
- Shell scripts in `lazygit/scripts/` use `~/configs/` as the base path
- No completion/autocomplete plugin in nvim (intentional)
- Format-on-save enabled in nvim (conform.nvim); `<leader>F` also available for manual formatting
- Formatter lists in `nvim/lua/plugins/format.lua` and `claude/hooks/format-edits.sh` must stay in step, binary names and arguments included (`terraform fmt -no-color -`)
- Before adding a formatter to either file, check the binary actually resolves. `sql_formatter` sat in `format.lua` doing nothing for as long as it was there: conform runs `sql-formatter`, which was installed nowhere
- Run a script against a realistic input before documenting how it behaves. Every wrong claim in this file so far came from describing intent instead of observed output
- Binary/generated files (`.icns`, `lazy-lock.json`, iTerm themes) are committed as-is
