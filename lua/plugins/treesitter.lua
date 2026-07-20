local parsers = {
  "bash",
  "c",
  "cpp",
  "go",
  "html",
  "http",
  "javascript",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(parsers):wait(300000)
    end,
    config = function()
      local group = vim.api.nvim_create_augroup("treesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
