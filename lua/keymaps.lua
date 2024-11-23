-- [[ Keymaps ]]

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostics Popup" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Save
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })

-- Files explorer
vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Explorer" })

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

vim.keymap.set("n", "<C-Left>", ":TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":TmuxNavigateRight<CR>", { silent = true })
vim.keymap.set("n", "<C-Up>", ":TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":TmuxNavigateDown<CR>", { silent = true })

-- Resizing Windows
vim.keymap.set("n", "<C-M-Left>", ":vertical resize -5<CR>")
vim.keymap.set("n", "<C-M-Right>", ":vertical resize +5<CR>")
vim.keymap.set("n", "<C-M-Up>", ":resize +5<CR>")
vim.keymap.set("n", "<C-M-Down>", ":resize -5<CR>")

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

-- Zen mode
vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { desc = "Zen mode" })

-- Peack definition
vim.keymap.set("n", "<leader>gd", ":TSTextobjectPeekDefinitionCode @function.outer<CR>", { desc = "Peek Definition" })

-- LLM Chat
vim.keymap.set("n", "<leader>cc", ":Gen Chat<CR>", { desc = "Chat AI" })

-- Toggle relative lines numbers
vim.keymap.set("n", "<leader>rl", function()
  vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative lines numbers" })

-- Outline
vim.keymap.set("n", "<leader>ou", "<cmd>Outline<CR>", { desc = "Code Outline" })

-- Rest
vim.keymap.set("n", "<leader>rr", ":Rest run<CR>", { desc = "Run request" })
