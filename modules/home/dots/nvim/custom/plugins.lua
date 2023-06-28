local plugins = {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"c",
				"cpp",
				"markdown",
				"nix",
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"jose-elias-alvarez/null-ls.nvim",
			config = function()
				require("custom.configs.null-ls")
			end,
		},

		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},

	{
		"lervag/vimtex",
		ft = "tex",
		config = function()
			require("custom.configs.vimtex")
		end,
	},

	{
		"quarto-dev/quarto-nvim",
		lazy = false,
		dependencies = {
			"jmbuhr/otter.nvim",
		},
		config = function()
			require("quarto").setup({})
		end,
	},

	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = {
			"cd app && npm install",
		},
		config = function() end,
	},

	{
		"andrewferrier/wrapping.nvim",
		event = "VeryLazy",
		config = function()
			require("wrapping").setup()
		end,
	},
}
return plugins