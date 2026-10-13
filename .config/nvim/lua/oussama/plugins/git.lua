-- close the diffview/file-history in the current tab, or open it with `cmd`
local function toggle(cmd)
	return function()
		if require("diffview.lib").get_current_view() then
			vim.cmd("DiffviewClose")
		else
			vim.cmd(cmd)
		end
	end
end

return {
	{
		"dlyongemallo/diffview-plus.nvim",
		version = "*",
		config = function()
			require("diffview").setup()
		end,
		keys = {
			{ "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
			{ "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
			{ "<leader>gt", toggle("DiffviewOpen"), desc = "Toggle diffview" },
			{ "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle files" },
			{ "<leader>gl", toggle("DiffviewFileHistory"), desc = "Toggle repo commit history" },
			{ "<leader>gh", toggle("DiffviewFileHistory %"), desc = "Toggle current file history" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "]h", gs.next_hunk, "Next Hunk")
				map("n", "[h", gs.prev_hunk, "Prev Hunk")

				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk")
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk")

				map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

				map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

				map("n", "<leader>hb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

				map("n", "<leader>hd", gs.diffthis, "Diff this")
				map("n", "<leader>hD", function()
					gs.diffthis("~")
				end, "Diff this ~")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
			end,
		},
	},
}
