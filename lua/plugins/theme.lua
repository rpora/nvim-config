return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      -- vim.cmd("colorscheme catpucccin")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    init = function()
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },
  {

    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    init = function()
      require("kanagawa").setup({
        commentStyle = { italic = true },
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
      })
      -- vim.cmd("colorscheme kanagawa")
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    init = function()
      require("rose-pine").setup({
        styles = {
          bold = true,
          italic = false,
        },
      })
    end,
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        backdrop = 1,
        width = 120, -- width of the Zen window
        height = 1, -- height of the Zen window
        options = {
          signcolumn = "no", -- disable signcolumn
          number = false, -- disable number column
          relativenumber = true, -- disable relative numbers
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = true,
          showcmd = false,
          laststatus = 0,
        },
        tmux = { enabled = true }, -- disables the tmux statusline
        kitty = {
          enabled = true,
          font = "+20", -- (10% increase per step)
        },
      },
    },
  },
}
