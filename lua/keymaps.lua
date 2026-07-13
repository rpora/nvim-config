-- [[ Keymaps ]]

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

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

-- Hunks
vim.keymap.set("n", "<leader>cv", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>cz", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "[h", function()
  require("custom.git").nav_hunk("prev")
end, { desc = "Prev hunk" })
vim.keymap.set("n", "]h", function()
  require("custom.git").nav_hunk("next")
end, { desc = "Next hunk" })

-- Git
vim.keymap.set("n", "<leader>cf", "<cmd>Gedit :<cr>", { desc = "Git status dans la fenêtre courante" })
vim.keymap.set("n", "<leader>cc", "<cmd>GitHunks<cr>", { desc = "Changements Git dans la quickfix" })
vim.keymap.set("n", "<leader>cd", "<cmd>Gdiffsplit<cr>", { desc = "Diff du fichier courant" })
vim.keymap.set("n", "<leader>cu", "<cmd>Git diff HEAD -- %<cr>", { desc = "Diff unifié du fichier courant" })

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

-- Peack definition
vim.keymap.set("n", "<leader>gd", ":TSTextobjectPeekDefinitionCode @function.outer<CR>", { desc = "Peek Definition" })
