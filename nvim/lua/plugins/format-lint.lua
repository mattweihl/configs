return {
  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format file or selection",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          python = { "black", "isort" },
          lua = { "stylua" },
        },
        format_on_save = function(bufnr)
          -- Skip if formatter is not installed (prevents freezing)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname == "" then
            return
          end
          return {
            timeout_ms = 1000,
            lsp_fallback = true,
          }
        end,
        -- Don't show errors when formatter is missing
        notify_on_error = false,
      })
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "ruff" },
        -- JS/TS linting handled by eslint LSP server
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Auto-install formatters/linters via Mason (runs on startup)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "black",
          "isort",
          "ruff",
          "stylua",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
}
