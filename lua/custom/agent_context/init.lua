local clipboard = require("custom.agent_context.clipboard")
local diagnostics = require("custom.agent_context.diagnostics")
local git = require("custom.agent_context.git")
local path = require("custom.agent_context.path")
local prompt = require("custom.agent_context.prompt")
local quickfix = require("custom.agent_context.quickfix")
local selection = require("custom.agent_context.selection")

local M = {
  copy_buffer_diagnostics = diagnostics.copy_buffer,
  copy_cursor_diagnostics = diagnostics.copy_cursor,
  copy_current_hunk = git.copy_current_hunk,
  copy_file_diff = git.copy_file_diff,
  copy_quickfix = quickfix.copy,
  copy_to_clipboard = clipboard.copy,
  get_buffer_path = path.get_buffer_path,
  get_git_root = path.get_git_root,
  get_relative_path = path.get_relative_path,
  get_visual_range = selection.get_visual_range,
  get_visual_selection = selection.get_visual_selection,
  open_prompt = prompt.open,
}

local function normalize_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end

  return bufnr
end

---Return the filetype associated with a buffer.
---@param bufnr? integer
---@return string
function M.get_filetype(bufnr)
  bufnr = normalize_bufnr(bufnr)
  return vim.bo[bufnr].filetype
end

---Return the opening and closing Markdown fences for a buffer.
---@param bufnr? integer
---@return string opening
---@return string closing
function M.get_markdown_fence(bufnr)
  return "```" .. M.get_filetype(bufnr), "```"
end

---Return the word under the cursor in a buffer.
---@param bufnr? integer
---@return string|nil symbol
function M.get_current_symbol(bufnr)
  bufnr = normalize_bufnr(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  local symbol
  vim.api.nvim_buf_call(bufnr, function()
    symbol = vim.fn.expand("<cword>")
  end)

  if symbol == "" then
    return nil
  end

  return symbol
end

M.notify_copy = clipboard.notify_copy
M.notify_error = clipboard.notify_error

---Copy the complete session prompt to the system clipboard.
---@return boolean success
function M.copy_prompt()
  local bufnr = prompt.get_buffer()
  if not bufnr then
    M.notify_error("Aucun prompt Codex n'existe dans cette session.")
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")
  local copied, copy_error = M.copy_to_clipboard(content)
  if not copied then
    M.notify_error(copy_error)
    return false
  end

  vim.notify(
    ("Prompt Codex copié : %d lignes, %d caractères."):format(#lines, #content),
    vim.log.levels.INFO
  )
  return true
end

---Clear the session prompt after explicit confirmation.
---@return boolean success
function M.clear_prompt()
  if not prompt.get_buffer() then
    M.notify_error("Aucun prompt Codex n'existe dans cette session.")
    return false
  end

  local choice = vim.fn.confirm(
    "Vider le prompt Codex ?",
    "&Oui\n&Non",
    2
  )
  if choice ~= 1 then
    vim.notify("Nettoyage du prompt Codex annulé.", vim.log.levels.INFO)
    return false
  end

  local cleared, clear_error = prompt.clear()
  if not cleared then
    M.notify_error(clear_error)
    return false
  end

  vim.notify("Prompt Codex vidé.", vim.log.levels.INFO)
  return true
end

vim.api.nvim_create_user_command("CodexPrompt", M.open_prompt, {
  desc = "Ouvrir le prompt Codex de la session",
})
vim.api.nvim_create_user_command("CopyCodexPrompt", M.copy_prompt, {
  desc = "Copier le prompt Codex dans le presse-papiers",
})
vim.api.nvim_create_user_command("ClearCodexPrompt", M.clear_prompt, {
  desc = "Vider le prompt Codex après confirmation",
})
vim.api.nvim_create_user_command("CopyFileDiff", M.copy_file_diff, {
  desc = "Copier le diff Git du fichier courant",
})
vim.api.nvim_create_user_command("CopyCurrentHunk", M.copy_current_hunk, {
  desc = "Copier le hunk Git sous le curseur",
})
vim.api.nvim_create_user_command("CopyBufferDiagnostics", M.copy_buffer_diagnostics, {
  desc = "Copier les diagnostics du buffer courant",
})
vim.api.nvim_create_user_command("CopyCursorDiagnostics", M.copy_cursor_diagnostics, {
  desc = "Copier les diagnostics sous le curseur",
})
vim.api.nvim_create_user_command("CopyQuickfix", M.copy_quickfix, {
  desc = "Copier la quickfix courante",
})

return M
