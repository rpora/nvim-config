return {
    'mfussenegger/nvim-dap',
    config = function()
        local dap = require("dap")

        dap.configurations = {
            cpp = {
                {
                    type = "codelldb",
                    name = "Debug",
                    request = "launch",
                    program = "${file}"
                }
            }
        }

        dap.adapters.codelldb = {
            type = "server",
            port = "13000",
            executable = {
                command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
                args = {"--port", "13000"}
            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

    end
}
