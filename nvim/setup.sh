#!/bin/bash
# Neovim Config Setup
# Run this on any new machine (macOS or Linux) to link the config and install everything
#
# Usage:
#   bash ~/Configs/nvim/setup.sh           # symlink config
#   bash ~/Configs/nvim/setup.sh install   # symlink config + install plugins/parsers
#   bash ~/Configs/nvim/setup.sh uninstall # remove symlink + all nvim data (clean slate)

set -e

NVIM_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.config/nvim"

# --- Uninstall ---
if [ "$1" = "uninstall" ]; then
  echo "=== Neovim Config Uninstall ==="
  echo ""

  if [ -L "$TARGET" ]; then
    current="$(readlink "$TARGET")"
    echo "Current symlink: $TARGET -> $current"
  fi

  echo ""
  echo "This will remove:"
  echo "  - $TARGET (symlink)"
  echo "  - ~/.local/share/nvim  (plugins, parsers)"
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
echo "  Source: $NVIM_DIR"
echo "  Target: $TARGET"
echo ""

mkdir -p "$HOME/.config"

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
  echo "[1/3] Backing up existing config to $TARGET.bak"
  mv "$TARGET" "$TARGET.bak"
elif [ -L "$TARGET" ]; then
  current="$(readlink "$TARGET")"
  echo "[1/3] Removing existing symlink ($current)"
  rm "$TARGET"
else
  echo "[1/3] No existing config found"
fi

ln -s "$NVIM_DIR" "$TARGET"
echo "  Symlink created: $TARGET -> $NVIM_DIR"

# --- Install ---
if [ "$1" = "install" ]; then
  echo ""
  echo "[2/3] Installing plugins via lazy.nvim..."
  nvim --headless "+Lazy! sync" +qa
  echo "  Plugins installed."

  echo ""
  echo "[3/3] Installing treesitter parsers..."
  PARSERS="javascript typescript tsx python html css json lua bash yaml"
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
  echo "Installed: plugins, treesitter parsers"
  echo ""
  echo "Verify inside nvim:"
  echo "  :Lazy          -- plugin status"
  echo "  :checkhealth   -- overall health check"
else
  echo ""
  echo "Symlink created. To install plugins and parsers, run:"
  echo "  bash ~/Configs/nvim/setup.sh install"
fi
