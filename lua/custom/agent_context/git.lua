local clipboard = require("custom.agent_context.clipboard")
local path = require("custom.agent_context.path")

local M = {}

local function strip_trailing_newlines(text)
  return (text or ""):gsub("[\r\n]+$", "")
end

---@param command string[]
---@param cwd string
---@param callback fun(result: vim.SystemCompleted)
local function run_git(command, cwd, callback)
  vim.system(command, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

---@param title string
---@param diff string
---@return string
local function format_diff(title, diff)
  return table.concat({
    "## " .. title,
    "",
    "```diff",
    strip_trailing_newlines(diff),
    "```",
  }, "\n")
end

---@param result vim.SystemCompleted
---@param label string
---@return string|nil error
local function git_error(result, label)
  if result.code == 0 then
    return nil
  end

  local detail = strip_trailing_newlines(result.stderr)
  if detail == "" then
    detail = ("code %d"):format(result.code)
  end
  return ("%s : %s"):format(label, detail)
end

---@param sections string[]
---@param label string
---@return boolean
local function copy_sections(sections, label)
  local content = table.concat(sections, "\n\n")
  local copied, copy_error = clipboard.copy(content)
  if not copied then
    clipboard.notify_error(copy_error)
    return false
  end

  clipboard.notify_copy(label, content)
  return true
end

---Copy unstaged and staged changes for a buffer's file.
---@param bufnr? integer
function M.copy_file_diff(bufnr)
  bufnr = bufnr or 0
  local absolute_path, path_error = path.get_buffer_path(bufnr)
  if not absolute_path then
    clipboard.notify_error(path_error)
    return
  end

  local root, root_error = path.get_git_root(bufnr)
  if not root then
    clipboard.notify_error(root_error)
    return
  end

  local relative_path, relative_error = path.get_relative_path(bufnr)
  if not relative_path then
    clipboard.notify_error(relative_error)
    return
  end

  local results = {}
  local pending = 2

  local function finish()
    pending = pending - 1
    if pending > 0 then
      return
    end

    local unstaged_error = git_error(results.unstaged, "Impossible de lire le diff unstaged")
    local staged_error = git_error(results.staged, "Impossible de lire le diff staged")
    if unstaged_error or staged_error then
      clipboard.notify_error(unstaged_error or staged_error)
      return
    end

    local sections = {}
    local unstaged = strip_trailing_newlines(results.unstaged.stdout)
    local staged = strip_trailing_newlines(results.staged.stdout)
    if unstaged ~= "" then
      table.insert(sections, format_diff("Diff unstaged — " .. relative_path, unstaged))
    end
    if staged ~= "" then
      table.insert(sections, format_diff("Diff staged — " .. relative_path, staged))
    end

    if #sections > 0 then
      copy_sections(sections, "diff de " .. relative_path)
      return
    end

    run_git({ "git", "ls-files", "--error-unmatch", "--", relative_path }, root, function(tracked)
      if tracked.code == 0 or not vim.uv.fs_stat(absolute_path) then
        vim.notify("Aucune modification Git pour " .. relative_path .. ".", vim.log.levels.INFO)
        return
      end

      run_git({ "git", "diff", "--no-index", "--", "/dev/null", relative_path }, root, function(untracked)
        if untracked.code ~= 0 and untracked.code ~= 1 then
          clipboard.notify_error(git_error(untracked, "Impossible de lire le fichier non suivi"))
          return
        end

        local diff = strip_trailing_newlines(untracked.stdout)
        if diff == "" then
          local content = ("## Fichier non suivi — %s\n\n_Fichier vide._"):format(relative_path)
          copy_sections({ content }, "fichier non suivi " .. relative_path)
          return
        end

        copy_sections(
          { format_diff("Fichier non suivi — " .. relative_path, diff) },
          "fichier non suivi " .. relative_path
        )
      end)
    end)
  end

  run_git(
    { "git", "diff", "--no-ext-diff", "--relative", "--", relative_path },
    root,
    function(result)
      results.unstaged = result
      finish()
    end
  )
  run_git(
    { "git", "diff", "--cached", "--no-ext-diff", "--relative", "--", relative_path },
    root,
    function(result)
      results.staged = result
      finish()
    end
  )
end

---@param hunk table
---@param cursor_line integer
---@return boolean
local function contains_line(hunk, cursor_line)
  local start_line = hunk.added.start
  local end_line = hunk.added.count > 0
      and start_line + hunk.added.count - 1
    or start_line
  return cursor_line >= start_line and cursor_line <= end_line
end

---@class AgentContextGitHunk
---@field head string
---@field lines string[]
---@field new_start integer
---@field new_count integer

---Parse the unified hunks from a `git diff` output.
---@param diff string
---@return AgentContextGitHunk[]
local function parse_git_hunks(diff)
  local hunks = {}
  local current_hunk

  for _, line in ipairs(vim.split(strip_trailing_newlines(diff), "\n", { plain = true })) do
    local old_start, _, new_start, new_count =
      line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")

    if old_start then
      current_hunk = {
        head = line,
        lines = {},
        new_start = tonumber(new_start),
        new_count = new_count == "" and 1 or tonumber(new_count),
      }
      table.insert(hunks, current_hunk)
    elseif current_hunk then
      table.insert(current_hunk.lines, line)
    end
  end

  return hunks
end

---@param hunk AgentContextGitHunk
---@param cursor_line integer
---@return boolean
local function git_hunk_contains_line(hunk, cursor_line)
  local start_line = math.max(1, hunk.new_start)
  local end_line = hunk.new_count > 0
      and start_line + hunk.new_count - 1
    or start_line
  return cursor_line >= start_line and cursor_line <= end_line
end

---Copy the complete Git unified hunk under the cursor.
---@param bufnr? integer
function M.copy_current_hunk(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local relative_path, relative_error = path.get_relative_path(bufnr)
  if not relative_path then
    clipboard.notify_error(relative_error)
    return
  end

  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    clipboard.notify_error("Gitsigns n'est pas disponible.")
    return
  end

  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks then
    clipboard.notify_warn("Gitsigns n'est pas attaché au buffer courant.")
    return
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local current_hunk
  for _, hunk in ipairs(hunks) do
    if contains_line(hunk, cursor_line) then
      current_hunk = hunk
      break
    end
  end

  if not current_hunk then
    clipboard.notify_warn("Aucun hunk Git sous le curseur.")
    return
  end

  if vim.bo[bufnr].modified then
    clipboard.notify_warn("Enregistre le buffer avant de copier son hunk Git.")
    return
  end

  local root, root_error = path.get_git_root(bufnr)
  if not root then
    clipboard.notify_error(root_error)
    return
  end

  run_git(
    {
      "git",
      "diff",
      "--no-ext-diff",
      "--diff-algorithm=patience",
      "--unified=0",
      "--relative",
      "--",
      relative_path,
    },
    root,
    function(result)
      local result_error = git_error(result, "Impossible de lire le hunk Git")
      if result_error then
        clipboard.notify_error(result_error)
        return
      end

      local git_hunk
      for _, hunk in ipairs(parse_git_hunks(result.stdout or "")) do
        if git_hunk_contains_line(hunk, cursor_line) then
          git_hunk = hunk
          break
        end
      end

      if not git_hunk then
        clipboard.notify_warn("Impossible de retrouver le hunk unifié sous le curseur.")
        return
      end

      local start_line = math.max(1, git_hunk.new_start)
      local end_line = git_hunk.new_count > 0
          and start_line + git_hunk.new_count - 1
        or start_line
      local patch_lines = { git_hunk.head }
      vim.list_extend(patch_lines, git_hunk.lines)
      local content = format_diff(
        ("Hunk — %s:{%d-%d}"):format(relative_path, start_line, end_line),
        table.concat(patch_lines, "\n")
      )

      copy_sections({ content }, "hunk de " .. relative_path)
    end
  )
end

return M
