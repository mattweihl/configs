# Configs

Personal dotfiles for macOS/Linux. Cloned to `~/configs` (lowercase).

## Structure

```
ghostty/          Ghostty terminal config + custom icons
glow/             Glow markdown viewer config
iterm2/           iTerm2 profile, keymaps, color themes (legacy/backup)
lazygit/          Lazygit config + helper scripts
nvim/             Neovim config (Lua, lazy.nvim)
tmux/             tmux config + Claude Code integration scripts
zsh/              zsh config (config.zsh) + worktree helpers
```

## tmux + Claude Code

- Claude Code panes are detected in `tmux.conf` by their process name: the
  launcher execs a version-named binary, so `pane_current_command` is e.g.
  `2.1.226`. `automatic-rename-format` substitutes Claude's own OSC title.
- `tmux/claude-status.sh` is driven by hooks in `~/.claude/settings.json`
  (not in this repo) and sets a per-pane `@claude_state` that renders as a
  glyph in the window name: `●` working, `◍` needs input, `✦` idle.
- `<prefix> a` opens `tmux/claude-agents.sh`, an fzf picker over every Claude
  pane across all sessions.
- The `@_claude_*` formats in `tmux.conf` (pane match, glyph, label, title) are
  the single source of truth; `claude-agents.sh` evaluates them via
  `list-panes -f` rather than reimplementing the matching.

## How configs are deployed

- `nvim/` → symlinked to `~/.config/nvim/`
- `lazygit/` → symlinked to platform-specific lazygit config path
- `tmux/tmux.conf` → sourced from `~/.tmux.conf` wrapper file (not symlinked)
- `zsh/config.zsh` → sourced from `~/.zshrc` wrapper file (not symlinked)
- `glow/` → symlinked to `~/Library/Preferences/glow/` (macOS) or `~/.config/glow/` (Linux)

## Neovim

- `init.lua` loads `core/` (options, keymaps, autocmds), then `lazy.setup("plugins")` auto-discovers `lua/plugins/*.lua`
- 2 spaces default indent, 4 for Python (autocmd)

## Conventions

- All config files should work on both macOS and Linux where possible
- Shell scripts in `lazygit/scripts/` use `~/configs/` as the base path
- No completion/autocomplete plugin in nvim (intentional)
- Format-on-save enabled in nvim (conform.nvim); `<leader>F` also available for manual formatting
- Binary/generated files (`.icns`, `lazy-lock.json`, iTerm themes) are committed as-is
