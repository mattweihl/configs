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

  -- Bridge mason with native LSP
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Shared on_attach for all LSP servers
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Navigation
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
        vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))

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

      -- LspAttach autocmd to run on_attach for all servers
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            on_attach(client, args.buf)
          end
        end,
      })

      -- Configure LSP servers using native vim.lsp.config (Neovim 0.11+)
      -- Common root markers
      local web_root = { "package.json", "tsconfig.json", "jsconfig.json", ".git" }

      local server_configs = {
        ts_ls = {
          capabilities = capabilities,
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
          root_markers = web_root,
          settings = {
            typescript = { preferences = { quoteStyle = "single" } },
            javascript = { preferences = { quoteStyle = "single" } },
          },
        },
        pyright = {
          capabilities = capabilities,
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
          root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git" },
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
          capabilities = capabilities,
          cmd = { "lua-language-server" },
          filetypes = { "lua" },
          root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
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
          capabilities = capabilities,
          cmd = { "emmet-ls", "--stdio" },
          filetypes = {
            "html", "css", "scss", "javascript", "javascriptreact",
            "typescript", "typescriptreact", "svelte", "vue",
          },
          root_markers = web_root,
        },
        eslint = {
          capabilities = capabilities,
          cmd = { "vscode-eslint-language-server", "--stdio" },
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
          root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "eslint.config.mjs", "package.json", ".git" },
          handlers = {
            ["textDocument/diagnostic"] = function() end,
          },
        },
        html = {
          capabilities = capabilities,
          cmd = { "vscode-html-language-server", "--stdio" },
          filetypes = { "html", "templ" },
          root_markers = { "package.json", ".git" },
        },
        cssls = {
          capabilities = capabilities,
          cmd = { "vscode-css-language-server", "--stdio" },
          filetypes = { "css", "scss", "less" },
          root_markers = { "package.json", ".git" },
        },
        tailwindcss = {
          capabilities = capabilities,
          cmd = { "tailwindcss-language-server", "--stdio" },
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "vue" },
          root_markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts", "package.json" },
        },
        jsonls = {
          capabilities = capabilities,
          cmd = { "vscode-json-language-server", "--stdio" },
          filetypes = { "json", "jsonc" },
          root_markers = { ".git" },
        },
        rust_analyzer = {
          capabilities = capabilities,
          cmd = { "rust-analyzer" },
          filetypes = { "rust" },
          root_markers = { "Cargo.toml", "rust-project.json", ".git" },
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = { command = "clippy" },
              cargo = { allFeatures = true },
              procMacro = { enable = true },
            },
          },
        },
        clangd = {
          capabilities = capabilities,
          cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
          root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
        },
        jdtls = {
          capabilities = capabilities,
          cmd = { "jdtls" },
          filetypes = { "java" },
          root_markers = { "pom.xml", "build.gradle", ".git" },
        },
      }

      -- Register each server config with native API
      for server, config in pairs(server_configs) do
        vim.lsp.config(server, config)
      end

      -- ESLint fix on save
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              command = "EslintFixAll",
            })
          end
        end,
      })

      -- Mason-lspconfig: install servers and auto-enable them
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
          "rust_analyzer",
          "clangd",
          "jdtls",
        },
        automatic_enable = true,
      })

      -- Diagnostic display settings (Neovim 0.11+ signs API)
      local nf = vim.g.have_nerd_font
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = nf and " " or "E",
            [vim.diagnostic.severity.WARN] = nf and " " or "W",
            [vim.diagnostic.severity.HINT] = nf and "󰌵 " or "H",
            [vim.diagnostic.severity.INFO] = nf and " " or "I",
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
