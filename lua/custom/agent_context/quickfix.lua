local clipboard = require("custom.agent_context.clipboard")
local path = require("custom.agent_context.path")

local M = {}

local max_items = 200

local function normalize_text(text)
  return vim.trim((text or ""):gsub("%s+", " "))
end

---@param item table
---@return string|nil
local function get_item_path(item)
  local filename
  if item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
    filename = vim.api.nvim_buf_get_name(item.bufnr)
  end
  if (not filename or filename == "") and item.filename and item.filename ~= "" then
    filename = item.filename
  end
  if not filename or filename == "" then
    return nil
  end

  local relative_path = path.get_relative_path_for_path(filename)
  return relative_path or vim.fs.normalize(filename)
end

---Copy the current quickfix list as compact Markdown.
function M.copy()
  local quickfix = vim.fn.getqflist({
    title = 1,
    items = 1,
    context = 1,
  })
  local items = quickfix.items or {}
  if #items == 0 then
    vim.notify("La quickfix est vide.", vim.log.levels.INFO)
    return
  end

  local title = quickfix.title ~= "" and quickfix.title or "Quickfix"
  local lines = { "## Quickfix — " .. title, "" }
  local copied_items = 0
  local limit = math.min(#items, max_items)

  for index = 1, limit do
    local item = items[index]
    local item_path = item.valid ~= 0 and get_item_path(item) or nil
    if item_path then
      local location = item_path
      if item.lnum and item.lnum > 0 then
        location = location .. ":" .. item.lnum
        if item.col and item.col > 0 then
          location = location .. ":" .. item.col
        end
      end

      table.insert(lines, ("- `%s` — %s"):format(location, normalize_text(item.text)))
      copied_items = copied_items + 1
    end
  end

  if copied_items == 0 then
    clipboard.notify_warn("La quickfix ne contient aucune entrée de fichier valide.")
    return
  end

  local omitted = #items - limit
  if omitted > 0 then
    table.insert(lines, "")
    table.insert(lines, ("_%d entrée(s) supplémentaire(s) omise(s)._"):format(omitted))
  end

  local content = table.concat(lines, "\n")
  local copied, copy_error = clipboard.copy(content)
  if not copied then
    clipboard.notify_error(copy_error)
    return
  end

  if omitted > 0 then
    clipboard.notify_warn(
      ("Quickfix copiée : %d entrées, %d omises."):format(copied_items, omitted)
    )
  else
    clipboard.notify_copy(("quickfix, %d entrée(s)"):format(copied_items), content)
  end
end

return M
