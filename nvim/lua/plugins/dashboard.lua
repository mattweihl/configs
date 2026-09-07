return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local function pad_to_block(lines)
      local width = 0
      for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
      end
      return vim.tbl_map(function(line)
        return line .. string.rep(' ', width - vim.fn.strdisplaywidth(line))
      end, lines)
    end

    local shuttle = pad_to_block {
      '',
      '',
      '        _',
      "      ,' '.",
      '     /     \\',
      '   ^ |  _  | ^',
      '  | || / \\ || |',
      '  | |||.-.||| |',
      '  | |||   ||| |',
      '  | |||   ||| |',
      '  | |||   ||| |',
      '  | |||   ||| |',
      "  | ,'     '. |",
      "  ,'__     __`.",
      ' /____  |  ____\\',
      '  /_\\ |_|_| /_\\',
      '  .:   : :   :.',
      '  : .  : .  : :',
      '   ::   ::   ::',
      '  : : .: :. : :',
      ' .: :.: : :. : .',
      ' : : .: :  ::  :',
      ' .:  .   : :   ..',
      '',
      '',
    }

    local function lazy_stats_footer()
      local ok, lazy = pcall(require, 'lazy')
      if not ok then
        return {}
      end
      local stats = lazy.stats()
      local startup_ms = math.floor(stats.startuptime * 100 + 0.5) / 100
      return {
        '',
        ('Startup time: %s ms'):format(startup_ms),
        ('Plugins: %d loaded / %d installed'):format(stats.loaded, stats.count),
      }
    end

    require('dashboard').setup {
      theme = 'hyper',
      config = {
        header = shuttle,
        shortcut = {},
        packages = { enable = false },
        project = {
          enable = true,
          limit = 8,
          action = function(path)
            vim.cmd('cd ' .. vim.fn.fnameescape(path))
            require('fzf-lua').files { cwd = path }
          end,
        },
        mru = { limit = 10 },
        footer = lazy_stats_footer,
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
