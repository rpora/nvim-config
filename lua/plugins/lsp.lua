return {
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      require("outline").setup({})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      -- vim.lsp.set_log_level("debug")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          local builtin = require("telescope.builtin")

          map("gd", builtin.lsp_definitions, "To definition")
          map("gr", builtin.lsp_references, "Show references")
          map("gI", builtin.lsp_implementations, "Show implementations")

          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
          map("<leader>D", builtin.lsp_type_definitions, "Type definition")
          map("<leader>ds", builtin.lsp_document_symbols, "Document symbols")
          map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("K", vim.lsp.buf.hover, "Quick definition")

          -- highlight term after timeout
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local servers = {
        ts_ls = {},
        pyright = {},
        html = {
          filetypes = { "html", "htmldjango" },
        },
        yamlls = {
          settings = {
            yaml = {
              validate = true,
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = {
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.yml",
                ["https://raw.githubusercontent.com/docker/compose/master/compose/config/compose_spec.json"] = "docker-compose*.{yml,yaml}",
                -- ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.4/all.json"] = "*.{yml,yaml}",
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        cssls = {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Ensure the servers are installed
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
