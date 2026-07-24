-- [[ Keymaps ]]

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

-- Diagnostic
vim.keymap.set("n", "<leader>dc", vim.diagnostic.setloclist, { desc = "Diagnostics List" })
vim.keymap.set("n", "<leader>dv", vim.diagnostic.open_float, { desc = "Diagnostics Float" })

-- Agent context
local agent_context = require("custom.agent_context")
local cp = require("custom.copy-path")

vim.keymap.set("n", "<leader>ao", function()
  agent_context.open_prompt()
end, { desc = "Open Codex prompt" })

vim.keymap.set("n", "<leader>ac", function()
  agent_context.copy_prompt()
end, { desc = "Copy Codex prompt" })

vim.keymap.set("n", "<leader>ax", function()
  agent_context.clear_prompt()
end, { desc = "Clear Codex prompt" })

vim.keymap.set("n", "<leader>cp", function()
  cp.copy_path()
end, { desc = "Copy relative path (project root)" })

vim.keymap.set("n", "<leader>cl", function()
  cp.copy_path_line()
end, { desc = "Copy path:line" })

vim.keymap.set("n", "<leader>cs", function()
  cp.copy_path_line_symbol()
end, { desc = "Copy path:line:symbol" })

vim.keymap.set("x", "<leader>cr", function()
  cp.copy_range()
end, { desc = "Copy path:{start-end}" })

vim.keymap.set("x", "<leader>cR", function()
  cp.copy_range_with_text()
end, { desc = "Copy path:{start-end} + text" })

vim.keymap.set("n", "<leader>cd", function()
  agent_context.copy_file_diff()
end, { desc = "Copy current file diff" })

vim.keymap.set("n", "<leader>ch", function()
  agent_context.copy_current_hunk()
end, { desc = "Copy current Git hunk" })

vim.keymap.set("n", "<leader>ce", function()
  agent_context.copy_buffer_diagnostics()
end, { desc = "Copy buffer diagnostics" })

vim.keymap.set("n", "<leader>cE", function()
  agent_context.copy_cursor_diagnostics()
end, { desc = "Copy cursor diagnostics" })

vim.keymap.set("n", "<leader>cq", function()
  agent_context.copy_quickfix()
end, { desc = "Copy quickfix" })

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
-- Désactivé temporairement : <leader>cd est réservé à CopyFileDiff.
-- vim.keymap.set("n", "<leader>cd", "<cmd>Gdiffsplit<cr>", { desc = "Diff du fichier courant" })
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
