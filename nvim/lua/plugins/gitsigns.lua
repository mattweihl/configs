return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function(_, opts)
    -- Set sign highlights once globally, not per-buffer
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#b8bb26", bold = true })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#fabd2f", bold = true })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#fb4934", bold = true })
    require("gitsigns").setup(opts)
  end,
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "│" },
      untracked = { text = "┆" },
    },
    signs_staged_enable = false,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, "Next hunk")

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, "Prev hunk")

      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", gs.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>hd", gs.diffthis, "Diff this file")
    end,
  },
}
