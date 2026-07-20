return {
  {
    "vague-theme/vague.nvim",
    init = function()
      require("vague").setup({
        transparent = true,
      })
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
          transparency = true,
        },
      })
    end,
  },
}
