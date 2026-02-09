return {
  -- Lazygit in a floating terminal
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local nf = vim.g.have_nerd_font
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = nf and "󰍵" or "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
          virt_text_pos = "eol",
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }

          -- Navigation (nav_hunk replaces deprecated next_hunk/prev_hunk)
          vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, vim.tbl_extend("force", opts, { desc = "Next git hunk" }))
          vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, vim.tbl_extend("force", opts, { desc = "Previous git hunk" }))

          -- Actions
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, vim.tbl_extend("force", opts, { desc = "Stage hunk" }))
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk_inline, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))
          vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, vim.tbl_extend("force", opts, { desc = "Blame line" }))
          vim.keymap.set("n", "<leader>hd", gs.diffthis, vim.tbl_extend("force", opts, { desc = "Diff this" }))
        end,
      })
    end,
  },
}
