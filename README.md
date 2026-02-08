# Configs

Personal development environment configurations for macOS.

## Neovim (`nvim/`)

Lua-based Neovim config using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.

- **Colorscheme:** Gruvbox (hard contrast), with Dracula, Solarized, PaperColor, and Gabriel also available in `colors/`
- **LSP:** Mason-managed language servers for TypeScript, Python (Pyright), Lua, Rust, C/C++, Java, HTML/CSS, Tailwind, ESLint, and Emmet
- **Treesitter:** Syntax highlighting and structural editing for 20+ languages
- **Telescope:** Fuzzy finder (`Ctrl+P` files, `<leader>fg` live grep, `<leader>fb` buffers)
- **Completion:** nvim-cmp with LSP and snippet sources
- **UI:** Lualine status bar, Barbar buffer tabs (`Shift+H/L`), indent guides, Trouble diagnostics
- **Debugging:** DAP with dapui
- **Git:** Git integration plugins
- **Formatting/Linting:** Configured via format-lint.lua
- **Key mappings:** Leader is `<Space>`, `jk` for ESC, `Ctrl+H/J/K/L` window nav, `Alt+J/K` move lines, standard LSP bindings (`gd`, `gr`, `K`, `<leader>rn`)
- **Editor:** 2-space tabs, cursorline, persistent undo, OSC 52 clipboard (SSH/tmux compatible)

## Tmux (`tmux/`)

Single `tmux.conf` file.

- **Prefix:** `Ctrl+B`
- **Base index:** 1
- **Mouse:** Enabled (toggle with `<prefix>m`)
- **History:** 10,000 lines
- **Splits:** `"` horizontal, `%` vertical — new panes open in current directory
- **Reload:** `<prefix>r`
- **Status bar:** Session name on left, time/date on right
- **Clipboard:** OSC 52 passthrough enabled

## Zsh (`zsh/`)

Single `zshrc` file.

- **Prompt:** `HH:MM ~/path (branch)` with color coding (green time, blue directory, red git branch)
- **Editor:** Defaults to Neovim (`vim`/`vi` aliased to `nvim`)
- **Aliases:** `ll`/`l` for detailed listing, `gs` git status, `gb` git branch, `c` jump to code directory, `dt` jump to desktop
- **FZF:** Auto-sourced if installed
- **History:** 10,000 entries, shared/incremental append
- **Keybindings:** Emacs mode, `Ctrl+X Ctrl+E` to edit command in `$EDITOR`

## iTerm2 (`iterm2/`)

Profiles, keymaps, and color schemes for iTerm2.

- **Font:** MesloLGM Nerd Font, 14pt
- **Terminal:** xterm-256color, unlimited scrollback
- **Color schemes (19):** Dracula, Gruvbox, Gabriel, Everforest (multiple variants), TokyoNight (4 variants), OneHalfDark, IcebergDark, Glacier, Github, FirefoxDev, Espresso, Alabaster
- **Features:** Blurred background, mouse reporting, Powerline glyphs, silent bell

## Mac Terminal (`Mac Terminal/`)

Dracula theme file (`Dracula.terminal`) importable into macOS Terminal.app.
