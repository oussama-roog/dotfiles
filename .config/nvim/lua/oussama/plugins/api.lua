return {
	"mistweaverco/kulala.nvim",
	keys = {
		{ "<leader>Rs", desc = "Send request" },
		{ "<leader>Ra", desc = "Send all requests" },
		{ "<leader>Rb", desc = "Open scratchpad" },
	},
	ft = { "http", "rest" },
	opts = {
		global_keymaps = true,
		global_keymaps_prefix = "<leader>R",
		kulala_keymaps_prefix = "",

		ui = {
			-- display mode: possible values: "split", "float"
			display_mode = "float",
			-- default view: "body" or "headers" or "headers_body" or "verbose" or fun(response: Response)
			default_view = "headers_body",
		},
	},
}
