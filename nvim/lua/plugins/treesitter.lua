return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 900,
    init = function()
      vim.treesitter.language.register("bash", "sh")
      vim.treesitter.language.register("bash", "zsh")
      vim.treesitter.language.register("javascript", "javascriptreact")
    end,
    config = function()
      local ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "python",
        "json",
        "markdown",
        "markdown_inline",
        "java",
        "latex",
        "yaml",
        "dockerfile",
        "hcl",
        "sql",
        "graphql",
      }

      require("nvim-treesitter").install(ensure_installed)

      -- On a brand-new machine, tree-sitter-cli (installed via Mason, see
      -- lsp.lua) may still be downloading when the install above runs,
      -- causing parser builds to fail with "tree-sitter not found". Retry
      -- once Mason finishes so first launch doesn't need a manual restart.
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
          require("nvim-treesitter").install(ensure_installed)
        end,
      })

      -- Highlighting/indentation are provided by Neovim core; nvim-treesitter
      -- only supplies parsers/queries. Start them per-buffer (silently
      -- no-ops if no parser is installed for the filetype).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
