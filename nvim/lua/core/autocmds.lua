local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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
  command = "%s/\\s\\+$//e",
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
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end)
    end
  end,
})


vim.cmd("amenu PopUp." .. "Search\\ Word             <cmd>lua require('telescope.builtin').grep_string()<CR>")

-- Detect external file changes (e.g. Cursor Agent, Claude, or another process).
-- checktime runs on focus/enter/cursor-hold; with autoread, unmodified buffers reload automatically.
augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = "AutoReload",
  command = "checktime",
})
autocmd("FileChangedShellPost", {
  group = "AutoReload",
  callback = function()
    vim.notify("File changed on disk (e.g. by agent). Buffer reloaded.", vim.log.levels.INFO)
  end,
})

