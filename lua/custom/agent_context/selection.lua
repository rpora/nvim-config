local M = {}

local visual_modes = {
  v = true,
  V = true,
  ["\22"] = true,
}

local function visual_region()
  local mode = vim.fn.mode()
  if visual_modes[mode] then
    return vim.fn.getpos("v"), vim.fn.getpos("."), mode
  end

  local last_mode = vim.fn.visualmode()
  if not visual_modes[last_mode] then
    last_mode = "v"
  end

  return vim.fn.getpos("'<"), vim.fn.getpos("'>"), last_mode
end

local function valid_position(position)
  return type(position) == "table" and (position[2] or 0) > 0
end

---Return the first and last lines of the current or latest visual selection.
---@return integer|nil start_line
---@return integer|string|nil end_line_or_error
---@return string|nil selection_type
function M.get_visual_range()
  local start_position, end_position, selection_type = visual_region()
  if not valid_position(start_position) or not valid_position(end_position) then
    return nil, "Aucune sélection visuelle valide.", nil
  end

  local start_line = math.min(start_position[2], end_position[2])
  local end_line = math.max(start_position[2], end_position[2])
  return start_line, end_line, selection_type
end

---Return the exact text of the current or latest visual selection.
---@return string|nil text
---@return string|nil error
function M.get_visual_selection()
  local start_position, end_position, selection_type = visual_region()
  if not valid_position(start_position) or not valid_position(end_position) then
    return nil, "Aucune sélection visuelle valide."
  end

  local lines = vim.fn.getregion(start_position, end_position, {
    type = selection_type,
  })

  if #lines == 0 then
    return nil, "La sélection visuelle est vide."
  end

  return table.concat(lines, "\n"), nil
end

return M
