return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>sf",
      function()
        require("fzf-lua").git_files()
      end,
      desc = "FZF Git Files",
    },
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
    {
      "<leader>sg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "FZF Live Grep",
    },
    {
      "<leader>sw",
      function()
        require("fzf-lua").grep_cword()
      end,
      desc = "FZF Grep word under cursor",
    },
    {
      "<leader><space>",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "FZF Buffers",
    },
    {
      "<leader>sd",
      function()
        require("fzf-lua").diagnostics_document()
      end,
      desc = "FZF Diagnostics Document",
    },
    {
      "<leader>sD",
      function()
        require("fzf-lua").diagnostics_workspace()
      end,
      desc = "FZF Diagnostics Workspace",
    },
    {
      "<leader>ss",
      function()
        require("fzf-lua").lsp_document_symbols()
      end,
      desc = "FZF Document Symbols",
    },
    {
      "<leader>sS",
      function()
        require("fzf-lua").lsp_workspace_symbols()
      end,
      desc = "FZF Workspace Symbols",
    },
    {
      "<leader>sr",
      function()
        require("fzf-lua").resume()
      end,
      desc = "FZF Resume",
    },
    {
      "<leader>sn",
      function()
        require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "FZF Config",
    },

    -- LSP
    {
      "<leader>gr",
      function()
        require("fzf-lua").lsp_references()
      end,
      desc = "FZF LSP References",
    },
    {
      "<leader>gw",
      function()
        require("fzf-lua").lsp_workspace_symbols()
      end,
      desc = "FZF LSP References",
    },
  },
  opts = {},
}
