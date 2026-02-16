return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Enable treesitter-based highlighting and indentation
      vim.treesitter.language.register("bash", "sh")
    end,
  },
}
