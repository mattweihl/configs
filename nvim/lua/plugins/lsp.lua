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
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- LSP servers
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "pyright",
        "vscode-eslint-language-server",
        "jdtls",
        "marksman",
        "texlab",
        "bash-language-server",
        "yaml-language-server",
        "json-lsp",
        "lua-language-server",
        "vim-language-server",
        "sqlls",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "terraform-ls",
        -- Formatters & linters
        "prettier",
        "ruff",
        "sql-formatter",
      },
    },
  },

  {
    -- Loading nvim-lspconfig adds its lsp/ directory to runtimepath, providing
    -- cmd/filetypes/root_markers for servers activated by vim.lsp.enable().
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        root_markers = { ".git" },
      })

      -- Schemastore requires must live here (not in lsp/ files) because
      -- Neovim's lsp/ auto-discovery runs outside lazy.nvim's load order.
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.enable({
        "ts_ls",
        "html",
        "cssls",
        "pyright",
        "eslint",
        "jdtls",
        "marksman",
        "texlab",
        "bashls",
        "yamlls",
        "jsonls",
        "lua_ls",
        "vimls",
        "sqlls",
        "dockerls",
        "docker_compose_language_service",
        "terraformls",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
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

          -- Open in vertical split (VSCode: Cmd+K F12 "Open Definition to Side")
          map("n", "<leader>gd", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
          end, "Definition in split")
          map("n", "<leader>gD", function()
            vim.cmd("vsplit")
            vim.lsp.buf.declaration()
          end, "Declaration in split")
          map("n", "<leader>gi", function()
            vim.cmd("vsplit")
            vim.lsp.buf.implementation()
          end, "Implementation in split")
          map("n", "<leader>gt", function()
            vim.cmd("vsplit")
            vim.lsp.buf.type_definition()
          end, "Type definition in split")

          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature help")

          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

          map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "Toggle inlay hints")

          map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
          map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to loclist")
        end,
      })

      vim.diagnostic.config({
        virtual_text = false,
        float = {
          border = "rounded",
        },
        severity_sort = true,
        update_in_insert = false,
      })
    end,
  },
}
