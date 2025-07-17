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
			c = { "clang-tidy" },
			cpp = { "clang-tidy" },
			go = { "golangci-lint" },
			bash = { "shellcheck" },
			markdown = { "markdownlint" },
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
