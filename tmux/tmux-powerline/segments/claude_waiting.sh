# shellcheck shell=bash
# Names the sessions holding a Claude agent that is waiting on you.
#
# With one session per worktree, a waiting agent in a detached session is easy
# to miss. This segment scans every pane and prints the other affected sessions.
# The current session is left out because this segment only reports elsewhere.
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
