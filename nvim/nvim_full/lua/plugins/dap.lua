return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")
          local nf = vim.g.have_nerd_font

          dapui.setup({
            icons = {
              expanded = nf and "▾" or "v",
              collapsed = nf and "▸" or ">",
              current_frame = nf and "→" or "*",
            },
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.35 },
                  { id = "breakpoints", size = 0.15 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                position = "left",
                size = 40,
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                position = "bottom",
                size = 10,
              },
            },
          })

          -- Auto open/close UI on debug session
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
      -- Mason DAP bridge — auto-install debug adapters
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
          require("mason-nvim-dap").setup({
            ensure_installed = { "js", "python", "codelldb" },
            automatic_installation = true,
            handlers = {},
          })
        end,
      },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local nf = vim.g.have_nerd_font

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", {
        text = nf and "" or "B",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = nf and "" or "C",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = nf and "" or ">",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })
    end,
  },
}
