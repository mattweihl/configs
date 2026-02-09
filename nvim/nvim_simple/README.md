# Neovim Simple Config

Ultra-minimal Neovim configuration for text editing. Designed for environments where full plugin installation is slow or problematic (e.g., corporate networks, AWS sandboxes).

## What's Included

- **Syntax:** Treesitter for JS/TS/Python/HTML/CSS/JSON/Lua/Bash/YAML
- **Fuzzy Finding:** Telescope (Ctrl+P, live grep)
- **Editor:** Auto-pairs, comment toggling, surround
- **UI:** VS Code Dark+ theme, Lualine status bar, Which-Key hints

## What's Excluded

- LSP / Language servers (no go-to-definition, hover, rename, etc.)
- Completion (no autocomplete)
- File tree (neo-tree)
- Git integration (gitsigns, lazygit)
- Debugging (DAP)
- Terminal (toggleterm)
- Buffer tabs (barbar)
- Formatters/linters

## Usage

### Install
```bash
bash ~/Configs/nvim/setup.sh simple install
```

### Switch Back to Full Config
```bash
bash ~/Configs/nvim/setup.sh uninstall
bash ~/Configs/nvim/setup.sh install
```

## Plugin Count

~10 plugins total (vs ~40 in full config)
