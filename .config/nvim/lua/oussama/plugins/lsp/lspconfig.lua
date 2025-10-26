return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local blink_cmp = require("blink.cmp")

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
			ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
			},
			clangd = {
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			},
			angularls = {
				cmd = { "ngserver", "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
				filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
			},
			cssls = {
				cmd = { "vscode-css-language-server", "--stdio" },
				filetypes = { "css", "scss", "less" },
			},
			html = {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
			},
			bashls = {
				cmd = { "bash-language-server", "start" },
				filetypes = { "sh", "bash" },
			},
			jsonls = {
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
			},
			nil_ls = {
				cmd = { "nil" },
				filetypes = { "nix" },
			},
			tailwindcss = {
				cmd = { "tailwindcss-language-server", "--stdio" },
				filetypes = {
					"aspnetcorerazor",
					"astro",
					"astro-markdown",
					"blade",
					"clojure",
					"django-html",
					"htmldjango",
					"edge",
					"eelixir",
					"elixir",
					"ejs",
					"erb",
					"eruby",
					"gohtml",
					"gohtmltmpl",
					"haml",
					"handlebars",
					"hbs",
					"html",
					"html-eex",
					"heex",
					"jade",
					"leaf",
					"liquid",
					"markdown",
					"mdx",
					"mustache",
					"njk",
					"nunjucks",
					"php",
					"razor",
					"slim",
					"twig",
					"css",
					"less",
					"postcss",
					"sass",
					"scss",
					"stylus",
					"sugarss",
					"javascript",
					"javascriptreact",
					"reason",
					"rescript",
					"typescript",
					"typescriptreact",
					"vue",
					"svelte",
				},
			},
			lua_ls = {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
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
							enable = true,
						},
					},
				},
			},
			gopls = {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = function(fname)
					local util = require("lspconfig.util")
					return util.root_pattern("go.work", "go.mod", ".git")(fname)
				end,
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
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
							-- extraPaths = {
							-- 	"/home/oussama/dotfiles/.config/fabric/venv/lib/python3.11/site-packages",
							-- },
						},
					},
				},
			},
		}

		for server, config in pairs(servers) do
			vim.lsp.config(
				server,
				vim.tbl_deep_extend("force", {
					capabilities = capabilities,
					on_attach = on_attach,
				}, config)
			)
		end

		-- Auto-start LSP servers based on filetype
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = vim.bo[args.buf].filetype

				-- Start appropriate LSP servers for this filetype
				for server_name, config in pairs(servers) do
					if config.filetypes and vim.tbl_contains(config.filetypes, ft) then
						-- Get the full config including capabilities and on_attach
						local full_config = vim.tbl_deep_extend("force", {
							capabilities = capabilities,
							on_attach = on_attach,
						}, config)

						vim.lsp.start(full_config, { bufnr = args.buf })
					end
				end
			end,
		})

		vim.diagnostic.config({
			-- virtual_lines = true,
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function(args)
				vim.diagnostic.enable(false, { bufnr = args.buf })
			end,
		})
	end,
}
