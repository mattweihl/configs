return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall", "MasonUninstall" },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "pyright",
        "jdtls",   -- Java
        "marksman", -- Markdown
        "texlab",  -- LaTeX
        "bashls",  -- Bash / Zsh
        "yamlls",  -- YAML
        "jsonls",  -- JSON
        "lua_ls",  -- Lua
        "vimls",   -- Vimscript
        "sqlls",   -- SQL
      },
    },
    config = function(_, opts)
      require("mason").setup()
      require("mason-lspconfig").setup(opts)

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Apply capabilities to all LSP servers (Neovim 0.11 vim.lsp.config).
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Keymaps and behavior on LSP attach (no setup_handlers in mason-lspconfig v2).
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "Go to references")

          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

          map("n", "<leader>f", function()
            local ok, conform = pcall(require, "conform")
            if ok then
              conform.format({ async = true, lsp_format = "fallback" })
            else
              vim.lsp.buf.format({ async = true })
            end
          end, "Format buffer")

          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to loclist")

          map("n", "<RightMouse>", function()
            vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
            vim.lsp.buf.code_action()
          end, "LSP code actions (right-click)")
        end,
      })

      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          prefix = "●",
        },
        float = {
          border = "rounded",
        },
        severity_sort = true,
        update_in_insert = false,
      })
    end,
  },
}
