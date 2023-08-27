local M = {}

M.setup = function()
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {
           "javascript",
            "typescript",
            "json",
            "http",
            "html",
            "c",
            "lua",
            "vim",
            "vimdoc",
            "query"
        },

        sync_install = false,
        auto_install = true,

        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    }
    end

    return M

