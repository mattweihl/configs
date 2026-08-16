local M = {}

local watchers = {}

local function is_watchable(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return false
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local stat = path ~= "" and vim.uv.fs_stat(path) or nil
  return vim.bo[bufnr].buftype == "" and stat ~= nil and stat.type == "file"
end

function M.stop(bufnr)
  local handle = watchers[bufnr]
  if not handle then return end

  watchers[bufnr] = nil
  pcall(handle.stop, handle)
  if not handle:is_closing() then
    handle:close()
  end
end

function M.check(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then return end
  if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then return end
  vim.cmd.checktime({ args = { tostring(bufnr) }, mods = { silent = true } })
end

function M.start(bufnr)
  M.stop(bufnr)
  if not is_watchable(bufnr) then return end

  local handle = vim.uv.new_fs_event()
  if not handle then return end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local started = handle:start(path, {}, function()
    vim.defer_fn(function()
      if watchers[bufnr] ~= handle then return end
      if not vim.bo[bufnr].modified then M.check(bufnr) end
      if watchers[bufnr] == handle then
        M.start(bufnr)
      end
    end, 50)
  end)

  if not started then
    handle:close()
    return
  end

  watchers[bufnr] = handle
end

function M.is_watching(bufnr)
  return watchers[bufnr] ~= nil
end

function M.stop_all()
  local buffers = vim.tbl_keys(watchers)
  for _, bufnr in ipairs(buffers) do
    M.stop(bufnr)
  end
end

function M.setup()
  M.stop_all()
  local group = vim.api.nvim_create_augroup("FsWatch", { clear = true })

  vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, {
    group = group,
    command = "checktime",
  })
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = group,
    callback = function(args) M.check(args.buf) end,
  })
  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group,
    callback = function(args)
      vim.notify("File changed on disk. Neovim checked the buffer.", vim.log.levels.INFO)
      vim.defer_fn(function() M.start(args.buf) end, 50)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
    group = group,
    callback = function(args) M.start(args.buf) end,
  })
  vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args) M.stop(args.buf) end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = M.stop_all,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    M.start(bufnr)
  end
end

return M
