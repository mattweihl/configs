return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        mode = "n",
        desc = "Search & replace",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        mode = "n",
        desc = "Search word under cursor",
      },
      {
        "<leader>sr",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        mode = "v",
        desc = "Search visual selection",
      },
    },
    config = function()
      require("grug-far").setup({
        windowCreationCommand = "vsplit",
      })
    end,
  },
}
