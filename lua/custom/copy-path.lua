local context = require("custom.agent_context")

local M = {}

local function relative_path()
  local path, path_error = context.get_relative_path(0)
  if not path then
    context.notify_error(path_error)
    return nil
  end

  return path
end

local function copy(text, label)
  local ok, copy_error = context.copy_to_clipboard(text)
  if not ok then
    context.notify_error(copy_error)
    return
  end

  context.notify_copy(label, text)
end

-- A) Copier chemin relatif à la racine
function M.copy_path()
  local path = relative_path()
  if path then
    copy(path, path)
  end
end

-- B) Copier chemin + numéro de ligne (format file:line)
function M.copy_path_line()
  local path = relative_path()
  if not path then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local reference = string.format("%s:%d", path, line)
  copy(reference, reference)
end

-- C) Copier fichier:ligne:symbole (symbole = <cword>)
function M.copy_path_line_symbol()
  local path = relative_path()
  if not path then
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local symbol = context.get_current_symbol(0)
  local reference = string.format("%s:%d", path, line)
  if symbol then
    reference = reference .. ":" .. symbol
  end

  copy(reference, reference)
end

-- D) Copier fichier:{start-end} (+ optionnel: texte sélectionné)
-- Format: file:{start-end}
function M.copy_range()
  local path = relative_path()
  if not path then
    return
  end

  local start_line, end_line = context.get_visual_range()
  if not start_line then
    context.notify_error(end_line)
    return
  end

  local reference = string.format("%s:{%d-%d}", path, start_line, end_line)
  copy(reference, reference)
end

-- E) Copier fichier:{start-end}\n```<ft>\n<texte>\n```
-- Très pratique pour Codex si tu veux donner le contenu exact.
function M.copy_range_with_text()
  local path = relative_path()
  if not path then
    return
  end

  local start_line, end_line = context.get_visual_range()
  if not start_line then
    context.notify_error(end_line)
    return
  end

  local selection, selection_error = context.get_visual_selection()
  if not selection then
    context.notify_error(selection_error)
    return
  end

  local opening_fence, closing_fence = context.get_markdown_fence(0)
  local reference = string.format("%s:{%d-%d}", path, start_line, end_line)
  local output = table.concat({
    reference,
    opening_fence,
    selection,
    closing_fence,
  }, "\n")

  copy(output, reference)
end

-- Expose comme commande
vim.api.nvim_create_user_command("CopyRelPath", M.copy_path, {})

return M
