return {
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		keys = {
			{ "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
			{ "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add DB Connection" },
			{ "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find DB Buffer" },
		},
		init = function()
			-- Store DB UI data in ~/.local/share/db_ui (not in project dirs)
			vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

			-- Use nerd font icons
			vim.g.db_ui_use_nerd_fonts = 1

			-- Show results in a vertical split
			vim.g.db_ui_winwidth = 35

			-- Auto-execute on save for .dbout files
			vim.g.db_ui_execute_on_save = 0

			-- Load connections from JSON file (gitignored, contains your actual connection strings)
			-- Create ~/.config/db_connections.json with format:
			-- [
			--   { "name": "Work MSSQL", "url": "sqlserver://user:pass@192.168.1.100:1433/dbname" },
			--   { "name": "Local Postgres", "url": "postgres://user:pass@localhost:5432/dbname" }
			-- ]
			local conn_file = vim.fn.expand("~/.config/db_connections.json")
			if vim.fn.filereadable(conn_file) == 1 then
				vim.g.dbs = vim.fn.json_decode(vim.fn.readfile(conn_file))
			end
		end,
		config = function()
		-- Determine export directory: ~/share (VM) > ~/data (dell-pc) > ~/
		local function get_export_dir()
			local share = vim.fn.expand("~/share")
			local data = vim.fn.expand("~/data")
			if vim.fn.isdirectory(share) == 1 then
				return share
			elseif vim.fn.isdirectory(data) == 1 then
				return data
			else
				return vim.fn.expand("~")
			end
		end

		-- Export current dbout buffer content as CSV or TSV
		local function export_results(separator, ext)
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			if #lines == 0 then
				vim.notify("No results to export", vim.log.levels.WARN)
				return
			end

			-- Parse the dadbod table output (pipe-separated columns)
			local csv_lines = {}
			for _, line in ipairs(lines) do
				-- Skip separator lines (e.g. +----+----+)
				if not line:match("^[%+%-]+$") and line ~= "" then
					-- Remove leading/trailing pipes and split by pipe
					local clean = line:gsub("^%s*|%s*", ""):gsub("%s*|%s*$", "")
					local fields = {}
					for field in clean:gmatch("([^|]+)") do
						field = field:match("^%s*(.-)%s*$") -- trim whitespace
						-- Escape quotes and wrap in quotes for CSV
						if separator == "," then
							field = '"' .. field:gsub('"', '""') .. '"'
						end
						table.insert(fields, field)
					end
					table.insert(csv_lines, table.concat(fields, separator))
				end
			end

			if #csv_lines == 0 then
				vim.notify("No data rows found to export", vim.log.levels.WARN)
				return
			end

			local dir = get_export_dir()
			local timestamp = os.date("%Y%m%d_%H%M%S")
			local filename = dir .. "/query_" .. timestamp .. "." .. ext
			vim.fn.writefile(csv_lines, filename)
			vim.notify("Exported " .. #csv_lines .. " rows to " .. filename, vim.log.levels.INFO)
		end

		-- Keymaps for SQL buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function(args)
				local bufnr = args.buf
				-- Execute query (whole file or visual selection)
				vim.keymap.set("n", "<leader>de", "<Plug>(DBUI_ExecuteQuery)", { buffer = bufnr, desc = "Execute Query" })
				vim.keymap.set("v", "<leader>de", "<Plug>(DBUI_ExecuteQuery)", { buffer = bufnr, desc = "Execute Selected Query" })
			end,
		})

		-- Keymaps for result buffers (dbout)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "dbout" },
			callback = function(args)
				local bufnr = args.buf
				vim.keymap.set("n", "<leader>ds", function()
					export_results(",", "csv")
				end, { buffer = bufnr, desc = "Save results as CSV" })
				vim.keymap.set("n", "<leader>dt", function()
					export_results("\t", "tsv")
				end, { buffer = bufnr, desc = "Save results as TSV (paste to Excel)" })
			end,
		})

		-- Setup dadbod-completion with blink.cmp
		-- (autocomplete database tables/columns in SQL buffers)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				-- vim-dadbod-completion integrates automatically via omnifunc
				vim.bo.omnifunc = "vim_dadbod_completion#omni"
			end,
		})
	end,
	},
}
