return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",
        "black",
        "flake8",
        "ruff",
        "sql-formatter",
      },
    },
  },

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
      -- Prepend Mason bin to PATH so Conform finds prettier/black/flake8.
      local ok, path = pcall(require, "mason-core.path")
      if ok and path.bin_prefix then
        local mason_bin = path.bin_prefix()
        if mason_bin and #mason_bin > 0 then
          local sep = package.config:sub(1, 1) == "\\" and ";" or ":"
          vim.env.PATH = mason_bin .. sep .. vim.env.PATH
        end
      end

      require("conform").setup(opts)
    end,
  },
}
