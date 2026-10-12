return {
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = "Format",
    keys = {
      {
        "<leader>F",
        "<cmd>Format<cr>",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        python = { "ruff_format" },
        sql = { "sql_formatter" },
        terraform = { "terraform_fmt" },
      },
    },
    config = function(_, opts)
      local conform = require("conform")
      conform.setup(opts)

      vim.api.nvim_create_user_command("Format", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.b[bufnr].large_file and vim.bo[bufnr].filetype ~= "markdown" then
          vim.api.nvim_buf_call(bufnr, function()
            local view = vim.fn.winsaveview()
            vim.cmd([[silent keepjumps keeppatterns %s/\s\+$//e]])
            vim.fn.winrestview(view)
          end)
        end

        conform.format({ bufnr = bufnr, async = true, lsp_format = "fallback" })
      end, { desc = "Format the current buffer" })
    end,
    -- Mason prepends its bin/ to PATH on setup (PATH = "prepend" default),
    -- so conform finds mason-installed formatters automatically.
  },
}
