return {
  {
    "wtfox/jellybeans.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        italics = false,
        flat_ui = false,
      },
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
}
