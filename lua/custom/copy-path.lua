-- lua/refcopy.lua
local M = {}

-- 1) Root du projet : git > lsp > cwd
local function project_root(bufnr)
  bufnr = bufnr or 0
  local file = vim.api.nvim_buf_get_name(bufnr)
  local dir = (file ~= "" and vim.fs.dirname(file)) or vim.loop.cwd()

  -- git root
  local git = vim.fs.find(".git", { path = dir, upward = true })[1]
  if git then
    return vim.fs.dirname(git)
  end

  -- lsp root
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, c in ipairs(clients) do
    if c.config and c.config.root_dir and c.config.root_dir ~= "" then
      return c.config.root_dir
    end
    -- certains serveurs exposent workspace_folders
    if c.workspace_folders and c.workspace_folders[1] and c.workspace_folders[1].name then
      return c.workspace_folders[1].name
    end
  end

  -- fallback
  return vim.loop.cwd()
end

local function relpath_from_root(bufnr)
  bufnr = bufnr or 0
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return "[No Name]"
  end
  local root = project_root(bufnr)
  local rel = vim.fs.relpath(root, file)
  return rel or file
end

local function set_clipboard(text)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text) -- aussi dans le unnamed
  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

local function selected_line_range()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local s = vim.fn.getpos("v")[2]
    local e = vim.api.nvim_win_get_cursor(0)[1]
    if s > e then
      s, e = e, s
    end
    return s, e
  end

  local s = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]
  if s > e then
    s, e = e, s
  end
  return s, e
end

-- A) Copier chemin relatif à la racine
function M.copy_path()
  set_clipboard(relpath_from_root(0))
end

-- B) Copier chemin + numéro de ligne (format file:line)
function M.copy_path_line()
  local p = relpath_from_root(0)
  local l = vim.api.nvim_win_get_cursor(0)[1]
  set_clipboard(string.format("%s:%d", p, l))
end

-- C) Copier fichier:ligne:symbole (symbole = <cword>)
function M.copy_path_line_symbol()
  local p = relpath_from_root(0)
  local l = vim.api.nvim_win_get_cursor(0)[1]
  local sym = vim.fn.expand("<cword>")
  set_clipboard(string.format("%s:%d:%s", p, l, sym))
end

-- D) Copier fichier:{start-end} (+ optionnel: texte sélectionné)
-- Format: file:{start-end}
function M.copy_range()
  local start_line, end_line = selected_line_range()

  local p = relpath_from_root(0)
  set_clipboard(string.format("%s:{%d-%d}", p, start_line, end_line))
end

-- E) Copier fichier:{start-end}\n```<ft>\n<texte>\n```
-- Très pratique pour Codex si tu veux donner le contenu exact.
function M.copy_range_with_text()
  local p = relpath_from_root(0)
  local ft = vim.bo.filetype
  local s, e = selected_line_range()
  if s == 0 or e == 0 then
    local l = vim.api.nvim_win_get_cursor(0)[1]
    s, e = l, l
  end

  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  local body = table.concat(lines, "\n")

  local out = string.format("%s:{%d-%d}\n```%s\n%s\n```", p, s, e, ft, body)
  set_clipboard(out)
end

vim.keymap.set("n", "<leader>rp", M.copy_path, { desc = "Copy relative path (project root)" })
vim.keymap.set("n", "<leader>rl", M.copy_path_line, { desc = "Copy path:line" })
vim.keymap.set("n", "<leader>rs", M.copy_path_line_symbol, { desc = "Copy path:line:symbol" })
vim.keymap.set("v", "<leader>rr", M.copy_range, { desc = "Copy path:{start-end}" })
vim.keymap.set("v", "<leader>rR", M.copy_range_with_text, { desc = "Copy path:{start-end} + text" })

-- Expose comme commande
vim.api.nvim_create_user_command("CopyRelPath", M.copy_path, {})

return M
