return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      local parsers = {
        "javascript", "typescript", "tsx",
        "python",
        "html", "css",
        "json",
        "lua",
        "markdown",
        "bash",
        "yaml",
        "vim",
      }
      vim.cmd("TSInstall! " .. table.concat(parsers, " "))
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
}
