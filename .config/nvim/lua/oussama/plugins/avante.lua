return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false, -- set this if you want to always pull the latest change
	opts = {
		-- add any opts here
		-- provider = "copilot",
		-- copilot = {
		-- 	endpoint = "https://api.githubcopilot.com",
		-- 	model = "gpt-4o-2024-08-06",
		-- 	proxy = nil, -- [protocol://]host[:port] Use this proxy
		-- 	allow_insecure = false, -- Allow insecure server connections
		-- 	timeout = 30000, -- Timeout in milliseconds
		-- 	temperature = 0,
		-- 	max_tokens = 4096,
		-- },
		provider = "gemini",
		providers = {
			gemini = {
				endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
				model = "gemini-2.5-flash",
				timeout = 30000, -- Timeout in milliseconds
				context_window = 1048576,
				use_ReAct_prompt = true,
				extra_request_body = {
					generationConfig = {
						temperature = 0.75,
					},
				},
			},
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		-- support for image pasting
		-- 			"HakonHarnes/img-clip.nvim",
		-- 			event = "VeryLazy",
		-- 			opts = {
		-- 				-- recommended settings
		-- 				default = {
		-- 					embed_image_as_base64 = false,
		-- 					prompt_for_file_name = false,
		-- 					drag_and_drop = {
		-- 						insert_mode = true,
		-- 					},
		-- 					-- required for Windows users
		-- 					use_absolute_path = true,
		-- 				},
		-- 			},
		-- 		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
