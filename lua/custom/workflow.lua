local M = {}

-- ---------------------------------------------------------------------------
-- Quickfix List
-- ---------------------------------------------------------------------------

---Parse a location string in the form `file:line[:col]`.
---@param raw string
---@return string|nil filename
---@return integer|nil lnum
---@return integer|nil col
local function parse_location(raw)
  local filename, lnum, col = raw:match("^([^:]+):(%d+):(%d+)$")
  if filename then
    return filename, tonumber(lnum), tonumber(col)
  end

  filename, lnum = raw:match("^([^:]+):(%d+)$")
  if filename then
    return filename, tonumber(lnum), 1
  end

  return nil, nil, nil
end

---Remove the current quickfix entry, like marking a todo item as done.
---Keeps focus on the next valid entry, or closes quickfix when empty.
function M.quickfix_done()
  local qf = vim.fn.getqflist()
  if #qf == 0 then
    vim.notify("Quickfix vide.", vim.log.levels.INFO)
    return
  end

  local idx = vim.fn.getqflist({ idx = 0 }).idx
  if idx < 1 or idx > #qf then
    vim.notify("Aucune entree quickfix active.", vim.log.levels.WARN)
    return
  end

  table.remove(qf, idx)
  vim.fn.setqflist({}, "r", { items = qf })

  if #qf == 0 then
    vim.cmd("cclose")
    vim.notify("Quickfix terminee.", vim.log.levels.INFO)
    return
  end

  local next_idx = math.min(idx, #qf)
  vim.cmd(("cc %d"):format(next_idx))
end

---Add a new quickfix entry.
---Usage:
---  - `:Cadd` to add the current cursor location.
---  - `:Cadd file:line[:col] [text]` to add a custom location.
---@param opts { fargs?: string[] }
function M.quickfix_add(opts)
  local args = opts.fargs or {}
  local item = {}

  if #args == 0 then
    item.bufnr = vim.api.nvim_get_current_buf()
    item.lnum = vim.api.nvim_win_get_cursor(0)[1]
    item.col = vim.api.nvim_win_get_cursor(0)[2] + 1
    item.text = vim.api.nvim_get_current_line()
  else
    local filename, lnum, col = parse_location(args[1])
    if not filename then
      vim.notify("Usage: :Cadd <fichier:ligne[:col]> [texte]", vim.log.levels.ERROR)
      return
    end

    item.filename = filename
    item.lnum = lnum
    item.col = col
    item.text = table.concat(args, " ", 2)
  end

  vim.fn.setqflist({}, "a", { items = { item } })
  vim.cmd("copen")
end

---Run `pnpm tsc --pretty false` and populate quickfix with TypeScript errors.
---Expected format: `file(line,col): error TSxxxx: message`
function M.typescript_to_quickfix()
  local lines = vim.fn.systemlist("pnpm tsc --pretty false 2>&1")
  local items = {}

  for _, line in ipairs(lines) do
    local file, lnum, col, tscode, message = line:match("^(.+)%((%d+),(%d+)%)%s*:%s*error%s+TS(%d+):%s+(.+)$")

    if file then
      table.insert(items, {
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = string.format("TS%s: %s", tscode, message),
        type = "E",
      })
    end
  end

  vim.fn.setqflist({}, "r", {
    title = "TypeScript",
    items = items,
  })

  if #items > 0 then
    vim.cmd("copen")
  end
end

--- Commands

vim.api.nvim_create_user_command("Cdone", M.quickfix_done, {
  desc = "Remove current quickfix entry",
  force = true,
})

vim.api.nvim_create_user_command("Cadd", M.quickfix_add, {
  desc = "Add entry to quickfix list",
  nargs = "*",
  complete = "file",
  force = true,
})

vim.api.nvim_create_user_command("Cts", M.typescript_to_quickfix, {
  desc = "Populate quickfix list from TypeScript diagnostics",
  force = true,
})

return M
