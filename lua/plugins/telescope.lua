return {
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build'
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config =  function()
            require('telescope').setup {
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    }
                }
            }

            -- To get fzf loaded and working with telescope, you need to call
            -- load_extension, somewhere after setup function:
            require('telescope').load_extension('fzf')

            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>f', builtin.find_files, {})
            vim.keymap.set('n', '<leader>t', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>b', builtin.buffers, {})

            -- vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {})
            -- vim.keymap.set('n', '<leader>fw', builtin.current_buffer_fuzzy_find, {})
            -- vim.keymap.set('n', '<leader>fm', builtin.marks, {})
        end
    }
}

