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
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
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

      -- Format on demand: Conform (prettier/black) with LSP fallback. Works in all buffers.
      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format buffer" })

      -- Flake8: run on demand (linter, not formatter). Uses PATH (Mason bin prepended above).
      vim.api.nvim_create_user_command("Flake8", function()
        local file = vim.fn.expand("%")
        if file == "" then
          vim.notify("Flake8: save the file first", vim.log.levels.WARN)
          return
        end
        vim.cmd("!flake8 " .. vim.fn.shellescape(file))
      end, { desc = "Run flake8 on current file" })
    end,
  },
}
