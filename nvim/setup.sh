#!/bin/bash
# Neovim Config Setup
# Run this on any new machine (macOS or Linux) to link the config and install everything
#
# Usage:
#   bash ~/Configs/nvim/setup.sh              # symlink only
#   bash ~/Configs/nvim/setup.sh install      # symlink + install all plugins/parsers/LSPs/formatters
#   bash ~/Configs/nvim/setup.sh uninstall    # remove symlink + all nvim data (clean slate)

set -e

CONFIGS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NVIM_CONFIG="$CONFIGS_DIR/nvim"
TARGET="$HOME/.config/nvim"

# --- Uninstall ---
if [ "$1" = "uninstall" ]; then
  echo "=== Neovim Config Uninstall ==="
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

# --- Setup ---
echo "=== Neovim Config Setup ==="
echo "  Source: $NVIM_CONFIG"
echo "  Target: $TARGET"
echo ""

mkdir -p "$HOME/.config"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "[1/4] Backing up existing config to $TARGET.bak"
  mv "$TARGET" "$TARGET.bak"
elif [ -L "$TARGET" ]; then
  echo "[1/4] Removing existing symlink"
  rm "$TARGET"
else
  echo "[1/4] No existing config found"
fi

ln -s "$NVIM_CONFIG" "$TARGET"
echo "  Symlink created: $TARGET -> $NVIM_CONFIG"

# --- Install everything ---
if [ "$1" = "install" ]; then
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
else
  echo ""
  echo "Symlink created. To install everything, run:"
  echo "  bash ~/Configs/nvim/setup.sh install"
  echo ""
  echo "Or install manually inside nvim:"
  echo "  :Lazy sync              -- install plugins"
  echo "  :MasonToolsInstall      -- install LSPs + formatters"
  echo "  :TSInstall all          -- install treesitter parsers"
fi
