return {
  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        transparent_mode = false,
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Extra colorschemes (lazy-loaded, available via :colorscheme)
  { "folke/tokyonight.nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "cocopon/iceberg.vim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      local nf = vim.g.have_nerd_font

      -- Clickable panel buttons — each is a separate component so on_click works
      local btn_files = {
        function() return nf and "󰙅 " or "[Files]" end,
        on_click = function() vim.cmd("Neotree toggle") end,
      }
      local btn_search = {
        function() return nf and "󰈞 " or "[Search]" end,
        on_click = function() require("grug-far").open() end,
      }
      local btn_git = {
        function() return nf and "󰊢 " or "[Git]" end,
        on_click = function() vim.cmd("DiffviewOpen") end,
      }
      local btn_debug = {
        function() return nf and" " or "[Debug]" end,
        on_click = function() require("dapui").toggle() end,
      }

      require("lualine").setup({
        options = {
          icons_enabled = nf,
          theme = "auto",
          component_separators = nf and { left = "", right = "" } or { left = "|", right = "|" },
          section_separators = nf and { left = "", right = "" } or { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "branch",
              on_click = function()
                vim.cmd("DiffviewOpen")
              end,
            },
            {
              "diff",
              on_click = function()
                vim.cmd("DiffviewOpen")
              end,
            },
            {
              "diagnostics",
              on_click = function()
                vim.cmd("Trouble diagnostics toggle")
              end,
            },
          },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { btn_files, btn_search, btn_git, btn_debug, "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Buffer tabs
  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    config = function()
      require("barbar").setup({
        animation = false,
        auto_hide = false,
        clickable = true,
        icons = {
          buffer_index = false,
          filetype = { enabled = vim.g.have_nerd_font },
          separator = { left = "▎", right = "" },
          modified = { button = "●" },
          pinned = { button = vim.g.have_nerd_font and "" or "*", filename = true },
          diagnostics = {
            [vim.diagnostic.severity.ERROR] = { enabled = true, icon = vim.g.have_nerd_font and " " or "E " },
            [vim.diagnostic.severity.WARN] = { enabled = false },
          },
        },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true, show_start = false, show_end = false },
      })
    end,
  },

  -- Inline color preview (CSS, Tailwind, etc.)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css", "scss", "html", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "lua", "vim",
        },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          css = true,
          css_fn = true,
          mode = "background",
          tailwind = true,
          always_update = false,
        },
      })
    end,
  },

  -- Icons (only loaded when Nerd Font is available)
  {
    "nvim-tree/nvim-web-devicons",
    enabled = vim.g.have_nerd_font,
    lazy = true,
    config = function()
      require("nvim-web-devicons").setup({ default = true })
    end,
  },

  -- Trouble (diagnostic list)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
    config = function()
      require("trouble").setup({
        icons = {
          folder_closed = vim.g.have_nerd_font and " " or "> ",
          folder_open = vim.g.have_nerd_font and " " or "v ",
        },
      })
    end,
  },

  -- Notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      notify.setup({
        timeout = 2000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
        render = "compact",
        stages = "fade",
      })
      vim.notify = notify
    end,
  },
}
