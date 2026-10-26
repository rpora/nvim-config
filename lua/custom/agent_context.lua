-- Copy file references, selections, diagnostics and the quickfix list to the system clipboard,
-- formatted to be pasted into an agent prompt.
local M = {}

local max_quickfix_items = 200

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warning",
  [vim.diagnostic.severity.INFO] = "info",
  [vim.diagnostic.severity.HINT] = "hint",
}

---Return a path relative to its Git root, or relative to the cwd outside a repository.
---@param file string
---@return string
local function relpath(file)
  file = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
  local root = vim.fs.root(file, ".git")
  return root and vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":~:.")
end

---@return string|nil
local function buffer_relpath()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Le buffer courant n'est associé à aucun fichier.", vim.log.levels.ERROR)
    return nil
  end

  return relpath(file)
end

local function one_line(text)
  return vim.trim((text or ""):gsub("%s+", " "))
end

---Copy text to the system clipboard and report it.
---@param text string
---@param label string
local function copy(text, label)
  vim.fn.setreg("+", text)
  local line_count = select(2, text:gsub("\n", "")) + 1
  local detail = line_count > 1 and (" (%d lignes)"):format(line_count) or ""
  vim.notify(("Copié : %s%s"):format(label, detail), vim.log.levels.INFO)
end

-- Visual selection helpers, meant to be called from a visual mode mapping.

local function visual_lines()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  return math.min(first, last), math.max(first, last)
end

local function selected_lines()
  return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
end

-- File references

---Copy `path`.
function M.copy_path()
  local path = buffer_relpath()
  if path then
    copy(path, path)
  end
end

---Copy `path:line`.
function M.copy_path_line()
  local path = buffer_relpath()
  if path then
    local reference = ("%s:%d"):format(path, vim.fn.line("."))
    copy(reference, reference)
  end
end

---Copy `path:line:symbol`, where the symbol is the word under the cursor.
function M.copy_path_line_symbol()
  local path = buffer_relpath()
  if not path then
    return
  end

  local reference = ("%s:%d"):format(path, vim.fn.line("."))
  local symbol = vim.fn.expand("<cword>")
  if symbol ~= "" then
    reference = reference .. ":" .. symbol
  end
  copy(reference, reference)
end

---Copy `path:{start-end}` for the visual selection.
function M.copy_range()
  local path = buffer_relpath()
  if path then
    local reference = ("%s:{%d-%d}"):format(path, visual_lines())
    copy(reference, reference)
  end
end

---Copy `path:{start-end}` followed by the selected text in a Markdown fence.
function M.copy_range_with_text()
  local path = buffer_relpath()
  if not path then
    return
  end

  local reference = ("%s:{%d-%d}"):format(path, visual_lines())
  local output = table.concat({
    reference,
    "```" .. vim.bo.filetype,
    table.concat(selected_lines(), "\n"),
    "```",
  }, "\n")
  copy(output, reference)
end

-- Diagnostics

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

  return table.concat(parts, " ") .. " — " .. one_line(diagnostic.message)
end

---@param diagnostics vim.Diagnostic[]
---@param empty_message string
local function copy_diagnostics(diagnostics, empty_message)
  if #diagnostics == 0 then
    vim.notify(empty_message, vim.log.levels.INFO)
    return
  end

  local path = buffer_relpath()
  if not path then
    return
  end

  table.sort(diagnostics, function(left, right)
    if left.lnum ~= right.lnum then
      return left.lnum < right.lnum
    end
    if left.col ~= right.col then
      return left.col < right.col
    end
    return (left.severity or math.huge) < (right.severity or math.huge)
  end)

  local lines = { "## Diagnostics — " .. path, "" }
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(lines, format_diagnostic(diagnostic))
  end
  copy(table.concat(lines, "\n"), ("%d diagnostic(s)"):format(#diagnostics))
end

---Copy every diagnostic of the current buffer.
function M.copy_buffer_diagnostics()
  copy_diagnostics(vim.diagnostic.get(0), "Aucun diagnostic dans le buffer courant.")
end

---Copy the diagnostics whose range includes the cursor line.
function M.copy_cursor_diagnostics()
  local line = vim.fn.line(".") - 1
  local diagnostics = vim.tbl_filter(function(diagnostic)
    return diagnostic.lnum <= line and (diagnostic.end_lnum or diagnostic.lnum) >= line
  end, vim.diagnostic.get(0))
  copy_diagnostics(diagnostics, "Aucun diagnostic sous le curseur.")
end

-- Quickfix

---@param item vim.quickfix.entry
---@return string|nil
local function quickfix_location(item)
  if item.valid == 0 or item.bufnr == 0 or not vim.api.nvim_buf_is_valid(item.bufnr) then
    return nil
  end

  local file = vim.api.nvim_buf_get_name(item.bufnr)
  if file == "" then
    return nil
  end

  local location = relpath(file)
  if item.lnum > 0 then
    location = location .. ":" .. item.lnum
    if item.col > 0 then
      location = location .. ":" .. item.col
    end
  end
  return location
end

---Copy the current quickfix list as compact Markdown.
function M.copy_quickfix()
  local quickfix = vim.fn.getqflist({ title = 1, items = 1 })
  local items = quickfix.items
  if #items == 0 then
    vim.notify("La quickfix est vide.", vim.log.levels.INFO)
    return
  end

  local title = quickfix.title ~= "" and quickfix.title or "Quickfix"
  local lines = { "## Quickfix — " .. title, "" }
  local copied = 0
  local limit = math.min(#items, max_quickfix_items)

  for index = 1, limit do
    local item = items[index]
    local location = quickfix_location(item)
    if location then
      table.insert(lines, ("- `%s` — %s"):format(location, one_line(item.text)))
      copied = copied + 1
    end
  end

  if copied == 0 then
    vim.notify("La quickfix ne contient aucune entrée de fichier valide.", vim.log.levels.WARN)
    return
  end

  local label = ("quickfix, %d entrée(s)"):format(copied)
  local omitted = #items - limit
  if omitted > 0 then
    table.insert(lines, "")
    table.insert(lines, ("_%d entrée(s) supplémentaire(s) omise(s)._"):format(omitted))
    label = label .. (", %d omise(s)"):format(omitted)
  end

  copy(table.concat(lines, "\n"), label)
end

-- Herdr

---Hand the visual selection over to Herdr Annotate. The plugin cannot see a Neovim selection, so
---it reads it once from a file (ignored after 15 s).
function M.herdr_annotate()
  local lines = selected_lines()
  local base = os.getenv("XDG_RUNTIME_DIR")
  if not base or base == "" then
    base = vim.uv.os_tmpdir()
  end
  local dir = base .. "/herdr-annotate-" .. vim.uv.getuid()
  vim.fn.mkdir(dir, "p", tonumber("700", 8))
  vim.fn.writefile(lines, dir .. "/selection")
  vim.cmd("normal! " .. vim.keycode("<Esc>"))
  vim.fn.jobstart({ "herdr", "plugin", "action", "invoke", "annotate.capture" })
end

-- Commands

vim.api.nvim_create_user_command("CopyRelPath", M.copy_path, {
  desc = "Copier le chemin relatif à la racine Git",
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
