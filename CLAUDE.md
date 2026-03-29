# Configs

Personal dotfiles for a macOS/Linux dev environment. This repo is cloned to `~/configs` (lowercase) and individual config files are symlinked into their expected locations.

## Structure

```
ghostty/          Ghostty terminal config + custom icons
iterm2/           iTerm2 profile, keymaps, color themes (legacy/backup)
lazygit/          Lazygit config + helper scripts (open, clipboard)
nvim/             Neovim config (Lua, lazy.nvim plugin manager)
tmux/             tmux config
zsh/              zshrc
```

## Symlink targets

Configs are expected to be symlinked as follows:

- `nvim/` → `~/.config/nvim/`
- `tmux/tmux.conf` → `~/.tmux.conf`
- `zsh/zshrc` → `~/.zshrc`
- `lazygit/config.yml` → platform-specific lazygit config path

## Neovim

- **Plugin manager**: lazy.nvim with lazy-loading enabled by default
- **Leader key**: Space
- **Colorscheme**: gruvbox (dark)
- **File structure**: `init.lua` loads `core/` (options, keymaps, autocmds), then `lazy.setup("plugins")` auto-discovers `lua/plugins/*.lua`
- **LSP**: mason.nvim + mason-lspconfig.nvim; servers are declared in `lsp.lua` `ensure_installed`
- **Formatting**: conform.nvim (prettier for web/markdown/yaml, black for Python); format-on-save is OFF, use `<leader>F` to format
- **Linting**: flake8 via `:Flake8` command (Python only)
- **File tree**: neo-tree (`<C-n>` to toggle)
- **Fuzzy finder**: telescope.nvim with fzf-native (`<C-p>` or `<leader>ff` for files, `<leader>fg` for grep)
- **Editor plugins**: autopairs, Comment.nvim (`gcc`), nvim-surround (`ys`/`ds`/`cs`)
- **Treesitter**: auto-install enabled; zsh files use bash parser
- **Indent**: 2 spaces default, 4 for Python (set via autocmd)
- **Auto-reload**: buffers auto-reload when files change on disk (for AI agent workflows)

### Key mappings (non-obvious)

| Key | Mode | Action |
|-----|------|--------|
| `jk` | insert | Exit insert mode |
| `<CR>` | normal | Clear search highlight |
| `<leader>ww` | normal | Save |
| `<leader>q` | normal | Quit |
| `<C-h/j/k/l>` | normal | Navigate splits |
| `<A-j/k>` | normal/visual | Move lines up/down |
| `<leader>rn` | normal | LSP rename |
| `<leader>ca` | normal/visual | LSP code action |
| `<leader>e` | normal | Show line diagnostics |
| `<leader>F` | normal | Format buffer |
| `<leader>?` | normal | Show all keybindings (which-key) |

## Shell (zsh)

- Custom prompt: time + cwd + git branch (no framework, pure zsh)
- `$EDITOR` is nvim when available, otherwise vim
- `fzf` shell integration loaded if available
- Git aliases: `gs`, `gb`, `ga`, `gc`, `gp`, `gd`
- Navigation: `c` → `$CODE_LOCATION`, `dt` → `$DESKTOP`
- Emacs keybindings (`bindkey -e`)
- History: 50k lines, shared across sessions, deduped

## Tmux

- Prefix: `C-b`
- `prefix r` reloads config
- Mouse enabled (toggle with `prefix m`)
- 1-indexed windows/panes
- New windows/splits inherit current path
- OSC 52 clipboard passthrough enabled (for SSH/remote)
- Status bar: session name left, time/date right, minimal style (black/white)

## Ghostty

- Font: Iosevka Nerd Font Mono, size 18
- Theme: Dracula+
- `Cmd+Ctrl+T` toggles quick terminal
- Custom icon: ghostty-black

## Conventions

- All config files should work on both macOS and Linux where possible
- Shell scripts in `lazygit/scripts/` use `~/configs/` as the base path
- No completion/autocomplete plugin in nvim (intentional)
- No format-on-save (intentional — format explicitly with `<leader>F`)
- Binary/generated files (`.icns`, `lazy-lock.json`, iTerm themes) are committed as-is
