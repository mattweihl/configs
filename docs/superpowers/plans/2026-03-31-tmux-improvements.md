# Tmux Config Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve tmux status bar clarity with process-aware icons and directory names, add a dev layout shortcut, and unify Ctrl+h/j/k/l navigation across tmux panes and neovim splits.

**Architecture:** Three independent changes to tmux.conf (smart labels, layout binding, seamless nav bindings) plus one neovim plugin addition and one keymaps cleanup. The tmux nav bindings and neovim plugin work together — tmux detects vim and forwards keys, the plugin handles edge-of-split navigation back to tmux.

**Tech Stack:** tmux 3.6a, neovim with lazy.nvim, christoomey/vim-tmux-navigator plugin

---

### Task 1: Smart window labels with process icons

**Files:**
- Modify: `tmux/tmux.conf:45-46` (window-status-format and window-status-current-format)

- [ ] **Step 1: Replace window-status-format with icon-aware conditional**

In `tmux/tmux.conf`, replace these two lines:

```
set -g window-status-format "  #I: #W  "
set -g window-status-current-format "  #I: #W  "
```

With:

```
set -g window-status-format "  #{?#{m:nvim,#{pane_current_command}},λ,#{?#{m:claude,#{pane_current_command}},✦,$}} #I: #W #{b:pane_current_path}  "
set -g window-status-current-format "  #{?#{m:nvim,#{pane_current_command}},λ,#{?#{m:claude,#{pane_current_command}},✦,$}} #I: #W #{b:pane_current_path}  "
```

The conditional logic:
- If `pane_current_command` matches `nvim` → show `λ`
- Else if it matches `claude` → show `✦`
- Else → show `$`

`#{b:pane_current_path}` appends the directory basename (e.g. `dashboards`).

- [ ] **Step 2: Reload tmux and verify**

Run: `tmux source-file ~/.tmux.conf`

Verify: status bar shows `$` icon for shell windows. Open nvim in a pane and confirm it switches to `λ`. The directory basename should appear after the window name.

- [ ] **Step 3: Commit**

```bash
git add tmux/tmux.conf
git commit -m "Add process-aware icons and directory to tmux status bar"
```

---

### Task 2: Dev layout keybinding (prefix + D)

**Files:**
- Modify: `tmux/tmux.conf` (add binding after the existing split bindings around line 53)

- [ ] **Step 1: Add the prefix + D binding**

In `tmux/tmux.conf`, after the line `bind % split-window -h -c "#{pane_current_path}"`, add:

```
bind D split-window -h -l 50% -c "#{pane_current_path}"
```

- [ ] **Step 2: Reload tmux and verify**

Run: `tmux source-file ~/.tmux.conf`

Test: press `prefix + D`. Verify it creates a 50/50 vertical split with both panes in the same directory.

- [ ] **Step 3: Commit**

```bash
git add tmux/tmux.conf
git commit -m "Add prefix+D keybinding for 50/50 dev split layout"
```

---

### Task 3: Seamless Ctrl+h/j/k/l navigation — tmux side

**Files:**
- Modify: `tmux/tmux.conf:55-59` (replace existing vi-style pane nav bindings)

- [ ] **Step 1: Replace prefix-based pane nav with vim-aware global bindings**

In `tmux/tmux.conf`, replace this block:

```
# vi-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

With:

```
# seamless navigation across tmux panes and neovim splits
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
```

The `-n` flag means no prefix needed. The `is_vim` check uses `ps` to inspect the foreground process of the active pane. If it's vim/neovim, the keypress is forwarded to vim. Otherwise, tmux handles pane selection directly.

- [ ] **Step 2: Reload tmux and verify tmux-side navigation**

Run: `tmux source-file ~/.tmux.conf`

Test with two non-vim panes side by side: `Ctrl+h` and `Ctrl+l` should move between them without pressing prefix first. Verify `Ctrl+j` and `Ctrl+k` work for vertical splits too.

- [ ] **Step 3: Commit**

```bash
git add tmux/tmux.conf
git commit -m "Add vim-aware Ctrl+h/j/k/l pane navigation to tmux"
```

---

### Task 4: Seamless Ctrl+h/j/k/l navigation — neovim side

**Files:**
- Create: `nvim/lua/plugins/tmux-navigator.lua`
- Modify: `nvim/lua/core/keymaps.lua:17-20` (remove old Ctrl+h/j/k/l mappings)

- [ ] **Step 1: Create the vim-tmux-navigator plugin file**

Create `nvim/lua/plugins/tmux-navigator.lua`:

```lua
return {
  "christoomey/vim-tmux-navigator",
  event = "VeryLazy",
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move to left window/pane" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Move to below window/pane" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Move to above window/pane" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Move to right window/pane" },
  },
}
```

The `keys` table serves dual purpose in lazy.nvim: it defines the keymaps AND lazy-loads the plugin only when one of these keys is first pressed.

- [ ] **Step 2: Remove old Ctrl+h/j/k/l mappings from keymaps.lua**

In `nvim/lua/core/keymaps.lua`, delete these four lines:

```lua
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
```

The vim-tmux-navigator plugin now owns these bindings.

- [ ] **Step 3: Verify end-to-end navigation**

Open a tmux split with neovim on one side and a shell on the other. Inside neovim, press `Ctrl+l` — it should jump to the shell pane. From the shell pane, press `Ctrl+h` — it should jump back to neovim. If neovim has multiple internal splits, `Ctrl+h/l` should navigate through them first, then cross to the tmux pane at the edge.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/tmux-navigator.lua nvim/lua/core/keymaps.lua
git commit -m "Add vim-tmux-navigator for seamless pane/split navigation"
```
