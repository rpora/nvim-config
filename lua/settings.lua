vim.o.clipboard = "unnamedplus"

-- lines numbers
vim.o.number = true
vim.o.relativenumber = true

-- indentation
vim.o.breakindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- save history
vim.o.undofile = true

-- disable swap files, as we auto-save when quitting insert mode
vim.o.swapfile = false

-- search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Preview substitutions
vim.opt.inccommand = "split"

-- signcolumn on
vim.wo.signcolumn = "yes"

-- update time
vim.o.updatetime = 250

vim.o.termguicolors = true

-- Default splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Show which line your cursor is on
vim.o.cursorline = true

-- lines to keep above and below the cursor
vim.opt.scrolloff = 10

vim.opt.hidden = true

-- Remove auto comment on new line below a comment
vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

