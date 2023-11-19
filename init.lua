-- package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct


require("lazy").setup("plugins")

----- settings

vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.guicursor = 'n-v-c-sm:block,ci-ve:ver25,r-cr-o:hor20,i:block-blinkwait700-blinkoff400-blinkon250-Cursor/lCursor'
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.timeout = true
vim.opt.timeoutlen = 500

vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
-- vim.opt.cursorline = true

vim.opt.hidden = true

vim.opt.clipboard = "unnamedplus"

-- Highlight on yank
vim.cmd [[
    augroup YankHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
]]

-- Netrw
vim.g.netrw_banner = 0

vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#79bcd7" })
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#79bcd7" })

vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }



----------- keymaps

local defaults_opts = { noremap = true, silent = true }

-- Files explorer
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Explorer" })

-- Scroll at center of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Paste over
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Save file
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("", "<leader>q", ":q<CR>")

-- Switch Buffer
vim.keymap.set("n", "<C-h>", ":bprevious<CR>", defaults_opts)
vim.keymap.set("n", "<C-l>", ":bnext<CR>", defaults_opts)

-- Cancel search highlight
vim.keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", defaults_opts)

-- Resizing
vim.keymap.set("n", "<C-Left>", ":vertical resize -5<CR>", defaults_opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", defaults_opts)
vim.keymap.set("n", "<C-Up>", ":resize -1<CR>", defaults_opts)
vim.keymap.set("n", "<C-Down>", ":resize +1<CR>", defaults_opts)

-- Zen mode
vim.keymap.set("n", "<leader>z", vim.cmd.ZenMode)

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Terminate line with ;
vim.keymap.set("n", "<leader>;", "A;<ESC>")
