return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local util = require("lspconfig.util")
		local keymap = vim.keymap

		-- Custom on_attach function
		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr, silent = true }

			-- Buffer local mappings
			keymap.set(
				{ "n", "v" },
				"<leader>ca",
				vim.lsp.buf.code_action,
				{ desc = "See available code actions", buffer = bufnr }
			)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart rename", buffer = bufnr })
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", buffer = bufnr })
		end

		-- Configure diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Capabilities for autocompletion
		local capabilities = cmp_nvim_lsp.default_capabilities()

		local common_servers = {
			"ts_ls",
			"clangd",
			"angularls",
			"cssls",
			"html",
			"bashls",
			"jsonls",
			"tailwindcss",
		}

		for _, server in ipairs(common_servers) do
			lspconfig[server].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end

		-- LSP server configurations
		lspconfig.lua_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		lspconfig.gopls.setup({
			on_attach = on_attach,
			cmd = { "gopls" }, -- Command to start the language server
			filetypes = { "go", "gomod", "gowork", "gotmpl" }, -- File types to activate gopls
			root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						nilness = true,
						unusedwrite = true,
						useany = true,
					},
					staticcheck = true,
				},
			},
		})

		lspconfig.pyright.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
					},
				},
			},
		})
	end,
}
