return {
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    keys = {
      {
        "<leader>F",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
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
        python = { "black" },
        terraform = { "terraform_fmt" },
        sql = { "sql_formatter" },
      },
      format_on_save = false,
    },
    -- Mason prepends its bin/ to PATH on setup (PATH = "prepend" default),
    -- so conform finds mason-installed formatters automatically.
  },
}
