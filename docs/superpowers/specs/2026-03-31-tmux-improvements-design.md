# Tmux Config Improvements

## Context

The user runs a multi-window tmux workflow:
- Neovim + Claude side-by-side (50/50 vertical split) for active code work
- A fullscreen clawd window for general repo questions
- A general shell window for misc commands

Pain points: windows look the same in the status bar, and navigating between neovim splits and tmux panes requires different keybindings.

## Changes

### 1. Smart window labels with icons

Replace the static `window-status-format` and `window-status-current-format` with conditional formats that show:

- An icon based on the running process:
  - `λ` for nvim
  - `✦` for claude/clawd
  - `$` for any other shell
- The window index and name
- The basename of the pane's current directory

Detection uses `#{pane_current_command}` with tmux's `#{m:pattern,string}` matching. An exact match on `claude` covers both `claude` and `clawd` since `clawd` is a shell function that runs `command claude` — the underlying process name is `claude` in both cases.

Directory uses `#{b:pane_current_path}` to show only the basename (e.g. `dashboards` not `/Users/mattweihl/dashboards`).

### 2. Dev layout keybinding (`prefix + D`)

A single keybinding that creates a new window pre-split into a 50/50 vertical layout:

```
bind D split-window -h -l 50% -c "#{pane_current_path}"
```

Both panes inherit the current working directory. Panes are left empty for the user to launch nvim/claude/clawd as needed.

### 3. Seamless Ctrl+h/j/k/l navigation

Unify navigation across tmux panes and neovim splits so `Ctrl+h/j/k/l` works seamlessly regardless of context.

**Tmux side:**

Bind `Ctrl+h/j/k/l` globally (`-n`, no prefix). Each binding checks if the active pane is running vim/neovim:
- If yes: forward the key to neovim (neovim handles its own window navigation)
- If no: tmux handles pane navigation directly

Detection uses `ps` to check the pane's foreground process against vim/neovim patterns.

```
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
```

**Neovim side:**

Install `christoomey/vim-tmux-navigator` as a lazy.nvim plugin. This plugin:
- Replaces the existing `Ctrl+h/j/k/l` keymaps in neovim
- When at the edge of neovim's splits, sends navigation to tmux instead of doing nothing
- Remove the manual `Ctrl+h/j/k/l` mappings from `core/keymaps.lua` (the plugin handles them)

## Files to modify

- `tmux/tmux.conf` — window-status formats, `prefix + D` binding, `Ctrl+h/j/k/l` bindings
- `nvim/lua/plugins/` — new plugin file for vim-tmux-navigator
- `nvim/lua/core/keymaps.lua` — remove existing `Ctrl+h/j/k/l` window navigation mappings
