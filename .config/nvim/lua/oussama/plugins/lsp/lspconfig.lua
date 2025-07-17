return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local blink_cmp = require("blink.cmp")
		local util = require("lspconfig.util")

		local capabilities = blink_cmp.get_lsp_capabilities()

		local on_attach = function(client, bufnr)
			local keymap = vim.keymap.set
			local opts = { buffer = bufnr, silent = true }

			keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", unpack(opts) })
			keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol", unpack(opts) })
			keymap("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", unpack(opts) })
			keymap("n", "<leader>xx", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
		end

		local servers = {
			ts_ls = {},
			clangd = {},
			angularls = {},
			cssls = {},
			html = {},
			bashls = {},
			jsonls = {},
			tailwindcss = {},
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
						hint = {
							enable = true, -- This is required!
						},
					},
				},
			},
			gopls = {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = util.root_pattern("go.work", "go.mod", ".git"),
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
			},
			pyright = {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			},
		}

		for server, config in pairs(servers) do
			lspconfig[server].setup(vim.tbl_deep_extend("force", {
				capabilities = capabilities,
				on_attach = on_attach,
			}, config))
		end

		vim.diagnostic.config({
			virtual_lines = true,
			-- virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(args)
				vim.diagnostic.disable(args.buf)
			end,
		})
	end,
}
