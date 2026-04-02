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
    config = function(_, opts)
      -- Prepend Mason bin to PATH so Conform finds prettier/black/etc.
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if vim.fn.isdirectory(mason_bin) == 1 then
        local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
        vim.env.PATH = mason_bin .. sep .. vim.env.PATH
      end

      require("conform").setup(opts)
    end,
  },
}
