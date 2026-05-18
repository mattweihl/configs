#!/usr/bin/env bash
# Wraps the Cursor Agent CLI to manage tmux window naming:
#   1. Immediately renames the window to "agent"
#   2. Polls the session's SQLite store for its name (picks up /rename too)
#   3. Resets automatic-rename when agent exits
#
# Called by the agent() shell function defined in zsh/config.zsh.
# Falls through to the real binary when not inside tmux.

set -euo pipefail

AGENT_BIN=$(command -v agent)

POLL_INTERVAL=5
MAX_TITLE_LEN=20
SKIP_NAMES="agent chat|new|new agent"
PREFIX="✦ "

if [[ -z "${TMUX:-}" ]]; then
    exec "$AGENT_BIN" "$@"
fi

for arg in "$@"; do
    case "$arg" in
        --version|-v|--help|-h|--list-models|-p|--print)
            exec "$AGENT_BIN" "$@" ;;
    esac
done

WINDOW_ID=$(tmux display-message -p '#{window_id}')
tmux rename-window -t "$WINDOW_ID" "${PREFIX}agent"
tmux set-window-option -t "$WINDOW_ID" automatic-rename off

# Session metadata lives in ~/.cursor/chats/<md5-of-workspace>/<uuid>/store.db.
# The meta table holds a hex-encoded JSON blob with a "name" field.
workspace_hash=$(echo -n "${PWD}" | md5 2>/dev/null || echo -n "${PWD}" | md5sum | cut -d' ' -f1)
chats_dir="$HOME/.cursor/chats/$workspace_hash"

extract_session_name() {
    local latest
    latest=$(ls -t "$chats_dir"/*/store.db 2>/dev/null | head -1) || return 1
    [[ -z "$latest" ]] && return 1

    local hex
    hex=$(sqlite3 "$latest" "SELECT * FROM meta;" 2>/dev/null | cut -d'|' -f2)
    [[ -z "$hex" ]] && return 1

    python3 -c "
import sys, json
raw = bytes.fromhex(sys.argv[1])
name = json.loads(raw).get('name', '')
skip = {s.strip() for s in sys.argv[2].split('|')}
if not name or name.lower() in skip:
    sys.exit(1)
print(name[:int(sys.argv[3])])
" "$hex" "$SKIP_NAMES" "$MAX_TITLE_LEN" 2>/dev/null
}

poll_for_title() {
    set +e
    local current=""
    sleep 3
    while true; do
        local title
        title=$(extract_session_name)
        if [[ -n "$title" && "$title" != "$current" ]]; then
            tmux rename-window -t "$WINDOW_ID" "${PREFIX}${title}"
            current="$title"
        fi
        sleep "$POLL_INTERVAL"
    done
}

poll_for_title &
POLLER_PID=$!

cleanup() {
    kill "$POLLER_PID" 2>/dev/null || true
    wait "$POLLER_PID" 2>/dev/null || true
    tmux set-window-option -t "$WINDOW_ID" automatic-rename on 2>/dev/null || true
}
trap cleanup EXIT

"$AGENT_BIN" "$@"
