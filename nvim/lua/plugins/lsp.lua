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
      "b0o/schemastore.nvim",
    },
    opts = {
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "pyright",
        "eslint",
        "jdtls",   -- Java
        "marksman", -- Markdown
        "texlab",  -- LaTeX
        "bashls",  -- Bash / Zsh
        "yamlls",  -- YAML
        "jsonls",  -- JSON
        "lua_ls",  -- Lua
        "vimls",   -- Vimscript
        "sqlls",   -- SQL
        "dockerls",                        -- Dockerfile
        "docker_compose_language_service", -- docker-compose.yml
        "terraformls",                     -- Terraform (requires terraform CLI)
        -- "tailwindcss",                  -- Uncomment when confirmed project uses Tailwind (resource-heavy)
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("eslint", {
        settings = {
          workingDirectories = { mode = "auto" },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("terraformls", {
        init_options = {
          ignoreSingleFileWarning = true,
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
              },
            },
          },
        },
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
          map("n", "gK", vim.lsp.buf.signature_help, "Signature help")

          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")

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
