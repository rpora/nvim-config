return {
  -- Undo tree
  "mbbill/undotree",

  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    lazy = false,
  },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
