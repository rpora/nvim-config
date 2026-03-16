return {
  -- Undo tree
  "mbbill/undotree",

  -- Explorer
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

  -- Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
      require("render-markdown").setup({
        heading = {
          enabled = true,
          backgrounds = {},
        },
      })
    end,
  },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
