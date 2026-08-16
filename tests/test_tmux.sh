#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOCKET="configs-test-$$"
TEMP_DIR="$(mktemp -d)"

cleanup() {
	tmux -L "$SOCKET" kill-server 2>/dev/null || true
	rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	exit 1
}

assert_equal() {
	local expected="$1"
	local actual="$2"
	local message="$3"

	[ "$actual" = "$expected" ] || fail "$message: expected '$expected', got '$actual'"
}

tmux_test() {
	tmux -L "$SOCKET" "$@"
}

wait_for_command() {
	local pane="$1"
	local expected="$2"
	local actual=''

	for _ in {1..50}; do
		actual="$(tmux_test display-message -p -t "$pane" '#{pane_current_command}')"
		[ "$actual" = "$expected" ] && return 0
		sleep 0.02
	done

	fail "pane command: expected '$expected', got '$actual'"
}

jq -e '
  .model == "opus"
  and (.skipDangerousModePermissionPrompt == null)
  and (.hooks.Notification[0].matcher == "permission_prompt|idle_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input")
  and (.hooks.PermissionRequest[0].hooks[0].command | endswith("claude-status.sh wait"))
  and (.hooks.Elicitation[0].hooks[0].command | endswith("claude-status.sh wait"))
  and (.hooks.ElicitationResult[0].hooks[0].command | endswith("claude-status.sh busy"))
  and (.hooks.PostToolUse[0].hooks[0].command | endswith("claude-status.sh busy"))
  and (.hooks.PostToolUseFailure[0].hooks[0].command | endswith("claude-status.sh busy"))
  and (.hooks.SessionStart[] | select(.matcher == "compact").hooks[0].command | endswith("claude-status.sh busy"))
  and (.hooks.StopFailure[0].hooks[0].command | endswith("claude-status.sh failed"))
  and ([.hooks[][]?.hooks[]? | select(.command | contains("claude-status.sh")) | has("async")] | any | not)
' "$ROOT/claude/settings.json" >/dev/null || fail 'Claude lifecycle hook configuration'

mkdir -p "$TEMP_DIR/bin"
cat >"$TEMP_DIR/wait.c" <<'EOF'
#include <unistd.h>

int main(void) {
	sleep(60);
	return 0;
}
EOF
cc "$TEMP_DIR/wait.c" -o "$TEMP_DIR/bin/claude"
cc "$TEMP_DIR/wait.c" -o "$TEMP_DIR/bin/2.1.226"
cc "$TEMP_DIR/wait.c" -o "$TEMP_DIR/bin/notclaude"

tmux_test -f "$ROOT/tmux/tmux.conf" new-session -d -s live "$TEMP_DIR/bin/claude 60"
live_pane="$(tmux_test list-panes -t live -F '#{pane_id}')"
wait_for_command "$live_pane" claude

version_pane="$(tmux_test split-window -d -P -F '#{pane_id}' -t "$live_pane" "$TEMP_DIR/bin/2.1.226 60")"
false_pane="$(tmux_test split-window -d -P -F '#{pane_id}' -t "$live_pane" "$TEMP_DIR/bin/notclaude 60")"
wait_for_command "$version_pane" 2.1.226
wait_for_command "$false_pane" notclaude

assert_equal 1 "$(tmux_test display-message -p -t "$live_pane" '#{E:@_claude_pane}')" 'claude command detection'
assert_equal 1 "$(tmux_test display-message -p -t "$version_pane" '#{E:@_claude_pane}')" 'version command detection'
assert_equal 0 "$(tmux_test display-message -p -t "$false_pane" '#{E:@_claude_pane}')" 'anchored command detection'
TMUX_POWERLINE_STATUS_INTERVAL=''
source "$ROOT/tmux/tmux-powerline/config.sh"
assert_equal 10 "$TMUX_POWERLINE_STATUS_INTERVAL" 'status interval configuration'

server="$(tmux_test display-message -p -t "$live_pane" '#{socket_path},#{pid},0')"
TMUX="$server" TMUX_PANE="$live_pane" "$ROOT/tmux/claude-status.sh" failed
assert_equal failed "$(tmux_test show-options -pqv -t "$live_pane" @claude_state)" 'failed state write'
assert_equal ✕ "$(tmux_test display-message -p -t "$live_pane" '#{E:@_claude_glyph}')" 'failed state glyph'

tmux_test set-option -p -t "$version_pane" @claude_state unexpected
assert_equal '?' "$(tmux_test display-message -p -t "$version_pane" '#{E:@_claude_glyph}')" 'unknown state glyph'

mkdir -p "$TEMP_DIR/daemon-bin"
cat >"$TEMP_DIR/daemon-bin/claude" <<'EOF'
#!/bin/sh
printf '%s\n' "$CLAUDE_TEST_AGENTS"
EOF
cat >"$TEMP_DIR/daemon-bin/fzf" <<'EOF'
#!/bin/sh
cat >"$FZF_CAPTURE"
exit 1
EOF
chmod +x "$TEMP_DIR/daemon-bin/claude" "$TEMP_DIR/daemon-bin/fzf"

tmux_test select-pane -t "$live_pane" -T unknown-agent
tmux_test select-pane -t "$version_pane" -T failed-agent
CLAUDE_TEST_AGENTS='[
  {"kind":"background","name":"unknown-agent","cwd":"/tmp/unknown","state":"new-state"},
  {"kind":"background","name":"failed-agent","cwd":"/tmp/failed","state":"failed"},
  {"kind":"background","name":"detached-agent","cwd":"/tmp/detached","state":"failed"},
  {"kind":"background","name":"detached-new","cwd":"/tmp/detached-new","state":"new-state"}
]'
FZF_CAPTURE="$TEMP_DIR/fzf-input"
export CLAUDE_TEST_AGENTS FZF_CAPTURE
PATH="$TEMP_DIR/daemon-bin:$PATH" TMUX="$server" "$ROOT/tmux/claude-agents.sh"
assert_equal unknown "$(tmux_test show-options -pqv -t "$live_pane" @claude_state)" 'unknown daemon state mapping'
assert_equal failed "$(tmux_test show-options -pqv -t "$version_pane" @claude_state)" 'failed daemon state mapping'
[[ "$(<"$FZF_CAPTURE")" == *failed*detached-agent* ]] || fail 'detached daemon state mapping'
[[ "$(<"$FZF_CAPTURE")" == *new-state* ]] || fail 'detached unknown state must stay verbatim'

tmux_test set-option -p -t "$false_pane" @claude_state wait
tmux_test set-option -p -t "$live_pane" @claude_state wait
waiting="$(tmux_test list-panes -a -f '#{&&:#{E:@_claude_pane},#{==:#{@claude_state},wait}}' -F '#{pane_id}')"
assert_equal "$live_pane" "$waiting" 'stale pane filtering'

tmux_test set-option -p -t "$live_pane" remain-on-exit on
tmux_test send-keys -t "$live_pane" C-c
for _ in {1..50}; do
	[ "$(tmux_test display-message -p -t "$live_pane" '#{pane_dead}')" = 1 ] && break
	sleep 0.02
done
assert_equal 0 "$(tmux_test display-message -p -t "$live_pane" '#{E:@_claude_pane}')" 'dead pane filtering'

printf 'tmux integration tests passed\n'
