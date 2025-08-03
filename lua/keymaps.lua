-- [[ Keymaps ]]

-- Files explorer
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })

-- Scroll at center of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Diagnostic keymaps
vim.keymap.set("n", "<F1>", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })
