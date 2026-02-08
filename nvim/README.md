# Neovim Config

Modular Lua-based Neovim 0.11+ configuration, designed to feel like VS Code/Cursor. Works on macOS and Linux (Debian 12). Runs in tmux, including over SSH.

## Setup

```bash
# Symlink only (install plugins manually inside nvim)
bash ~/Configs/nvim/setup.sh

# Symlink + install everything (plugins, LSPs, formatters, parsers)
bash ~/Configs/nvim/setup.sh install

# Use old config (vimscript + CoC)
bash ~/Configs/nvim/setup.sh old install

# Clean slate (remove symlink + all nvim data)
bash ~/Configs/nvim/setup.sh uninstall
```

The setup script creates a single symlink: `~/.config/nvim -> ~/Configs/nvim`

### Prerequisites

- Neovim 0.11+
- Git
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope live grep)
- A C compiler (`gcc` or `clang`) for Treesitter parser compilation
- Node.js (for prettier, eslint, ts_ls)
- Python 3 + pip (for black, isort, ruff, pyright)

**Optional:**
- A [Nerd Font](https://www.nerdfonts.com/) (off by default, see below)

### Nerd Font Support

Nerd Font icons are **off by default** for compatibility with terminals like macOS Terminal.app.

To enable, add this to your shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
export NVIM_NERD_FONT=1
```

This keeps the config repo unchanged across machines — just set the env var on machines that have a Nerd Font installed. All icon-using plugins (neo-tree, lualine, barbar, gitsigns, dap, diagnostics, devicons) respect this toggle automatically.

## Supported Languages

| Language | LSP Server | Formatter | Linter |
|---|---|---|---|
| JavaScript/TypeScript | ts_ls + eslint | prettier | eslint |
| Python | pyright | isort + black | ruff |
| HTML | html + emmet_ls | prettier | - |
| CSS/SCSS | cssls + tailwindcss | prettier | - |
| JSON | jsonls | prettier | - |
| Rust | rust_analyzer | rustfmt | clippy (via rust-analyzer) |
| C/C++ | clangd | clang-format | clang-tidy (via clangd) |
| Java | jdtls | google-java-format | - |
| Lua | lua_ls | stylua | - |
| YAML | - | prettier | - |
| Markdown | - | prettier | - |

Treesitter parsers are installed for all of the above plus bash, toml, regex, vim, vimdoc, gitignore, and diff.

## Keybindings

Leader key is **Space**. Press `<Space>?` to open the which-key modal showing all available keybindings.

### General

| Key | Mode | Action |
|---|---|---|
| `jk` | Insert | Exit insert mode |
| `<Space>ww` | Normal | Save |
| `<Space>q` | Normal | Quit |
| `<Space>qq` | Normal | Quit all |
| `<Space>wq` | Normal | Save and quit all |
| `<CR>` | Normal | Clear search highlight |
| `<C-a>` | Normal | Select all |

### Navigation

| Key | Mode | Action |
|---|---|---|
| `<C-h/j/k/l>` | Normal | Move between windows |
| `<C-Up/Down/Left/Right>` | Normal | Resize windows |
| `<S-h>` | Normal | Previous buffer |
| `<S-l>` | Normal | Next buffer |
| `<Space>bc` | Normal | Close buffer |
| `<Space>bp` | Normal | Pin buffer |

### Editing

| Key | Mode | Action |
|---|---|---|
| `<A-j>` / `<A-k>` | Normal/Visual | Move line(s) up/down |
| `<` / `>` | Visual | Indent (stays in visual mode) |
| `gcc` | Normal | Toggle line comment |
| `gc` | Normal/Visual | Toggle comment |
| `gbc` | Normal | Toggle block comment |
| `<C-d>` | Normal | Multi-cursor (select next match) |
| `ys{motion}{char}` | Normal | Add surround |
| `ds{char}` | Normal | Delete surround |
| `cs{old}{new}` | Normal | Change surround |
| `s` | Normal | Flash jump |
| `S` | Normal | Flash treesitter select |

### Treesitter Textobjects

| Key | Mode | Action |
|---|---|---|
| `af` / `if` | Visual/Operator | Select function (outer/inner) |
| `ac` / `ic` | Visual/Operator | Select class (outer/inner) |
| `aa` / `ia` | Visual/Operator | Select parameter (outer/inner) |
| `]f` / `[f` | Normal | Next/previous function |
| `]c` / `[c` | Normal | Next/previous class |
| `<Space>xp` | Normal | Swap next parameter |
| `<Space>xP` | Normal | Swap previous parameter |

### Find (Telescope)

| Key | Mode | Action |
|---|---|---|
| `<C-p>` / `<Space>ff` | Normal | Find files |
| `<Space>fg` | Normal | Live grep |
| `<Space>fb` | Normal | Buffers |
| `<Space>fr` | Normal | Recent files |
| `<Space>fs` | Normal | Grep word under cursor |
| `<Space>fd` | Normal | Diagnostics |
| `<Space>fh` | Normal | Help tags |
| `<Space>fk` | Normal | Keymaps |
| `<Space>fc` | Normal | Command palette |
| `<Space>fo` | Normal | Document symbols |
| `<Space>fw` | Normal | Workspace symbols |
| `<Space>ft` | Normal | Colorschemes |

### LSP

| Key | Mode | Action |
|---|---|---|
| `gd` | Normal | Go to definition |
| `gy` | Normal | Go to type definition |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Show references |
| `gD` | Normal | Go to declaration |
| `K` | Normal | Hover documentation |
| `<C-k>` | Normal/Insert | Signature help |
| `<Space>rn` | Normal | Rename symbol |
| `<Space>ca` | Normal/Visual | Code action |
| `<Space>cl` | Normal | Code lens |
| `<Space>cd` | Normal | Line diagnostics |
| `[g` / `]g` | Normal | Previous/next diagnostic |
| `<Space>cf` | Normal/Visual | Format file or selection |

### Git

| Key | Mode | Action |
|---|---|---|
| `]h` / `[h` | Normal | Next/previous git hunk |
| `<Space>hs` | Normal | Stage hunk |
| `<Space>hr` | Normal | Reset hunk |
| `<Space>hp` | Normal | Preview hunk inline |
| `<Space>hb` | Normal | Blame line (full) |
| `<Space>hd` | Normal | Diff this |

### Debugger

| Key | Mode | Action |
|---|---|---|
| `<Space>db` | Normal | Toggle breakpoint |
| `<Space>dB` | Normal | Conditional breakpoint |
| `<Space>dc` | Normal | Continue / start |
| `<Space>di` | Normal | Step into |
| `<Space>do` | Normal | Step over |
| `<Space>dO` | Normal | Step out |
| `<Space>dr` | Normal | Toggle REPL |
| `<Space>dl` | Normal | Run last |
| `<Space>dt` | Normal | Terminate |
| `<Space>du` | Normal | Toggle DAP UI |

### File Explorer (Neo-tree)

| Key | Mode | Action |
|---|---|---|
| `<C-n>` | Normal | Toggle file explorer |
| `<Space>e` | Normal | Toggle file explorer |
| `<Space>ge` | Normal | Git status explorer |

## File Structure

```
nvim/
├── init.lua                    # Bootstrap lazy.nvim, load core modules
├── setup.sh                    # Setup/install/uninstall script
├── lua/
│   ├── core/
│   │   ├── options.lua         # Editor settings, Nerd Font toggle
│   │   ├── keymaps.lua         # Global keybindings
│   │   └── autocmds.lua        # Autocommands
│   └── plugins/
│       ├── lsp.lua             # LSP servers (native vim.lsp.config API)
│       ├── cmp.lua             # Completion (nvim-cmp + LuaSnip)
│       ├── telescope.lua       # Fuzzy finder + command palette
│       ├── treesitter.lua      # Syntax highlighting + textobjects
│       ├── format-lint.lua     # Formatting (conform) + linting (nvim-lint)
│       ├── neo-tree.lua        # File explorer
│       ├── ui.lua              # Colorscheme, statusline, tabs, icons
│       ├── git.lua             # Gitsigns
│       ├── dap.lua             # Debugger (DAP + DAP UI + Mason DAP)
│       ├── edgy.lua            # Panel layout manager
│       ├── editor.lua          # Autopairs, comments, surround, multi-cursor
│       └── which-key.lua       # Keybinding hints modal
└── README.md
```

## External File Changes (AI Agents / Tmux)

Buffers auto-reload when files are changed externally (e.g. by cursor-agent running in another tmux pane). This triggers on:
- Switching back to the nvim tmux pane (`FocusGained`)
- Switching buffers (`BufEnter`)
- Idling for 250ms (`CursorHold`)

A notification appears when a buffer is reloaded from disk.

## Tmux Compatibility

Requires these settings in your tmux config for clipboard (OSC 52) support:

```tmux
set-option -g allow-passthrough on
set-option -g set-clipboard on
```

## Useful Commands

| Command | Action |
|---|---|
| `:Lazy` | Plugin manager (install/update/profile) |
| `:Mason` | LSP/formatter/linter installer |
| `:checkhealth` | Verify everything is working |
| `:ConformInfo` | Check formatter status for current file |
| `:LspInfo` | Check active LSP servers |
| `:TSInstall {lang}` | Install a treesitter parser |

## Colorscheme

Default is **gruvbox** (hard contrast). Browse available themes with `<Space>ft`.
