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

---Set the quickfix list from diagnostic items.
---@param title string
---@param items table[]
local function set_diagnostics_quickfix(title, items)
  vim.fn.setqflist({}, "r", {
    title = title,
    items = items,
  })

  if #items > 0 then
    vim.cmd("copen")
  else
    vim.notify(("Aucun diagnostic %s."):format(title), vim.log.levels.INFO)
  end
end

---Parse TypeScript diagnostics from `tsc --pretty false`.
---@param output string
---@return table[]
local function parse_typescript_output(output)
  local items = {}

  for line in vim.gsplit(output, "\n", { plain = true }) do
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

  return items
end

---Parse ESLint JSON output.
---@param output string
---@return table[]|nil items
---@return string|nil error
local function parse_eslint_output(output)
  if output == "" then
    return {}
  end

  local ok, results = pcall(vim.json.decode, output)
  if not ok then
    return nil, "Impossible de parser la sortie JSON d'ESLint."
  end

  local items = {}

  for _, result in ipairs(results or {}) do
    for _, message in ipairs(result.messages or {}) do
      local rule = message.ruleId and ("(" .. message.ruleId .. ")") or ""
      local qf_type = message.severity == 2 and "E" or "W"

      table.insert(items, {
        filename = result.filePath,
        lnum = message.line or 1,
        col = message.column or 1,
        end_lnum = message.endLine,
        end_col = message.endColumn,
        text = string.format("ESLint%s: %s", rule, message.message or ""),
        type = qf_type,
      })
    end
  end

  return items
end

local knip_issue_types = {
  { key = "files", title = "Unused files" },
  { key = "dependencies", title = "Unused dependencies" },
  { key = "devDependencies", title = "Unused devDependencies" },
  { key = "optionalPeerDependencies", title = "Referenced optional peerDependencies" },
  { key = "unlisted", title = "Unlisted dependencies" },
  { key = "binaries", title = "Unlisted binaries" },
  { key = "unresolved", title = "Unresolved imports" },
  { key = "exports", title = "Unused exports" },
  { key = "nsExports", title = "Exports in used namespace" },
  { key = "types", title = "Unused exported types" },
  { key = "nsTypes", title = "Exported types in used namespace" },
  { key = "enumMembers", title = "Unused exported enum members" },
  { key = "namespaceMembers", title = "Unused exported namespace members" },
  { key = "duplicates", title = "Duplicate exports", separator = ", " },
  { key = "catalog", title = "Unused catalog entries" },
  { key = "cycles", title = "Circular dependencies", separator = " -> " },
}

---Parse Knip JSON output.
---@param output string
---@return table[]|nil items
---@return string|nil error
local function parse_knip_output(output)
  local json_start = output:find("{", 1, true)
  if not json_start then
    return nil, "Impossible de trouver la sortie JSON de Knip."
  end

  local ok, report = pcall(vim.json.decode, output:sub(json_start))
  if not ok or type(report) ~= "table" or type(report.issues) ~= "table" then
    return nil, "Impossible de parser la sortie JSON de Knip."
  end

  local items = {}

  ---@param filename string
  ---@param title string
  ---@param symbols table[]
  ---@param separator string
  local function add_item(filename, title, symbols, separator)
    local names = {}
    local lnum = 1
    local col = 1
    local has_location = false

    for _, symbol in ipairs(symbols) do
      if type(symbol) == "table" then
        local name = symbol.name
        if type(name) == "string" then
          if type(symbol.namespace) == "string" and symbol.namespace ~= "" then
            name = symbol.namespace .. "." .. name
          end
          table.insert(names, name)
        end

        if not has_location and type(symbol.line) == "number" then
          lnum = symbol.line
          col = type(symbol.col) == "number" and symbol.col or 1
          has_location = true
        end
      end
    end

    table.insert(items, {
      filename = filename,
      lnum = lnum,
      col = col,
      text = string.format("Knip (%s): %s", title, table.concat(names, separator)),
      type = "W",
    })
  end

  for _, file_issues in ipairs(report.issues) do
    if type(file_issues) == "table" and type(file_issues.file) == "string" then
      for _, issue_type in ipairs(knip_issue_types) do
        local issues = file_issues[issue_type.key]
        if type(issues) == "table" then
          for _, issue in ipairs(issues) do
            if issue_type.separator then
              if type(issue) == "table" then
                add_item(file_issues.file, issue_type.title, issue, issue_type.separator)
              end
            elseif type(issue) == "table" then
              add_item(file_issues.file, issue_type.title, { issue }, ", ")
            end
          end
        end
      end
    end
  end

  return items
