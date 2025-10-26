return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					angularls = { "prettier" },
					css = { "prettier" },
					scss = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					prisma = { "prettier" },
					svelte = { "prettier" },
					bash = { "shfmt" },
					vim = { "prettier" },
					dockerfile = { "prettier" },
					gitignore = { "prettier" },
					query = { "prettier" },
					vimdoc = { "prettier" },
					markdown = { "prettier" },
					tailwindcss = { "prettier" },
					graphql = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					python = { "black" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					go = { "gofumpt", "goimports-reviser", "golines" },
					nix = { "nixpkgs_fmt" },
				},
				formatters = {
					nixpkgs_fmt = {
						command = "nixpkgs-fmt",
					},
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},
}
