return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	event = {
		"BufReadPre /mnt/data/Notes/*.md",
		"BufNewFile /mnt/data/Notes/*.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		workspaces = {
			{
				name = "Notes",
				path = "/mnt/data/Notes",
			},
		},
		-- Disable UI if not needed
		ui = {
			enable = false,
		},

		templates = {
			folder = "My Templates",
			date_format = "%Y-%m-%d-%a",
			time_format = "%H:%M",
		},

		completion = {
			nvim_cmp = false,
			blink = true,
		},

		picker = {
			name = "snacks.pick",
		},

		-- Use the title exactly as the note ID (file name).
		note_id_func = function(title)
			-- Just return the title as it is
			return title
		end,

		-- Use the title exactly as the file name.
		note_path_func = function(spec)
			-- Simply return the directory and the title (no modification).
			return tostring(spec.dir) .. "/" .. spec.title .. ".md"
		end,
	},
}
