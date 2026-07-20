-- theme
vim.cmd("colorscheme vague")
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "100"

-- lines numbers
vim.o.number = true
vim.o.relativenumber = true

-- indentation
vim.o.breakindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "│ ",
  leadmultispace = "│ ",
}

-- history
vim.o.undofile = true
vim.o.swapfile = false

-- search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Default splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Show which line your cursor is on
vim.o.cursorline = true

-- Lisibility
vim.opt.cursorlineopt = "number,line"
vim.opt.scrolloff = 10

-- Misc
vim.o.clipboard = "unnamedplus"
vim.opt.spelllang = { "en", "fr" }

-- Diffs
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("linematch:60")

-- Allow local configuration
vim.opt.exrc = true
vim.opt.secure = true

-- Diagnostics
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = true,
  },
  virtual_text = false,
  jump = { on_jump = true },
})
