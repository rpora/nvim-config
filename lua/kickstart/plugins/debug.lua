return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- debuggers
    'leoluz/nvim-dap-go',
    'mxsdev/nvim-dap-vscode-js',
    {
			"microsoft/vscode-js-debug",
			build = "npm i && npm run compile vsDebugServerBundle && mv dist out"
		}
  },
  config = function()

    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_setup = true,
      handlers = {},
    }

    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
    require("dap-vscode-js").setup({
      -- setup with lazy
      debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",

      -- setup with mason
      -- debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter',
      -- debugger_cmd = { 'js-debug-adapter' },

      adapters = { 'pwa-node' },
      -- log_file_path = "/home/rpora/dap_vscode_js.log", -- Path for file logging
      -- log_file_level = 0, -- Logging level for output to file. Set to false to disable file logging.
      -- log_console_level = vim.log.levels.ERROR, -- Logging level for output to console. Set to false to disable console output.
		})
    -- Js based languages
    local js_lang = { "typescript", "javascript", "typescriptreact"}
    for _, lang in ipairs(js_lang) do
      dap.configurations[lang] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch Current File (pwa-node)',
          cwd = vim.fn.getcwd(),
          program = '${file}',
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach",
          processId = require 'dap.utils'.pick_process,
          cwd = "${workspaceFolder}",
        },
      }
    end

  end,
}
