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

local function segments_for_right_status(window)
	return {
		window:active_workspace(),
		wezterm.strftime("%a %b %-d %H:%M"),
		wezterm.hostname(),
	}
end

-- wezterm.on("update-status", function(window, _)
-- 	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
-- 	local segments = segments_for_right_status(window)
--
-- 	local color_scheme = window:effective_config().resolved_palette
-- 	-- Note the use of wezterm.color.parse here, this returns
-- 	-- a Color object, which comes with functionality for lightening
-- 	-- or darkening the colour (amongst other things).
-- 	local bg = wezterm.color.parse(color_scheme.background)
-- 	local fg = color_scheme.foreground
--
-- 	-- Each powerline segment is going to be coloured progressively
-- 	-- darker/lighter depending on whether we're on a dark/light colour
-- 	-- scheme. Let's establish the "from" and "to" bounds of our gradient.
-- 	local gradient_to, gradient_from = bg
-- 	if appearance.is_dark() then
-- 		gradient_from = gradient_to:lighten(0.2)
-- 	else
-- 		gradient_from = gradient_to:darken(0.2)
-- 	end
--
-- 	-- Yes, WezTerm supports creating gradients, because why not?! Although
-- 	-- they'd usually be used for setting high fidelity gradients on your terminal's
-- 	-- background, we'll use them here to give us a sample of the powerline segment
-- 	-- colours we need.
-- 	local gradient = wezterm.color.gradient(
-- 		{
-- 			orientation = "Horizontal",
-- 			colors = { gradient_from, gradient_to },
-- 		},
-- 		#segments -- only gives us as many colours as we have segments.
-- 	)
--
-- 	-- We'll build up the elements to send to wezterm.format in this table.
-- 	local elements = {}
--
-- 	for i, seg in ipairs(segments) do
-- 		local is_first = i == 1
--
-- 		if is_first then
-- 			table.insert(elements, { Background = { Color = "none" } })
-- 		end
-- 		table.insert(elements, { Foreground = { Color = gradient[i] } })
-- 		table.insert(elements, { Text = SOLID_LEFT_ARROW })
--
-- 		table.insert(elements, { Foreground = { Color = fg } })
-- 		table.insert(elements, { Background = { Color = gradient[i] } })
-- 		table.insert(elements, { Text = " " .. seg .. " " })
-- 	end
--
-- 	window:set_right_status(wezterm.format(elements))
-- end)

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
