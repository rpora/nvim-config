return {
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build =
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build'
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "-L",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          file_ignore_patterns = { "node_modules" },
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },           -- default = nil,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        },
        extensions = {
          fzf = {
            fuzzy = true,                               -- false will only do exact matching
            override_generic_sorter = true,             -- override the generic sorter
            override_file_sorter = true,                -- override the file sorter
            case_mode = "smart_case",                   -- or "ignore_case" or "respect_case"
          }
        }
      }

      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require('telescope').load_extension('fzf')

      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>f', builtin.find_files, {})
      vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>b', builtin.buffers, {})

      -- vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {})
      -- vim.keymap.set('n', '<leader>fw', builtin.current_buffer_fuzzy_find, {})
      -- vim.keymap.set('n', '<leader>fm', builtin.marks, {})
    end
  }
}

-- local options = {
--     defaults = {
--         vimgrep_arguments = {
--             "rg",
--             "-L",
--             "--color=never",
--             "--no-heading",
--             "--with-filename",
--             "--line-number",
--             "--column",
--             "--smart-case",
--         },
--         prompt_prefix = "   ",
--         selection_caret = "  ",
--         entry_prefix = "  ",
--         initial_mode = "insert",
--         selection_strategy = "reset",
--         sorting_strategy = "ascending",
--         layout_strategy = "horizontal",
--         layout_config = {
--             horizontal = {
--                 prompt_position = "top",
--                 preview_width = 0.55,
--                 results_width = 0.8,
--             },
--             vertical = {
--                 mirror = false,
--             },
--             width = 0.87,
--             height = 0.80,
--             preview_cutoff = 120,
--         },
--         file_sorter = require("telescope.sorters").get_fuzzy_file,
--         file_ignore_patterns = { "node_modules" },
--         generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
--         path_display = { "truncate" },
--         winblend = 0,
--         border = {},
--         borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
--         color_devicons = true,
--         set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
--         file_previewer = require("telescope.previewers").vim_buffer_cat.new,
--         grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
--         qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
--         -- Developer configurations: Not meant for general override
--         buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
--         mappings = {
--             n = { ["q"] = require("telescope.actions").close },
--         },
--     },
--
--     extensions_list = { "themes", "terms", "fzf" },
--     extensions = {
--         fzf = {
--             fuzzy = true,
--             override_generic_sorter = true,
--             override_file_sorter = true,
--             case_mode = "smart_case",
--         },
--     },
-- }
--
-- return options
