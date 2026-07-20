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

  -- Auto pairs
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
}
