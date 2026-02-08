#!/usr/bin/env bash
set -euo pipefail

CONFIGS_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[0;34m%s\033[0m\n' "$1"; }
warn() { printf '\033[0;33m%s\033[0m\n' "$1"; }
ok()   { printf '\033[0;32m%s\033[0m\n' "$1"; }

backup() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up $target → $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        rm "$target"
    fi
}

# Neovim — symlink
info "Setting up Neovim..."
mkdir -p ~/.config
backup ~/.config/nvim
ln -s "$CONFIGS_DIR/nvim" ~/.config/nvim
ok "  ~/.config/nvim → $CONFIGS_DIR/nvim"

# Zsh — add source line to ~/.zshrc
info "Setting up Zsh..."
ZSHRC_SOURCE="source $CONFIGS_DIR/zsh/zshrc"
if [ -f ~/.zshrc ] && grep -qF "$ZSHRC_SOURCE" ~/.zshrc; then
    ok "  ~/.zshrc already sources configs"
else
    echo "" >> ~/.zshrc
    echo "# Shared configs" >> ~/.zshrc
    echo "$ZSHRC_SOURCE" >> ~/.zshrc
    ok "  Added source line to ~/.zshrc"
fi

# Tmux — add source-file line to ~/.tmux.conf
info "Setting up Tmux..."
TMUX_SOURCE="source-file $CONFIGS_DIR/tmux/tmux.conf"
if [ -f ~/.tmux.conf ] && grep -qF "$TMUX_SOURCE" ~/.tmux.conf; then
    ok "  ~/.tmux.conf already sources configs"
else
    touch ~/.tmux.conf
    echo "" >> ~/.tmux.conf
    echo "# Shared configs" >> ~/.tmux.conf
    echo "$TMUX_SOURCE" >> ~/.tmux.conf
    ok "  Added source-file line to ~/.tmux.conf"
fi

# iTerm2 / Mac Terminal — manual step
info "iTerm2 & Mac Terminal..."
ok "  Color schemes in $CONFIGS_DIR/iterm2/ — import manually via iTerm2 Preferences > Profiles > Colors"
ok "  Mac Terminal theme in $CONFIGS_DIR/Mac Terminal/ — double-click to import"

echo ""
ok "Done! Restart your shell or run: source ~/.zshrc"
