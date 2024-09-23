return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = false, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = true, -- enables an input dialog for inc-rename.nvim
				},
				cmdline = {
					view = "cmdline",
				},
				routes = {
					{
						view = "cmdline",
						filter = { event = "msg_showmode" },
					},
				},
			})
			vim.keymap.set("n", "<leader>nu", ":NoiceDismiss<CR>", { desc = "Dismiss Noice" })
		end,
	},
}
