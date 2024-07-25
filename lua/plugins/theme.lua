return {
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
      vim.cmd("colorscheme kanagawa")
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
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}
