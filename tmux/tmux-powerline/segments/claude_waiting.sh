# shellcheck shell=bash
# Names the sessions holding a Claude agent that is waiting on you.
#
# The ◍ glyph from @_claude_glyph lands in a *window name*, so it is only
# visible from the session you are attached to. With one session per worktree,
# an agent that stops to ask a question in a detached session waits unseen
# until you happen to open `<prefix> a`. This segment scans every pane on the
# server and prints where to go.
#
# The current session is left out: its window name already carries the glyph.
# When nothing is waiting the segment prints nothing, and tmux-powerline drops
# an empty segment from the status line rather than rendering an empty block.

run_segment() {
	local here waiting
	here="$(tmux display-message -p '#{session_name}')"

	# -f reuses tmux's own comparison against the per-pane @claude_state that
	# tmux/claude-status.sh writes. Do not re-implement the state vocabulary
	# here; tmux.conf owns it.
	waiting="$(tmux list-panes -a -f '#{&&:#{E:@_claude_pane},#{==:#{@claude_state},wait}}' -F '#{session_name}' |
		grep -vxF -e "$here" | sort -u | paste -sd, -)"

	[ -n "$waiting" ] || return 0

	# Segment output is expanded again as a tmux format, so an undoubled `#` in
	# a session name truncates the status line at that character.
	printf '◍ %s\n' "${waiting//\#/\#\#}"
	return 0
}
