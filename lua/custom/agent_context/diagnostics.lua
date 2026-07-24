local clipboard = require("custom.agent_context.clipboard")
local path = require("custom.agent_context.path")

local M = {}

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warning",
  [vim.diagnostic.severity.INFO] = "info",
  [vim.diagnostic.severity.HINT] = "hint",
}

local function normalize_message(message)
  return vim.trim((message or ""):gsub("%s+", " "))
end

---@param diagnostic vim.Diagnostic
---@return string
local function format_diagnostic(diagnostic)
  local parts = {
    ("- `%d:%d`"):format(diagnostic.lnum + 1, diagnostic.col + 1),
    severity_names[diagnostic.severity] or "unknown",
  }

  if diagnostic.code ~= nil and tostring(diagnostic.code) ~= "" then
    table.insert(parts, ("`%s`"):format(diagnostic.code))
  end
  if diagnostic.source and diagnostic.source ~= "" then
    table.insert(parts, ("`%s`"):format(diagnostic.source))
  end

  return table.concat(parts, " ") .. " — " .. normalize_message(diagnostic.message)
end

---@param diagnostics vim.Diagnostic[]
local function sort_diagnostics(diagnostics)
  table.sort(diagnostics, function(left, right)
    if left.lnum ~= right.lnum then
      return left.lnum < right.lnum
    end
    if left.col ~= right.col then
      return left.col < right.col
    end
    return (left.severity or math.huge) < (right.severity or math.huge)
  end)
end

---@param diagnostics vim.Diagnostic[]
---@param bufnr integer
---@param empty_message string
local function copy_diagnostics(diagnostics, bufnr, empty_message)
  if #diagnostics == 0 then
    vim.notify(empty_message, vim.log.levels.INFO)
    return
  end

  local relative_path, relative_error = path.get_relative_path(bufnr)
  if not relative_path then
    clipboard.notify_error(relative_error)
    return
  end

  sort_diagnostics(diagnostics)
  local lines = { "## Diagnostics — " .. relative_path, "" }
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(lines, format_diagnostic(diagnostic))
  end

  local content = table.concat(lines, "\n")
  local copied, copy_error = clipboard.copy(content)
  if not copied then
    clipboard.notify_error(copy_error)
    return
  end

  clipboard.notify_copy(("%d diagnostic(s)"):format(#diagnostics), content)
end

---Copy every diagnostic in the current buffer.
---@param bufnr? integer
function M.copy_buffer(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  copy_diagnostics(
    vim.diagnostic.get(bufnr),
    bufnr,
    "Aucun diagnostic dans le buffer courant."
  )
end

---Copy diagnostics whose range intersects the cursor line.
---@param bufnr? integer
function M.copy_cursor(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = {}

  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    local end_line = diagnostic.end_lnum or diagnostic.lnum
    if diagnostic.lnum <= cursor_line and end_line >= cursor_line then
      table.insert(diagnostics, diagnostic)
    end
  end

  copy_diagnostics(
    diagnostics,
    bufnr,
    "Aucun diagnostic sous le curseur."
  )
end

return M
