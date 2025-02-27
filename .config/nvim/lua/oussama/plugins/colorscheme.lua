return {
	{
		"projekt0n/github-nvim-theme",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins

		config = function()
			require("github-theme").setup({
				options = {
					transparent = true,
				},
			})

			-- vim.cmd("colorscheme github_dark_dimmed")
		end,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- latte, frappe, macchiato, mocha
				transparent_background = true,
			})
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			require("tokyonight").setup({
				style = "night", -- The theme comes in three styles, `storm`, `moon`, and `night`.
				transparent = true, -- Enable this to disable setting the background color
			})
		end,
	},
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		opts = {},
		config = function()
			require("onedark").setup({
				style = "dark",
				transparent = true, -- Enable this to disable setting the background color
			})
		end,
	},
	{
		"vague2k/vague.nvim",
		config = function()
			-- NOTE: you do not need to call setup if you don't want to.
			require("vague").setup({
				-- optional configuration here
			})

			vim.cmd("colorscheme vague")
		end,
	},

	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd("colorscheme moonfly")
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			-- vim.cmd("colorscheme rose-pine-main")
		end,
	},
}
