# shellcheck shell=bash
# tmux-powerline user config
# Loaded from ${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/config.sh
# (symlinked from this repo at ~/configs/tmux/tmux-powerline/)
# Reference: https://github.com/erikw/tmux-powerline#configuration

# Use the custom theme defined in themes/custom.sh next to this file.
export TMUX_POWERLINE_THEME="custom"

# Overlay dirs so this repo's theme/segment files are picked up.
export TMUX_POWERLINE_DIR_USER_THEMES="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/themes"
export TMUX_POWERLINE_DIR_USER_SEGMENTS="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/segments"

# Iosevka Nerd Font Mono in Ghostty — patched separators render correctly.
export TMUX_POWERLINE_PATCHED_FONT_IN_USE="true"

# Status bar refresh interval (seconds). 1 keeps the clock smooth; bump higher
# if any segments turn out to be expensive on your machine.
export TMUX_POWERLINE_STATUS_INTERVAL=1

# Window list left-aligned (after the left status segments).
export TMUX_POWERLINE_STATUS_JUSTIFICATION="left"

# Length caps. The defaults (60/90) are usually fine; raise if segments truncate.
export TMUX_POWERLINE_STATUS_LEFT_LENGTH=60
export TMUX_POWERLINE_STATUS_RIGHT_LENGTH=90

# Turn on debug output if a segment misbehaves.
# export TMUX_POWERLINE_DEBUG_MODE_ENABLED="true"
