local M = {}

function M.setup()
    local ensure_packer = function()
        local fn = vim.fn
        local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
                install_path })
            vim.cmd [[packadd packer.nvim]]
            return true
        end
        vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
        return false
    end

    local packer_bootstrap = ensure_packer()
    local packer = require('packer')

    packer.init({
        profile = {
            enable = true,
            threshold = 0,
        },
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'rounded' })
            end
        }
    })


    packer.startup(function(use)
        -- Sys dep, loaded when required
        use { "nvim-lua/plenary.nvim", module = "plenary" }

        -- Packer
        use 'wbthomason/packer.nvim'

        -- Telescope
        use {
            'nvim-telescope/telescope.nvim', tag = '0.1.2',
            event = "VimEnter",
            config = function()
                require("config.telescope").setup()
            end
        }
        use { 'nvim-telescope/telescope-fzf-native.nvim', run =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            event = "BufRead",
            opt = true,
            run = ':TSUpdate',
            config = function()
                require("config.treesitter").setup()
            end,
        }

        -- LSP
        use {
            'VonHeikemen/lsp-zero.nvim',
            branch = 'v2.x',
            requires = {
                { 'neovim/nvim-lspconfig' },
                { 'williamboman/mason.nvim' },
                { 'williamboman/mason-lspconfig.nvim' },

                { 'hrsh7th/nvim-cmp' },
                { 'hrsh7th/cmp-buffer' },
                { 'hrsh7th/cmp-path' },
                { 'hrsh7th/cmp-cmdline' },
                { 'hrsh7th/cmp-nvim-lsp' },

                { 'L3MON4D3/LuaSnip' },
                { 'saadparwaiz1/cmp_luasnip' },
            },
            config = function()
                require("config.lsp").setup()
            end
        }

        -- git
        use { "tpope/vim-fugitive" }

        -- Status line
        use {
            'nvim-lualine/lualine.nvim',
            config = function()
                require("config.lualine").setup()
            end,
            requires = { "nvim-tree/nvim-web-devicons" },
        }

        -- comments
        use {
            "numToStr/Comment.nvim",
            config = function()
                require("Comment").setup {}
            end
        }

        -- Markdown
        use {
            "iamcco/markdown-preview.nvim",
            run = function()
                vim.fn["mkdp#util#install"]()
            end,
            ft = "markdown",
            cmd = { "MarkdownPreview" },
        }

        -- Easy hopping
        use {
            "phaazon/hop.nvim",
            config = function()
                require("hop").setup {
                    uppercase_labels = true,
                }
            end,
        }

        use('mbbill/undotree')
        -- use "github/copilot.vim"

        use {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({
                    suggestion = {
                        enabled = false,
                        auto_trigger = false,
                        debounce = 75,
                        keymap = {
                            accept = "<M-i>",
                            accept_word = false,
                            accept_line = false,
                            next = "<M-e>",
                            prev = "<M-n>",
                            dismiss = "<M-o>",
                        },
                    },
                })
            end,
        }

        use "folke/zen-mode.nvim"
        use {
            "rest-nvim/rest.nvim",
            requires = { "nvim-lua/plenary.nvim" },
            config = function()
                require("rest-nvim").setup({})
                vim.keymap.set('n', '<leader>req', '<Plug>RestNvim', { noremap = false, silent = true })
            end
        }

        -- theme
        use({
            'rose-pine/neovim',
            config = function()
                vim.cmd "colorscheme rose-pine"
            end
        })

        require("cheatsh")

        if packer_bootstrap then
            print "Restart Neovim after installation!"
            require("packer").sync()
        end
    end)
end

return M
