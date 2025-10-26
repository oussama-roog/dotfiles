return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	ft = "markdown",
	event = {
		"BufReadPre ~/data/Notes/*.md",
		"BufNewFile ~/data/Notes/*.md",
	},
	cond = function()
		return vim.fn.isdirectory(vim.fn.expand("~/data/Notes")) == 1
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "Notes",
				path = "~/data/Notes",
			},
		},
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

		note_id_func = function(title)
			return title
		end,

		note_path_func = function(spec)
			return tostring(spec.dir) .. "/" .. spec.title .. ".md"
		end,
	},
}
