-- Kuala
vim.api.nvim_set_keymap(
  "n",
  "<C-k>",
  ":lua require('kulala').jump_prev()<CR>",
  { noremap = true, silent = true, desc = "Previous Request" }
)
vim.api.nvim_set_keymap(
  "n",
  "<C-j>",
  ":lua require('kulala').jump_next()<CR>",
  { noremap = true, silent = true, desc = "Next Request" }
)
vim.api.nvim_set_keymap(
  "n",
  "<C-l>",
  ":lua require('kulala').run()<CR>",
  { noremap = true, silent = true, desc = "RunRequest" }
)
vim.api.nvim_set_keymap(
  "n",
  "<C-t>",
  ":lua require('kulala').toggle_view()<CR>",
  { noremap = true, silent = true, desc = "Toggle Body/Headers" }
)
