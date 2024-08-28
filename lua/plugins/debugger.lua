return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Set keymaps to control the debugger
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "[Debug] Continue" })
      vim.keymap.set("n", "<F7>", dap.step_over, { desc = "[Debug] Step Over" })
      vim.keymap.set("n", "<F8>", dap.step_into, { desc = "[Debug] Step Into" })
      vim.keymap.set("n", "<F9>", dap.step_out, { desc = "[Debug] Step Out" })
      vim.keymap.set("n", "<F11>", dap.step_out, { desc = "[Debug] Restart" })
      vim.keymap.set("n", "<F12>", dap.close, { desc = "[Debug] Close" })

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "set conditional breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
      vim.keymap.set("n", "<leader>de", function()
        dapui.eval(nil, { enter = true })
      end, { desc = "Eval under cursor" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle UI" })

      -- Breakpoints icons
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      sign("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

      -- UI events hooks
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      -- Adapters config
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "::1",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = {
            "${port}",
          },
        },
      }

      for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            port = 9229,
            name = "Attach",
            skipFiles = { "<node_internals>/**", "node_modules/**" },
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}
