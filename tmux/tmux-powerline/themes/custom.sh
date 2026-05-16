# shellcheck shell=bash
# Custom tmux-powerline theme.
# Sourced after defaults; values here win.
#
# Segment array format:
#   "segment_name bg_color fg_color [separator] [sep_bg] [sep_fg] [spacing] [sep_disable]"
# Colors are 0-255 (run ~/.tmux/plugins/tmux-powerline/color_palette.sh to preview).
# Available segments: ls ~/.tmux/plugins/tmux-powerline/segments/

# Patched-font separators (Iosevka Nerd Font Mono is in use).
# Encoded as $'\xHH...' UTF-8 byte sequences so the source file stays plain ASCII;
# bash expands them at theme-load time. Codepoints: U+E0B0–U+E0B3 (Powerline glyphs).
TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=$'\xee\x82\xb2'
TMUX_POWERLINE_SEPARATOR_LEFT_THIN=$'\xee\x82\xb3'
TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=$'\xee\x82\xb0'
TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=$'\xee\x82\xb1'

# Default colors when a segment doesn't specify them.
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR="235"
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR="255"

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR="$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD"
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR="$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD"

# Window list — preserves your λ (nvim) / ✦ (claude) / $ (shell) indicators
# from the original tmux.conf. The #{?#{m:...}} matcher inspects pane_current_command.
TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
	"#[$(tp_format regular)]"
	"  #{?#{m:nvim,#{pane_current_command}},λ,#{?#{m:claude,#{pane_current_command}},✦,$}} #I: #W "
)

TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
	"#[$(tp_format inverse)]"
	"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
	" #{?#{m:nvim,#{pane_current_command}},λ,#{?#{m:claude,#{pane_current_command}},✦,$}} #I: #W "
	"#[$(tp_format regular)]"
	"$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
)

TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
	"$(tp_format regular)"
)

# 20-char session-name truncation, matching the original tmux.conf.
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="#{=/20/…:session_name}"
export TMUX_POWERLINE_SEG_TIME_FORMAT="%l:%M %p"

# Left: green session badge transitioning into the window list.
TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
	"tmux_session_info 148 234"
)

TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
	"time 235 136"
)
