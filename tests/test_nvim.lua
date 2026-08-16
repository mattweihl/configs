local failures = {}

local function expect(condition, message)
  if not condition then
    table.insert(failures, message)
  end
end

local function expect_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    table.insert(failures, string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function temp_file(extension, lines)
  local path = vim.fn.tempname() .. extension
  vim.fn.writefile(lines, path)
  return path
end

local function edit(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return vim.api.nvim_get_current_buf()
end

local function delete_buffer(bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

local function test_buffer_safety()
  local quit_all = vim.fn.maparg("<leader>qq", "n", false, true)
  local write_quit_all = vim.fn.maparg("<leader>wq", "n", false, true)
  local write = vim.fn.maparg("<leader>ww", "n", false, true)
  expect(not quit_all.rhs:find("!", 1, true), "quit-all mapping must not force changes away")
  expect(not write_quit_all.rhs:find("!", 1, true), "write-and-quit mapping must not force writes")
  expect(not write.rhs:find("!", 1, true), "write mapping must not force writes")

  local bufferline = dofile("nvim/lua/plugins/bufferline.lua")[1]
  local close_buffer = bufferline.opts.options.close_command
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "modified" })
  vim.bo[bufnr].modified = true
  close_buffer(bufnr)
  expect(vim.api.nvim_buf_is_valid(bufnr), "Bufferline must keep modified buffers")
  vim.bo[bufnr].modified = false
  close_buffer(bufnr)
  expect(not vim.api.nvim_buf_is_valid(bufnr), "Bufferline must close unmodified buffers")
end

local function test_trim_whitespace()
  local markdown_path = temp_file(".md", { "keep  " })
  local markdown_buf = edit(markdown_path)
  vim.cmd.write()
  expect_equal(vim.fn.readfile(markdown_path), { "keep  " }, "Markdown trailing spaces")

  local lua_path = temp_file(".lua", { "trim  " })
  local lua_buf = edit(lua_path)
  vim.cmd.write()
  expect_equal(vim.fn.readfile(lua_path), { "trim" }, "Lua trailing spaces")

  delete_buffer(markdown_buf)
  delete_buffer(lua_buf)
  vim.fn.delete(markdown_path)
  vim.fn.delete(lua_path)
end

local function test_large_file_guards()
  local path = temp_file(".lua", { string.rep("x", 1024 * 1024 + 1) })
  local bufnr = edit(path)
  expect(vim.b[bufnr].large_file == true, "large files must be marked before reading")
  expect(not vim.bo[bufnr].swapfile, "large files must disable swap files")
  expect(not vim.bo[bufnr].undofile, "large files must disable persistent undo")

  require("lazy").load({ plugins = { "nvim-lspconfig" } })
  local detached
  local original_get_client = vim.lsp.get_client_by_id
  local original_detach = vim.lsp.buf_detach_client
  vim.lsp.get_client_by_id = function() return { id = 77 } end
  vim.lsp.buf_detach_client = function(buffer, client)
    detached = { buffer, client }
    return true
  end
  local ok, error_message = pcall(vim.api.nvim_exec_autocmds, "LspAttach", {
    buffer = bufnr,
    data = { client_id = 77 },
  })
  vim.lsp.get_client_by_id = original_get_client
  vim.lsp.buf_detach_client = original_detach
  expect(ok, "late LSP attach guard failed: " .. tostring(error_message))
  expect_equal(detached, { bufnr, 77 }, "late LSP client detach")

  delete_buffer(bufnr)
  vim.fn.delete(path)
end

local function test_lsp_mappings()
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(bufnr)
  local original_get_client = vim.lsp.get_client_by_id
  vim.lsp.get_client_by_id = function() return { id = 78 } end
  local ok, error_message = pcall(vim.api.nvim_exec_autocmds, "LspAttach", {
    buffer = bufnr,
    data = { client_id = 78 },
  })
  vim.lsp.get_client_by_id = original_get_client
  expect(ok, "LSP mappings failed: " .. tostring(error_message))
  expect(vim.fn.maparg("<leader>dq", "n", false, true).buffer == 1, "diagnostic loclist must use <leader>dq")
  expect(vim.fn.maparg("<leader>dl", "n", false, true).buffer ~= 1, "LSP must not claim <leader>dl")
  delete_buffer(bufnr)
end

local function test_fswatch_lifecycle()
  local fswatch = require("core.fswatch")
  local path = temp_file(".txt", { "before" })
  local bufnr = edit(path)
  expect(fswatch.is_watching(bufnr), "file buffers must start a watcher")

  vim.wait(100, function() return false end, 20)
  vim.fn.system({ "sh", "-c", "printf '%s\\n' 'after external edit' > \"$1\"", "sh", path })
  local reloaded = vim.wait(2000, function()
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] == "after external edit"
  end, 20)
  expect(reloaded, "watcher must reload an external edit")

  fswatch.setup()
  expect(fswatch.is_watching(bufnr), "config reload must restart existing watchers")

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "local edit" })
  vim.fn.writefile({ "second external edit" }, path)
  vim.wait(200, function() return false end, 20)
  expect_equal(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), { "local edit" }, "watcher modified-buffer guard")

  delete_buffer(bufnr)
  expect(not fswatch.is_watching(bufnr), "buffer deletion must stop its watcher")
  vim.fn.delete(path)
end

local function test_plugin_configuration()
  local claudecode = dofile("nvim/lua/plugins/claudecode.lua")
  expect(
    not vim.iter(claudecode.keys):any(function(key) return key[2]:find("dangerously%-skip%-permissions") end),
    "ClaudeCode mappings must not bypass permission checks"
  )

  local completion = dofile("nvim/lua/plugins/completion.lua")[1]
  expect(not vim.list_contains(completion.opts.sources.default, "lazydev"), "Blink must not enable LazyDev globally")
  expect(vim.list_contains(completion.opts.sources.per_filetype.lua, "lazydev"), "Blink Lua sources must include LazyDev")
  expect_equal(completion.opts.sources.providers.lazydev.module, "lazydev.integrations.blink", "Blink LazyDev provider")

  local lsp_plugins = dofile("nvim/lua/plugins/lsp.lua")
  expect(vim.iter(lsp_plugins):any(function(plugin) return plugin[1] == "folke/lazydev.nvim" end), "LazyDev plugin spec")

  local lua_ls = dofile("nvim/lsp/lua_ls.lua")
  expect_equal(lua_ls.settings.Lua.workspace.library, { vim.env.VIMRUNTIME }, "lua_ls runtime-only library")

  local todo = dofile("nvim/lua/plugins/todo-comments.lua")
  expect(not vim.list_contains(todo.dependencies, "ibhagwan/fzf-lua"), "TODO comments must not eagerly depend on FzfLua")

  local installed_languages
  local original_treesitter = package.loaded["nvim-treesitter"]
  package.loaded["nvim-treesitter"] = {
    get_installed = function() return { "lua", "vim" } end,
    install = function(languages) installed_languages = languages end,
  }
  dofile("nvim/lua/plugins/treesitter.lua")[1].config()
  package.loaded["nvim-treesitter"] = original_treesitter
  expect(not vim.list_contains(installed_languages, "lua"), "Tree-sitter must not reinstall existing parsers")
  expect(vim.list_contains(installed_languages, "typescript"), "Tree-sitter must install missing parsers")
end

test_buffer_safety()
test_trim_whitespace()
test_large_file_guards()
test_lsp_mappings()
test_fswatch_lifecycle()
test_plugin_configuration()
require("core.fswatch").stop_all()

if #failures > 0 then
  error(table.concat(failures, "\n"))
end

print("Neovim tests passed")
