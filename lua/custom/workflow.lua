local M = {}

function M.diff_to_quickfix()
  vim.cmd([[cexpr system('git jump --stdout diff')]])

  if vim.fn.getqflist({ size = 0 }).size == 0 then
    vim.notify("Quickfix vide (diff vide ou commande indisponible).", vim.log.levels.INFO)
    return
  end

  vim.cmd("copen")
end

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

vim.api.nvim_create_user_command("Cdiff", M.diff_to_quickfix, {
  desc = "Populate quickfix list from full git diff",
})

vim.api.nvim_create_user_command("Cdone", M.quickfix_done, {
  desc = "Remove current quickfix entry",
})

return M
