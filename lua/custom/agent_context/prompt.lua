local M = {}

local prompt_name = "codex://prompt"
local prompt_bufnr

local function reuse_loaded_prompt(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_buf_get_name(bufnr) ~= prompt_name then
    return nil
  end

  if vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end

  -- A nofile buffer loses its content when unloaded. Remove the stale buffer
  -- so the next opening creates a fresh empty prompt.
  vim.api.nvim_buf_delete(bufnr, { force = true })
  return nil
end

local function find_prompt_buffer()
  if prompt_bufnr then
    local bufnr = reuse_loaded_prompt(prompt_bufnr)
    if bufnr then
      return bufnr
    end

    prompt_bufnr = nil
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local reusable_bufnr = reuse_loaded_prompt(bufnr)
    if reusable_bufnr then
      prompt_bufnr = reusable_bufnr
      return reusable_bufnr
    end
  end

  return nil
end

local function create_prompt_buffer()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, prompt_name)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undofile = false
  vim.bo[bufnr].filetype = "markdown"

  prompt_bufnr = bufnr
  return bufnr
end

---Return the session prompt buffer, creating it when needed.
---@return integer bufnr
function M.get_or_create_buffer()
  return find_prompt_buffer() or create_prompt_buffer()
end

---Return the existing session prompt buffer without creating it.
---@return integer|nil bufnr
function M.get_buffer()
  return find_prompt_buffer()
end

---Empty the existing session prompt.
---@return boolean success
---@return string|nil error
function M.clear()
  local bufnr = M.get_buffer()
  if not bufnr then
    return false, "Aucun prompt Codex n'existe dans cette session."
  end

  if not vim.bo[bufnr].modifiable then
    return false, "Le prompt Codex n'est pas modifiable."
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  return true, nil
end

---Open the session prompt buffer in a bottom horizontal split.
---@return integer bufnr
function M.open()
  local bufnr = M.get_or_create_buffer()
  local window = vim.fn.bufwinid(bufnr)

  if window ~= -1 then
    vim.api.nvim_set_current_win(window)
  else
    vim.cmd("botright split")
    vim.api.nvim_win_set_buf(0, bufnr)
  end

  return bufnr
end

return M
