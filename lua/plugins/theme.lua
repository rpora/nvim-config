return {
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
      vim.cmd("colorscheme rose-pine")
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
