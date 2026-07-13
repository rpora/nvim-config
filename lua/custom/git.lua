local M = {}

vim.api.nvim_create_user_command("GitHunks", function()
  require("gitsigns").setqflist("all")
end, { desc = "Liste globale des changements Git" })

function M.nav_hunk(direction)
  if vim.wo.diff then
    local native_motion = direction == "next" and "]c" or "[c"
    vim.cmd("normal! " .. vim.v.count1 .. native_motion)
    return
  end

  require("gitsigns").nav_hunk(direction, { target = "all" })
end

return M
