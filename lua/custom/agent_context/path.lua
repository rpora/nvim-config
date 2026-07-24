local M = {}

local function normalize_bufnr(bufnr)
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end

  return bufnr
end

---Find the Git root containing a file path.
---@param file_path string
---@return string|nil root
---@return string|nil error
function M.get_git_root_for_path(file_path)
  if type(file_path) ~= "string" or file_path == "" then
    return nil, "Aucun chemin de fichier valide n'a été fourni."
  end

  file_path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":p"))
  local git_entry = vim.fs.find(".git", {
    path = vim.fs.dirname(file_path),
    upward = true,
  })[1]

  if not git_entry then
    return nil, ("Le fichier %s n'appartient à aucun dépôt Git."):format(file_path)
  end

  return vim.fs.dirname(git_entry), nil
end

---Return a file path relative to its Git root.
---@param file_path string
---@return string|nil path
---@return string|nil error
function M.get_relative_path_for_path(file_path)
  local absolute_path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":p"))
  local root, root_error = M.get_git_root_for_path(absolute_path)
  if not root then
    return nil, root_error
  end

  local relative_path = vim.fs.relpath(root, absolute_path)
  if not relative_path then
    return nil, ("Impossible de rendre %s relatif à %s."):format(absolute_path, root)
  end

  return relative_path, nil
end

---Return the absolute path associated with a buffer.
---@param bufnr? integer
---@return string|nil path
---@return string|nil error
function M.get_buffer_path(bufnr)
  bufnr = normalize_bufnr(bufnr)

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil, "Le buffer demandé n'existe pas."
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return nil, "Le buffer courant n'est associé à aucun fichier."
  end

  return vim.fs.normalize(path), nil
end

---Find the Git root containing a buffer's file.
---@param bufnr? integer
---@return string|nil root
---@return string|nil error
function M.get_git_root(bufnr)
  local path, path_error = M.get_buffer_path(bufnr)
  if not path then
    return nil, path_error
  end

  return M.get_git_root_for_path(path)
end

---Return a buffer path relative to its Git root.
---@param bufnr? integer
---@return string|nil path
---@return string|nil error
function M.get_relative_path(bufnr)
  local path, path_error = M.get_buffer_path(bufnr)
  if not path then
    return nil, path_error
  end

  return M.get_relative_path_for_path(path)
end

return M
