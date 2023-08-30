vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true

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
vim.opt.cmdheight = 0

vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.timeout = true
vim.opt.timeoutlen = 300

vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

vim.opt.hidden = true

vim.opt.clipboard = "unnamedplus"

-- Search: add all subdirectories from pwd
vim.opt.path:remove "/usr/include"
vim.opt.path:append "**"

-- Highlight on yank
vim.cmd [[
    augroup YankHighlight
        autocmd!
        autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup end
]]

-- vim.cmd [[hi ActiveWindow guibg=#2e3440 ]]
-- vim.cmd [[hi InactiveWindow guibg=#3b4252]]
-- vim.cmd [[ set winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow]]

-- Netrw
vim.g.netrw_banner = 0

vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#79bcd7" })
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#79bcd7"})

