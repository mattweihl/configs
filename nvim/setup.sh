#!/bin/bash
# Neovim Config Setup
# Run this on any new machine (macOS or Linux) to link the config and install everything
#
# Usage:
#   bash ~/Configs/nvim/setup.sh                  # symlink new (lua) config
#   bash ~/Configs/nvim/setup.sh install          # symlink new config + install plugins/parsers/LSPs
#   bash ~/Configs/nvim/setup.sh old              # symlink old (vimscript + CoC) config
#   bash ~/Configs/nvim/setup.sh old install      # symlink old config + install plugins
#   bash ~/Configs/nvim/setup.sh uninstall        # remove symlink + all nvim data (clean slate)

set -e

CONFIGS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NVIM_NEW="$CONFIGS_DIR/nvim"
NVIM_OLD="$CONFIGS_DIR/nvim/nvim_old"
TARGET="$HOME/.config/nvim"

# --- Uninstall ---
if [ "$1" = "uninstall" ]; then
  echo "=== Neovim Config Uninstall ==="
  echo ""

  # Show which config is currently linked
  if [ -L "$TARGET" ]; then
    current="$(readlink "$TARGET")"
    echo "Current symlink: $TARGET -> $current"
  fi

  echo ""
  echo "This will remove:"
  echo "  - $TARGET (symlink)"
  echo "  - ~/.local/share/nvim  (plugins, mason, parsers)"
  echo "  - ~/.local/state/nvim  (shada, swap, undo, log)"
  echo "  - ~/.cache/nvim        (cache)"
  echo ""
  read -p "Are you sure? (y/N) " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
  fi

  echo ""
  [ -L "$TARGET" ] && rm "$TARGET" && echo "Removed symlink: $TARGET"
  [ -e "$TARGET" ] && rm -rf "$TARGET" && echo "Removed config dir: $TARGET"
  [ -d "$HOME/.local/share/nvim" ] && rm -rf "$HOME/.local/share/nvim" && echo "Removed: ~/.local/share/nvim"
  [ -d "$HOME/.local/state/nvim" ] && rm -rf "$HOME/.local/state/nvim" && echo "Removed: ~/.local/state/nvim"
  [ -d "$HOME/.cache/nvim" ] && rm -rf "$HOME/.cache/nvim" && echo "Removed: ~/.cache/nvim"

  echo ""
  echo "=== Clean slate. Run 'bash ~/Configs/nvim/setup.sh install' to reinstall. ==="
  exit 0
fi

# --- Determine which config to use ---
USE_OLD=false
if [ "$1" = "old" ]; then
  USE_OLD=true
  shift  # consume "old" so $1 becomes "install" if provided
fi

if $USE_OLD; then
  NVIM_SOURCE="$NVIM_OLD"
  CONFIG_LABEL="old (vimscript + CoC)"
else
  NVIM_SOURCE="$NVIM_NEW"
  CONFIG_LABEL="new (lua + lazy.nvim)"
fi

# Verify source exists
if [ ! -d "$NVIM_SOURCE" ]; then
  echo "Error: config directory not found: $NVIM_SOURCE"
  exit 1
fi

# --- Setup ---
echo "=== Neovim Config Setup ($CONFIG_LABEL) ==="
echo "  Source: $NVIM_SOURCE"
echo "  Target: $TARGET"
echo ""

mkdir -p "$HOME/.config"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "[1/4] Backing up existing config to $TARGET.bak"
  mv "$TARGET" "$TARGET.bak"
elif [ -L "$TARGET" ]; then
  current="$(readlink "$TARGET")"
  echo "[1/4] Removing existing symlink ($current)"
  rm "$TARGET"
else
  echo "[1/4] No existing config found"
fi

ln -s "$NVIM_SOURCE" "$TARGET"
echo "  Symlink created: $TARGET -> $NVIM_SOURCE"

# --- Install everything ---
if [ "$1" = "install" ]; then
  if $USE_OLD; then
    # Old config: vim-plug + CoC
    echo ""
    echo "[2/4] Installing plugins via vim-plug..."
    nvim --headless +PlugInstall +qa 2>/dev/null || nvim +PlugInstall +qa
    echo "  Plugins installed."

    echo ""
    echo "[3/4] Building coc.nvim..."
    COC_DIR="$HOME/.local/share/nvim/plugged/coc.nvim"
    if [ -d "$COC_DIR" ]; then
      if command -v npm &> /dev/null; then
        cd "$COC_DIR"
        npm ci --silent
        echo "  coc.nvim built successfully."
      else
        echo "  Warning: npm not found. Install Node.js and run 'cd $COC_DIR && npm ci' manually."
      fi
    else
      echo "  Warning: coc.nvim not found at $COC_DIR"
    fi

    echo ""
    echo "[4/4] Skipped (no Treesitter in old config)"

    echo ""
    echo "=== All done! (old config) ==="
    echo "Installed: vim-plug plugins, coc.nvim"
    echo ""
    echo "Inside nvim, run :CocInstall for any language extensions you need."
  else
    # New config: lazy.nvim + Mason + Treesitter
    echo ""
    echo "[2/4] Installing plugins via lazy.nvim..."
    nvim --headless "+Lazy! sync" +qa
    echo "  Plugins installed."

    echo ""
    echo "[3/4] Installing LSP servers and formatters via Mason..."
    nvim --headless -c "Lazy load mason-tool-installer.nvim" -c "MasonToolsInstall" -c "sleep 45" -c "qa"
    echo "  Mason tools installed."

    echo ""
    echo "[4/4] Installing treesitter parsers (this takes a minute)..."
    PARSERS="javascript typescript tsx python html css scss json jsonc bash yaml toml regex gitignore diff rust c cpp java"
    for parser in $PARSERS; do
      echo "  Installing $parser..."
      nvim --headless \
        -c "Lazy load nvim-treesitter" \
        -c "TSInstall! $parser" \
        -c "sleep 15" \
        -c "qa" 2>/dev/null || echo "  Warning: $parser may need manual install (:TSInstall $parser)"
    done
    echo "  Treesitter parsers installed."

    echo ""
    echo "=== All done! ==="
    echo "Installed: plugins, LSP servers, formatters/linters, treesitter parsers"
    echo ""
    echo "Verify inside nvim:"
    echo "  :Lazy          -- plugin status"
    echo "  :Mason         -- LSP/formatter status"
    echo "  :checkhealth   -- overall health check"
  fi
else
  echo ""
  echo "Symlink created. To install everything, run:"
  if $USE_OLD; then
    echo "  bash ~/Configs/nvim/setup.sh old install"
  else
    echo "  bash ~/Configs/nvim/setup.sh install"
  fi
  echo ""
  echo "To switch configs:"
  echo "  bash ~/Configs/nvim/setup.sh uninstall"
  if $USE_OLD; then
    echo "  bash ~/Configs/nvim/setup.sh install        # switch to new config"
  else
    echo "  bash ~/Configs/nvim/setup.sh old install    # switch to old config"
  fi
fi
