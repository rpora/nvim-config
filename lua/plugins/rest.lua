return {
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "luarocks.nvim" },
    config = function()
      require("rest-nvim").setup()
    end,
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
}
