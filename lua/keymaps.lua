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

-- Hunks
vim.keymap.set("n", "<leader>hs", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hz", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hq", ":Gitsigns setqflist<CR>", { desc = "Hunks List" })
vim.keymap.set("n", "[h", ":Gitsigns nav_hunk prev<CR>", { desc = "Prev hunk" })
vim.keymap.set("n", "]h", ":Gitsigns nav_hunk next<CR>", { desc = "Next hunk" })
