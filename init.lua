vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
require("keymaps")
require("settings")
require("custom.copy-path")
require("custom.scratch")
require("custom.workflow")

-- vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
--   pattern = "%/templates/**/*.html", -- Adjust the path as needed
--   callback = function()
--     local clients = vim.lsp.get_active_clients({ name = "html" })
--     if next(clients) == nil then
--       vim.cmd('lua require"lspconfig".html.setup{}')
--     end
--   end,
-- })
