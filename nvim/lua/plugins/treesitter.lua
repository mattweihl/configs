return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      -- Only install parsers on plugin install/update, not every startup
      local parsers = {
        "javascript", "typescript", "tsx",
        "python",
        "html", "css", "scss",
        "json", "jsonc",
        "lua",
        "markdown", "markdown_inline",
        "bash",
        "yaml", "toml",
        "vim", "vimdoc",
        "regex",
        "gitignore", "diff",
        "rust",
        "c", "cpp",
        "java",
      }
      vim.cmd("TSInstall! " .. table.concat(parsers, " "))
    end,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Nothing needed here — Neovim 0.11 handles treesitter
      -- highlighting and indentation natively once parsers are installed.
      -- Use :TSInstall <lang> to manually add new languages.
    end,
  },

  -- Textobjects (select, move, swap functions/classes/params)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- Select textobjects
      local select_maps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }

      for key, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query)
        end, { desc = "Select " .. query })
      end

      -- Move to next/previous function/class
      local move_maps = {
        ["]f"] = { query = "@function.outer", desc = "Next function" },
        ["]c"] = { query = "@class.outer", desc = "Next class" },
        ["[f"] = { query = "@function.outer", desc = "Previous function", prev = true },
        ["[c"] = { query = "@class.outer", desc = "Previous class", prev = true },
      }

      for key, opts in pairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          if opts.prev then
            move.goto_previous_start(opts.query)
          else
            move.goto_next_start(opts.query)
          end
        end, { desc = opts.desc })
      end

      -- Swap parameters
      vim.keymap.set("n", "<leader>xp", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next parameter" })

      vim.keymap.set("n", "<leader>xP", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap previous parameter" })
    end,
  },
}
