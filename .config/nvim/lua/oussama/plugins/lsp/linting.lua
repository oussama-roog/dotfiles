return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			angularls = { "eslint_d" },
			python = { "ruff" },
			json = { "jsonlint" },
			lua = { "luacheck" },
			html = { "htmlhint" },
			css = { "stylelint" },
			scss = { "stylelint" },
			svelte = { "eslint_d" },
			graphql = { "eslint_d" },
			yaml = { "yamllint" },
			go = { "golangci-lint" },
			bash = { "shellcheck" },
			markdown = { "markdownlint" },
			nix = { "statix" },
		}

		lint.linters["golangci-lint"] = {
			cmd = "golangci-lint",
			args = { "run", "--out-format", "json" },
			stdin = false,
			stream = "stdout",
			ignore_exitcode = true,
			parser = function(output, bufnr)
				local ok, decoded = pcall(vim.json.decode, output)
				if not ok then
					return {}
				end
				local diagnostics = {}
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				for _, issue in ipairs(decoded.Issues or {}) do
					if issue.Pos.Filename == bufname then
						table.insert(diagnostics, {
							lnum = issue.Pos.Line - 1,
							col = issue.Pos.Column - 1,
							message = issue.Text,
							severity = vim.diagnostic.severity.WARN,
							source = "golangci-lint",
						})
					end
				end
				return diagnostics
			end,
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })

		vim.keymap.set("n", "<leader>lh", function()
			local bufnr = vim.api.nvim_get_current_buf()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, { desc = "Toggle Inlay Hints" })
	end,
}
