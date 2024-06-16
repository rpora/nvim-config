return {
  -- Surround commands
  "tpope/vim-surround",

  -- Undo tree
  "mbbill/undotree",

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Css colors
  {
    "NvChad/nvim-colorizer.lua",
    init = function()
      require("colorizer").setup({
        filetypes = { "css" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          RRGGBBAA = true,
          rgb_fn = true,
          hsl_fn = true,
          mode = "virtualtext", -- Set the display mode.
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = false, -- Enable tailwind colors
          sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■",
          always_update = false,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      })
    end,
  },
}
