# tmux configuration

`tmux/tmux.conf` loads from the `~/.tmux.conf` wrapper.

`tmux/tmux-powerline/` links to `~/.config/tmux-powerline/`.

## Claude Code panes

The launcher runs a version-named Claude Code binary.

Therefore, `pane_current_command` can contain a value such as `2.1.226`.

Claude Code windows keep the name `claude`.

The outer terminal title uses the window name without the tmux session name.

Use `@_claude_pane` to identify a Claude Code pane.

The literal `#{m:claude,#{pane_current_command}}` match does not identify these panes.

## Session state

`tmux/claude-status.sh` receives events from hooks in `claude/settings.json`.

The script sets `@claude_state` for the active pane.

The `claude_waiting` segment lists other sessions with a `wait` pane.

The segment returns no output when no other session waits.

It filters `list-panes -f` against `@claude_state`.

It excludes the current session.

Inspect state with this command:

```sh
tmux list-panes -a -F '#{pane_id} [#{@claude_state}] #{window_name}'
```

The fixed `claude` window name does not indicate agent state.

## Agent edit history

`<prefix> e` opens `tmux/agent-edits.sh`.

The script shows an fzf picker for files edited by the agent in that pane.

`agents/hooks/format-edits.sh` appends paths to `~/.cache/agent-edits/<pane-id>`.

The hook records paths before formatter gates.

New sessions clear their history. Resumed sessions keep existing history.

Keep the leading `%` in the pane identifier.

The expression `#{s/%//:pane_id}` does not remove that character reliably.

Use `~/.cache` for hook and tmux server handoffs.

On macOS, `$TMPDIR` can differ between their process contexts.

## Popups

`<prefix> g` opens Lazygit in `#{pane_current_path}`.

`M-t` opens a shell in the same path.

Both commands use popups to preserve pane width.

`<prefix> t` opens the clock.

## Background sessions

Only agents launched inside a pane update that pane's state.

`claude-status.sh` targets `$TMUX_PANE`.

Background sessions do not inherit their own pane identifier.

Process tree traversal can find no pane or the parent agent's pane.

`claude --resume` rejects a session that a background agent still owns.

Use `claude agents` to reach or stop that session.

`~/.claude/daemon.log` records background claims as `bg claimed-spare <id> (<reason>)`.
