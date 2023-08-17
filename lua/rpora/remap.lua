-- Files explorer
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex)

-- Move selection up/down
vim.keymap.set("v", "K", ":m '<-2/<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- Scroll at center of the screen 
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle of the screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Don't put the replaced value inside the register when pasted
vim.keymap.set("x", "<leader>p", "\"_dP")

