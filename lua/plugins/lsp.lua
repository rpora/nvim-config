return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
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
              diagnostics = {
                globals = { "vim" },
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

      -- blink.cmp adds its completion capabilities to every server by itself
      for server_name, server_config in pairs(servers) do
        vim.lsp.config(server_name, server_config)
      end

      -- Install the servers, then enable them
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers) })
    end,
  },
}
