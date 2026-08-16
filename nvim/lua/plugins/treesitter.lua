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

      local function install_missing()
        local treesitter = require("nvim-treesitter")
        local installed = {}
        for _, language in ipairs(treesitter.get_installed("parsers")) do
          installed[language] = true
        end

        local missing = vim.tbl_filter(function(language)
          return not installed[language]
        end, ensure_installed)
        if #missing > 0 then
          treesitter.install(missing, { force = true })
        end
      end

      install_missing()

      -- On a brand-new machine, tree-sitter-cli (installed via Mason, see
      -- lsp.lua) may still be downloading when the install above runs,
      -- causing parser builds to fail with "tree-sitter not found". Retry
      -- once Mason finishes so first launch doesn't need a manual restart.
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
          install_missing()
        end,
      })

      -- Highlighting/indentation are provided by Neovim core; nvim-treesitter
      -- only supplies parsers/queries. Start them per-buffer (silently
      -- no-ops if no parser is installed for the filetype).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if vim.b[ev.buf].large_file then return end
          local language = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if language and pcall(vim.treesitter.language.add, language) then
            if pcall(vim.treesitter.start, ev.buf, language) then
              vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
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
