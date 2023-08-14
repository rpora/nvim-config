-- This file can be loaded by calling `lua requ:e('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	use('theprimeagen/harpoon')
	use('mbbill/undotree')
	use('tpope/vim-fugitive')
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		requires = {
		-- LSP Support
		{'neovim/nvim-lspconfig'},             -- Required
		{'williamboman/mason.nvim'},           -- Optional
		{'williamboman/mason-lspconfig.nvim'}, -- Optional

		-- Autocompletion
       		{'hrsh7th/nvim-cmp'},     -- Required
		{'hrsh7th/cmp-nvim-lsp'}, -- Required
		{'L3MON4D3/LuaSnip'},     -- Required
		}
	}

	use({'rose-pine/neovim',
    config = function()
        vim.cmd "colorscheme rose-pine"
    end,
    as = 'rose-pine' })
	use({'sainnhe/everforest',
    -- config = function()
    --    vim.cmd "colorscheme everforest"
    -- end,
    as = 'everforest'})
	use({'shaunsingh/nord.nvim', as = 'nord'})
    use({"EdenEast/nightfox.nvim", as = "nightfox"}) -- Packer
end)

