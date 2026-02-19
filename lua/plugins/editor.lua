return {
  -- Undo tree
  "mbbill/undotree",

  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        columns = {
          "permissions",
          "size",
          "mtime",
        },
        view_options = {
          show_hidden = true,
        },
      })
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    lazy = false,
  },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
