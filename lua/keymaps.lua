-- [[ Keymaps ]]

-- Files explorer
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })

-- Scroll at center of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Cancel search highlight
vim.keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>")

-- Quit terminal insert mode
vim.keymap.set("t", "<ESC>", "<C-\\><C-N>")

-- Navigating beetween Windows and panes
vim.keymap.set("n", "<C-Left>", "<c-w>h")
vim.keymap.set("n", "<C-Right>", "<c-w>l")
vim.keymap.set("n", "<C-Up>", "<c-w>k")
vim.keymap.set("n", "<C-Down>", "<c-w>j")

-- Resizing Windows
vim.keymap.set("n", "<C-M-Left>", ":vertical resize -5<CR>")
vim.keymap.set("n", "<C-M-Right>", ":vertical resize +5<CR>")
vim.keymap.set("n", "<C-M-Up>", ":resize +5<CR>")
vim.keymap.set("n", "<C-M-Down>", ":resize -5<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<F1>", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

-- Peack definition
vim.keymap.set("n", "<leader>gd", ":TSTextobjectPeekDefinitionCode @function.outer<CR>", { desc = "Peek Definition" })
