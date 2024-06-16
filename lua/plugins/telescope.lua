return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            n = {
              ["<C-d>"] = require("telescope.actions").delete_buffer,
            },
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = require("telescope.actions").delete_buffer,
            },
          },
        },
      })

      -- enable telescope extensions
      pcall(require("telescope").load_extension, "fzf")

      -- telescope keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><space>", builtin.buffers)
      vim.keymap.set("n", "<leader>gf", builtin.git_files)
      vim.keymap.set("n", "<leader>sf", builtin.find_files)
      vim.keymap.set("n", "<leader>sw", builtin.grep_string)
      vim.keymap.set("n", "<leader>sg", builtin.live_grep)
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics)
      vim.keymap.set("n", "<leader>sr", builtin.resume)
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles)

      -- Fuzzy search in the current buffer
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end)

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },
}
