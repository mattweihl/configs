local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- When nvim opens with a directory argument (e.g. `vim .`), replace the
-- empty directory buffer with a clean buffer and open neo-tree automatically.
augroup("DirOpen", { clear = true })
autocmd("VimEnter", {
  group = "DirOpen",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" and vim.fn.isdirectory(bufname) == 1 then
      local buf = vim.api.nvim_get_current_buf()
      -- Create a clean empty buffer and wipe the directory buffer
      vim.cmd("enew")
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.api.nvim_set_current_dir(bufname)
      -- Defer neo-tree open so lazy.nvim has time to load it
      vim.defer_fn(function()
        require("lazy").load({ plugins = { "neo-tree.nvim" } })
        vim.cmd("Neotree toggle")
      end, 10)
    end
  end,
})

augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function(args)
    if vim.b[args.buf].large_file then return end
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
})

augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
  group = "ResizeSplits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
  group = "FileTypeIndent",
  pattern = { "python" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

augroup("LargeFile", { clear = true })
autocmd("BufReadPre", {
  group = "LargeFile",
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then
      vim.b[args.buf].large_file = true
      vim.opt_local.syntax = ""
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.cursorline = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      -- Disable treesitter highlighting for this buffer
      vim.schedule(function()
        pcall(vim.treesitter.stop, args.buf)
      end)
      -- Detach LSP clients (they choke on huge files)
      vim.schedule(function()
        for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
          client:detach(args.buf)
        end
      end)
    end
  end,
})


-- Dynamic right-click context menu (adapts based on LSP availability and buffer type)
local function build_right_click_menu()
  pcall(vim.cmd, "aunmenu PopUp")

  if vim.bo.filetype == "neo-tree" then
    return -- handled separately via vim.ui.select
  end

  -- Normal buffer context menu
  local has_lsp = #vim.lsp.get_clients({ bufnr = 0 }) > 0

  if has_lsp then
    vim.cmd("amenu PopUp.Go\\ to\\ Definition         <cmd>lua vim.lsp.buf.definition()<CR>")
    vim.cmd("amenu PopUp.Go\\ to\\ Definition\\ (Split) <cmd>lua vim.cmd('vsplit'); vim.lsp.buf.definition()<CR>")
    vim.cmd("amenu PopUp.Go\\ to\\ Type\\ Definition  <cmd>lua vim.lsp.buf.type_definition()<CR>")
    vim.cmd("amenu PopUp.Go\\ to\\ Implementations    <cmd>lua vim.lsp.buf.implementation()<CR>")
    vim.cmd("amenu PopUp.Go\\ to\\ References          <cmd>lua vim.lsp.buf.references()<CR>")
    vim.cmd("amenu PopUp.-sep1- :")
    vim.cmd("amenu PopUp.Find\\ All\\ References       <cmd>FzfLua lsp_references<CR>")
    vim.cmd("amenu PopUp.Show\\ Call\\ Hierarchy       <cmd>lua vim.lsp.buf.incoming_calls()<CR>")
    vim.cmd("amenu PopUp.-sep2- :")
    vim.cmd("amenu PopUp.Rename\\ Symbol               <cmd>lua vim.lsp.buf.rename()<CR>")
    vim.cmd("amenu PopUp.Format\\ Document             <cmd>lua require('conform').format({ async = true, lsp_format = 'fallback' })<CR>")
    vim.cmd("amenu PopUp.Code\\ Action                 <cmd>lua vim.lsp.buf.code_action()<CR>")
    vim.cmd("amenu PopUp.-sep3- :")
  end

  vim.cmd([[amenu PopUp.Cut         "+x]])
  vim.cmd([[amenu PopUp.Copy        "+y]])
  vim.cmd([[amenu PopUp.Paste       "+gP]])
  vim.cmd("amenu PopUp.-sep4- :")
  vim.cmd("amenu PopUp.Command\\ Palette              <cmd>FzfLua commands<CR>")
end

local function neo_tree_context_menu()
  local Menu = require("nui.menu")
  local event = require("nui.utils.autocmd").event

  local items = {
    Menu.item("  New File", { key = "a" }),
    Menu.item("  Rename", { key = "r" }),
    Menu.item("  Delete", { key = "d" }),
    Menu.separator(""),
    Menu.item("  Copy", { key = "y" }),
    Menu.item("  Cut", { key = "x" }),
    Menu.item("  Paste", { key = "p" }),
    Menu.separator(""),
    Menu.item("  Move", { key = "m" }),
  }

  local mouse = vim.fn.getmousepos()
  local menu = Menu({
    relative = "editor",
    position = {
      row = mouse.screenrow,
      col = mouse.screencol,
    },
    size = { width = 20 },
    border = {
      style = "rounded",
      padding = { 0, 1 },
    },
    win_options = {
      cursorline = true,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel",
    },
  }, {
    lines = items,
    keymap = {
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      close = { "<Esc>", "q", "<RightMouse>" },
      submit = { "<CR>" },
    },
    on_submit = function(item)
      vim.api.nvim_feedkeys(item.key, "m", false)
    end,
  })

  menu:mount()

  -- Custom left-click: move cursor to clicked line, then submit
  menu:map("n", "<LeftMouse>", function()
    vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
    vim.schedule(function()
      local ok, _ = pcall(vim.api.nvim_feedkeys, vim.keycode("<CR>"), "m", false)
      if not ok then menu:unmount() end
    end)
  end, { noremap = true })

  menu:on(event.BufLeave, function()
    menu:unmount()
  end)
end

-- Remove Neovim's default MenuPopup autocmd so it doesn't conflict with our custom menu
pcall(vim.api.nvim_del_augroup_by_name, "nvim.popupmenu")

vim.keymap.set("n", "<RightMouse>", function()
  vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
  vim.schedule(function()
    if vim.bo.filetype == "neo-tree" then
      neo_tree_context_menu()
      return
    end

    build_right_click_menu()
    vim.cmd("popup! PopUp")
  end)
end, { desc = "Context menu" })

-- Detect external file changes (e.g. Cursor Agent, Claude, or another process).
-- Two layers: (1) checktime on focus/enter/cursor-hold events, (2) native fs_event watchers
-- for real-time reload without user interaction.
augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "TermLeave", "WinEnter", "BufEnter" }, {
  group = "AutoReload",
  command = "checktime",
})
autocmd("FileChangedShellPost", {
  group = "AutoReload",
  callback = function()
    vim.notify("File changed on disk (e.g. by agent). Buffer reloaded.", vim.log.levels.INFO)
  end,
})

-- Native filesystem watcher: reload visible buffers when files change on disk.
-- Uses libuv fs_event for near-instant detection, independent of cursor/focus events.
local fs_watchers = {}

local function stop_watcher(bufnr)
  if fs_watchers[bufnr] then
    fs_watchers[bufnr]:stop()
    fs_watchers[bufnr] = nil
  end
end

local function start_watcher(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" or not vim.uv.fs_stat(path) then return end
  -- Skip special buffer types (diffview, neo-tree, help, etc.)
  local bt = vim.bo[bufnr].buftype
  if bt ~= "" then return end

  stop_watcher(bufnr)
  local handle = vim.uv.new_fs_event()
  if not handle then return end
  fs_watchers[bufnr] = handle

  handle:start(path, {}, function(err)
    if err then return end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        stop_watcher(bufnr)
        return
      end
      -- Skip if buffer has unsaved local changes
      if vim.bo[bufnr].modified then return end
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! checktime")
      end)
    end)
  end)
end

augroup("FsWatch", { clear = true })
autocmd("BufReadPost", {
  group = "FsWatch",
  callback = function(args) start_watcher(args.buf) end,
})
autocmd("BufDelete", {
  group = "FsWatch",
  callback = function(args) stop_watcher(args.buf) end,
})
autocmd("VimLeavePre", {
  group = "FsWatch",
  callback = function()
    for bufnr, _ in pairs(fs_watchers) do
      stop_watcher(bufnr)
    end
  end,
})

