return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- mason_lspconfig.setup({
		-- 	automatic_installation = false,
		-- })

		mason_tool_installer.setup({
			ensure_installed = {
				-- LSP
				"ts_ls",
				"gopls",
				"html",
				"cssls",
				"tailwindcss",
				"angularls",
				"lua_ls",
				"pyright",
				"clangd",
				"bashls",
				"jsonls",
				"qmlls",

				-- Other stuff
				"prettier",
				"stylua",
				"eslint_d",
				"ruff",
				"black",
				"clang-format",
				"golangci-lint",
				"gofumpt",
				"goimports-reviser",
				"golines",
				"shfmt",
				"jsonlint",
				"htmlhint",
				"stylelint",
				"yamllint",
				"markdownlint",
				"luacheck",
			},
		})
	end,
}
