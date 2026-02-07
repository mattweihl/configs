return {
  -- Mason: auto-install LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  -- Bridge mason with lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities()

      -- Shared on_attach for all LSP servers
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Navigation (same keybindings as old CoC config)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))

        -- Documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

        -- Actions
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Code lens" }))

        -- Diagnostics
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))

        -- Highlight symbol under cursor
        if client.server_capabilities.documentHighlightProvider then
          local hl_group = vim.api.nvim_create_augroup("LspHighlight_" .. bufnr, { clear = true })
          vim.api.nvim_create_autocmd("CursorHold", {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            group = hl_group,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- Disable automatic_enable so we control setup ourselves
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "pyright",
          "html",
          "cssls",
          "tailwindcss",
          "emmet_ls",
          "eslint",
          "lua_ls",
          "jsonls",
        },
        automatic_enable = false,
      })

      -- Default config shared by all servers
      local default_config = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Server-specific overrides
      local server_configs = {
        ts_ls = {
          settings = {
            typescript = { preferences = { quoteStyle = "single" } },
            javascript = { preferences = { quoteStyle = "single" } },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
              diagnostics = { globals = { "vim" } },
              telemetry = { enable = false },
            },
          },
        },
        emmet_ls = {
          filetypes = {
            "html", "css", "scss", "javascript", "javascriptreact",
            "typescript", "typescriptreact", "svelte", "vue",
          },
        },
        eslint = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        },
      }

      -- Setup each installed server
      local installed = require("mason-lspconfig").get_installed_servers()
      for _, server in ipairs(installed) do
        local config = vim.tbl_deep_extend("force", default_config, server_configs[server] or {})
        lspconfig[server].setup(config)
      end

      -- Also setup servers that might not be installed via mason yet
      -- (handles first-run before mason installs them)
      for server, config in pairs(server_configs) do
        local merged = vim.tbl_deep_extend("force", default_config, config)
        if not vim.tbl_contains(installed, server) then
          pcall(function()
            lspconfig[server].setup(merged)
          end)
        end
      end

      -- Diagnostic display settings (Neovim 0.11+ signs API)
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })
    end,
  },
}