end

---Quality gates whose diagnostics can be loaded into the quickfix list.
---`parse` returns quickfix items, or nil and an error message.
local checks = {
  typescript = {
    title = "TypeScript",
    command = function()
      return { "pnpm", "tsc", "--pretty", "false" }
    end,
    parse = function(result)
      return parse_typescript_output(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))
    end,
  },
  eslint = {
    title = "ESLint",
    command = function(targets)
      local command = { "pnpm", "exec", "eslint" }
      vim.list_extend(command, #targets > 0 and targets or { "." })
      vim.list_extend(command, { "--format", "json" })
      return command
    end,
    parse = function(result)
      return parse_eslint_output(result.stdout or "")
    end,
  },
  knip = {
    title = "Knip",
    command = function()
      return { "pnpm", "knip", "--reporter", "json", "--no-progress", "--no-exit-code" }
    end,
    parse = function(result)
      return parse_knip_output(result.stdout or "")
    end,
  },
}

---Run quality gates in parallel and load their combined diagnostics into the quickfix list.
---A gate whose output cannot be parsed is reported and left out.
---@param names string[] keys of `checks`
---@param targets? string[] ESLint targets, the whole project by default
local function run_checks(names, targets)
  local title = table.concat(
    vim.tbl_map(function(name)
      return checks[name].title
    end, names),
    " + "
  )
  vim.notify(("%s: %s en cours..."):format(title, #names > 1 and "checks" or "check"), vim.log.levels.INFO)

  local pending = #names
  local items = {}
  local parsed = false

  for _, name in ipairs(names) do
    local check = checks[name]
    vim.system(
      check.command(targets or {}),
      { text = true },
      vim.schedule_wrap(function(result)
        local check_items, err = check.parse(result)
        if check_items then
          vim.list_extend(items, check_items)
          parsed = true
        else
          vim.notify(err, vim.log.levels.ERROR)
          if result.stderr and result.stderr ~= "" then
            vim.notify(result.stderr, vim.log.levels.ERROR)
          end
        end

        pending = pending - 1
        if pending == 0 and parsed then
          set_diagnostics_quickfix(title, items)
        end
      end)
    )
  end
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
  run_checks({ "typescript" })
end

---Run ESLint and populate quickfix with lint diagnostics.
---Usage:
---  - `:Ceslint` to lint the current project.
---  - `:Ceslint app/foo.ts app/bar.tsx` to lint explicit targets.
function M.eslint_to_quickfix(opts)
  run_checks({ "eslint" }, opts.fargs)
end

---Run Knip and populate quickfix with unused-code diagnostics.
function M.knip_to_quickfix()
  run_checks({ "knip" })
end

---Run TypeScript, ESLint and Knip checks, then populate one quickfix list.
---Usage:
---  - `:Ccheck` to check the current project.
---  - `:Ccheck app/foo.ts app/bar.tsx` to restrict ESLint targets only.
function M.check_to_quickfix(opts)
  run_checks({ "typescript", "eslint", "knip" }, opts.fargs)
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

vim.api.nvim_create_user_command("Ceslint", M.eslint_to_quickfix, {
  desc = "Populate quickfix list from ESLint diagnostics",
  nargs = "*",
  complete = "file",
  force = true,
})

vim.api.nvim_create_user_command("Cknip", M.knip_to_quickfix, {
  desc = "Populate quickfix list from Knip diagnostics",
  force = true,
})

vim.api.nvim_create_user_command("Ccheck", M.check_to_quickfix, {
  desc = "Populate quickfix list from TypeScript, ESLint and Knip diagnostics",
  nargs = "*",
  complete = "file",
  force = true,
})

return M
