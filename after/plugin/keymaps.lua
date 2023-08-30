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
vim.keymap.set("n", "<C-Left>", ":vertical resize +1<CR>", defaults_opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize -1<CR>", defaults_opts)
vim.keymap.set("n", "<C-Up>", ":resize -1<CR>", defaults_opts)
vim.keymap.set("n", "<C-Down>", ":resize +1<CR>", defaults_opts)

--  Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Zen mode
vim.keymap.set("n", "<leader>z", vim.cmd.ZenMode)

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Hop
vim.keymap.set("n", "<leader>n", vim.cmd.HopWord, { desc = "Hop" })
vim.keymap.set("n", "<leader>h", vim.cmd.HopPattern, { desc = "HopPattern" })

vim.keymap.set("n", "<leader>c", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })

-- Terminate line with ;
vim.keymap.set("n", "<leader>;", "A;<ESC>")
