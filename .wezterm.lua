local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "GitHub Dark"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14

config.enable_tab_bar = false
-- config.window_background_opacity = 0.75

config.keys = {
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(wezterm.action.SendString("~/.tmux-sessionizer\n"), pane)
		end),
	},
}

return config
