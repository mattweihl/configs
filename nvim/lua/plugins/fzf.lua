return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = true },
    },
    keys = {
      { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>f.", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
      { "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
      { "<leader>p", "<cmd>FzfLua commands<cr>", desc = "Command palette" },
    },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            layout = "horizontal",
            horizontal = "right:55%",
          },
        },
        keymap = {
          fzf = {
            ["ctrl-q"] = "select-all+accept", -- send all to quickfix
          },
          builtin = {
            ["<C-j>"] = "preview-page-down",
            ["<C-k>"] = "preview-page-up",
          },
        },
        files = {
          cmd = "rg --files --hidden --glob=!.git/*",
          file_ignore_patterns = { "node_modules/", "__pycache__/", "%.pyc" },
        },
        grep = {
          rg_opts = "--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --glob=!.git/*",
        },
      })
    end,
  },
}
