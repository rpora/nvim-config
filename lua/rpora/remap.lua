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

-- Save file easily
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- Move between buffers
vim.keymap.set("n", "<leader>b", ":buffers<CR>:buffer<Space>")

-- Copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_assumed_mapped = true

vim.keymap.set('i', '<M-!>', '<Plug>(copilot-dismiss)')
vim.keymap.set('i', '<M-;>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<M-,>', '<Plug>(copilot-previous)')
vim.keymap.set(
  "i", "<M-:>", 'copilot#Accept("<CR>")',
  { silent = true, expr = true, noremap = true, replace_keycodes = false}
)

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

--  Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
