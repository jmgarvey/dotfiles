-- Pull in the wezterm API
local wezterm = require("wezterm")

local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"

-- This is where you actually apply your config choices

-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font = wezterm.font("MonaspiceNe Nerd Font Mono")
-- config.font = wezterm.font("Inconsolata LGC Nerd Font Mono")
-- config.font = wezterm.font("FiraCode Nerd Font Mono")
-- config.font = wezterm.font("0xProto Nerd Font Mono")
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
config.harfbuzz_features = { "ss01=1", "ss02=1" }

config.font_size = 15

config.enable_tab_bar = true
config.use_fancy_tab_bar = false

config.window_background_opacity = 0.9

-- Pick a colour scheme. WezTerm ships with more than 1,000!
-- Find them here: https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'Banana Blueberry'

config.enable_scroll_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 5000

-- Hide the scrollbar when there is no scrollback or alternate screen is active
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local dimensions = pane:get_dimensions()

	overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows
		and not pane:is_alt_screen_active()

	window:set_config_overrides(overrides)
end)

config.keys = {
	{
		key = "t",
		mods = "ALT|SHIFT",
		action = act.ShowTabNavigator,
	},
	{
		key = "R",
		mods = "ALT|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- other keys
}
for i = 1, 9 do
	-- CTRL+ALT + number to move to that position
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

-- and finally, return the configuration to wezterm
return config
