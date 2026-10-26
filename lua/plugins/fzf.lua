return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {

    grep = {
      rg_opts = table.concat({
        "--column",
        "--line-number",
        "--no-heading",
        "--color=always",
        "--smart-case",
        "--max-columns=4096",
        "--hidden",
        "--glob=!.git",
        "-e", -- must stay last: the query follows it
      }, " "),
    },
  },
  keys = {
    { "<leader>sf", "<cmd>FzfLua git_files<cr>", desc = "FZF Git Files" },
    {
      "<leader>sa",
      function()
        require("fzf-lua").files({
          hidden = true,
          no_ignore = true,
          file_ignore_patterns = {
            "node_modules",
            "%.git",
            "%.turbo",
            "dist",
          },
        })
      end,
      desc = "FZF All Files",
    },
    { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "FZF Live Grep" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "FZF Grep word under cursor" },
    { "<leader><space>", "<cmd>FzfLua buffers<cr>", desc = "FZF Buffers" },
    -- Diagnostics
    { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "FZF Diagnostics Document" },
    { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "FZF Diagnostics Workspace" },
    -- Symbols
    { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "FZF Document Symbols" },
    { "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "FZF Workspace Symbols" },
    { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "FZF Resume" },
    {
      "<leader>sn",
      function()
        require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "FZF Config",
    },
  },
}
