return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
      { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick close" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close others" },
      { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close right" },
      { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        close_command = function(bufnr)
          -- Find an alternate buffer to show
          local alt_buf = nil
          for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
            if b.bufnr ~= bufnr then
              alt_buf = b.bufnr
              break
            end
          end
          -- Switch ALL windows showing this buffer before deleting it
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == bufnr then
              if alt_buf then
                vim.api.nvim_win_set_buf(win, alt_buf)
              else
                vim.api.nvim_win_call(win, function() vim.cmd("enew") end)
              end
            end
          end
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
  },
}
