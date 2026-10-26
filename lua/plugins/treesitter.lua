local parsers = {
  "bash",
  "css",
  "html",
  "http",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "sql",
  "tsx",
  "typescript",
  "yaml",
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
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      multiline_threshold = 1,
      max_lines = 5,
      mode = "topline",
    },
  },
}
