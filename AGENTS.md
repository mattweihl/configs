# Configs

Personal dotfiles for macOS/Linux. Cloned to `~/configs` (lowercase).

## Structure

```
ghostty/          Ghostty terminal config + custom icons
glow/             Glow markdown viewer config
iterm2/           iTerm2 profile, keymaps, color themes (legacy/backup)
lazygit/          Lazygit config + helper scripts
nvim/             Neovim config (Lua, lazy.nvim)
tmux/             tmux config
zsh/              zshrc
```

## How configs are deployed

- `nvim/` → symlinked to `~/.config/nvim/`
- `lazygit/` → symlinked to platform-specific lazygit config path
- `tmux/tmux.conf` → sourced from `~/.tmux.conf` wrapper file (not symlinked)
- `zsh/zshrc` → sourced from `~/.zshrc` wrapper file (not symlinked)
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

## Worktree + tmux workflow

- Shared helpers live in `~/configs/zsh/worktree.sh` and are sourced from `~/configs/zsh/config.zsh`.
- Work-repo wrappers stay in `~/code/configs/config.zsh` so repo-specific paths are not baked into shared dotfiles.
- `,cwt <branch> [base-branch]` creates/reuses the worktree, runs bootstrap steps, and enters tmux by default.
- `,cwt --no-tmux <branch> [base-branch]` creates/reuses without attaching/switching tmux.
- `,rwt <worktree>` removes the worktree and kills its matching tmux session when present.
- `,rwt --keep-session <worktree>` (or `--no-kill-session`) removes without killing tmux.
- `,s` remains the browse/attach sessionizer; naming is shared with `,cwt` via helper functions.
