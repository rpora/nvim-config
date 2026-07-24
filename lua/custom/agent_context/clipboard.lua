local M = {}

---Copy text to the system clipboard without writing the unnamed register.
---@param text string
---@return boolean success
---@return string|nil error
function M.copy(text)
  if type(text) ~= "string" then
    return false, "Le contenu à copier doit être une chaîne de caractères."
  end

  local ok, copy_error = pcall(vim.fn.setreg, "+", text)
  if not ok then
    return false, "Impossible de copier dans le presse-papiers système : " .. tostring(copy_error)
  end

  return true, nil
end

---Notify that a labelled value was copied.
---@param label string
---@param text? string
function M.notify_copy(label, text)
  local detail = ""
  if text and text:find("\n", 1, true) then
    detail = (" (%d lignes)"):format(select(2, text:gsub("\n", "\n")) + 1)
  end

  vim.notify(("Copié : %s%s"):format(label, detail), vim.log.levels.INFO)
end

---@param message string
function M.notify_error(message)
  vim.notify(message, vim.log.levels.ERROR)
end

---@param message string
function M.notify_warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

return M
