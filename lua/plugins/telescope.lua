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
      vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>sf", builtin.git_files, { desc = "Git files" })
      vim.keymap.set("n", "<leader>sa", function()
        builtin.find_files({
          hidden = true,
          no_ignore = true,
          file_ignore_patterns = {
            "node_modules",
            ".git",
            ".turbo",
            "dist",
          },
        })
      end, { desc = "All files" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Grep string" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Grep live" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Resume last" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Recent files" })

      -- Fuzzy search in the current buffer
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Fuzzy search" })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Neovim config" })
    end,
  },
}
