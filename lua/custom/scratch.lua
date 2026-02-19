local function open_scratch(ft)
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.bo.buflisted = true
  vim.bo.filetype = ft
  vim.bo.modifiable = true
  vim.bo.undofile = false
  vim.cmd("file [scratch]." .. ft)
end

vim.api.nvim_create_user_command("Scratch", function(opts)
  if not opts.args or opts.args == "" then
    vim.notify("Usage: :Scratch <filetype>", vim.log.levels.ERROR)
    return
  end
  open_scratch(opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "json", "md", "ts", "lua", "sql", "txt", "sh" }
  end,
})
