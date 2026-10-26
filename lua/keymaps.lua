-- [[ Keymaps ]]

-- Files explorer
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Explorer" })

-- Scroll at center of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Cancel search highlight
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<bar>echo<cr>")

-- Diagnostic
vim.keymap.set("n", "<leader>dc", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- Agent context
local agent_context = require("custom.agent_context")

vim.keymap.set("n", "<leader>cp", agent_context.copy_path, { desc = "Copy relative path (project root)" })
vim.keymap.set("n", "<leader>cl", agent_context.copy_path_line, { desc = "Copy path:line" })
vim.keymap.set("n", "<leader>cs", agent_context.copy_path_line_symbol, { desc = "Copy path:line:symbol" })
vim.keymap.set("x", "<leader>cr", agent_context.copy_range, { desc = "Copy path:{start-end}" })
vim.keymap.set("x", "<leader>cR", agent_context.copy_range_with_text, { desc = "Copy path:{start-end} + text" })
vim.keymap.set("n", "<leader>ce", agent_context.copy_buffer_diagnostics, { desc = "Copy buffer diagnostics" })
vim.keymap.set("n", "<leader>cE", agent_context.copy_cursor_diagnostics, { desc = "Copy cursor diagnostics" })
vim.keymap.set("n", "<leader>cq", agent_context.copy_quickfix, { desc = "Copy quickfix" })
vim.keymap.set("x", "<leader>a", agent_context.herdr_annotate, { desc = "Annotate in Herdr" })

-- Undo tree
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Undotree" })

-- Hunks
vim.keymap.set("n", "<leader>gv", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>gz", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
vim.keymap.set("n", "[h", function()
  require("custom.git").nav_hunk("prev")
end, { desc = "Prev hunk" })
vim.keymap.set("n", "]h", function()
  require("custom.git").nav_hunk("next")
end, { desc = "Next hunk" })

-- Git
vim.keymap.set("n", "<leader>gc", "<cmd>GitHunks<cr>", { desc = "Changements Git dans la quickfix" })
vim.keymap.set("n", "<leader>gu", "<cmd>Git diff HEAD -- %<cr>", { desc = "Diff unifié du fichier courant" })

-- Navigating beetween Windows and panes
vim.keymap.set("n", "<C-Left>", "<c-w>h")
vim.keymap.set("n", "<C-Right>", "<c-w>l")
vim.keymap.set("n", "<C-Up>", "<c-w>k")
vim.keymap.set("n", "<C-Down>", "<c-w>j")

-- Resizing Windows
vim.keymap.set("n", "<C-M-Left>", "<cmd>vertical resize -5<cr>")
vim.keymap.set("n", "<C-M-Right>", "<cmd>vertical resize +5<cr>")
vim.keymap.set("n", "<C-M-Up>", "<cmd>resize +5<cr>")
vim.keymap.set("n", "<C-M-Down>", "<cmd>resize -5<cr>")
