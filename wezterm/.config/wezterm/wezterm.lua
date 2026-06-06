local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 14.0

config.line_height = 1.1

config.cell_width = 1.0

local function get_appearance()
	local gui = wezterm.gui
	if gui then
		return gui.get_appearance()
	end
	-- Fallback if GUI is not available (e.g., headless mode)
	return "Dark"
end

local function set_color_scheme()
	local appearance = get_appearance()
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = set_color_scheme()

config.window_background_opacity = 1.0
config.window_decorations = "TITLE | RESIZE"
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

config.window_padding = {
	left = 0,
	right = 0,
	top = 3,
	bottom = 0,
}

config.front_end = "WebGpu"
config.max_fps = 120

config.default_cursor_style = "SteadyBar"
config.cursor_thickness = "2px"

config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"

config.scrollback_lines = 10000

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+(/[\w\d._-]+)+):(\d+):?(\d+)?["]?]],
	format = "$1:$3:$4",
})

local act = wezterm.action

config.keys = {
	-- Tabs
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = act.ActivateTab(4) },

	-- Splits (WezTerm's strength!)
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CMD|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

	-- Navigate splits
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- Font size
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },

	-- Quick launcher (WezTerm feature!)
	{ key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
}

local is_windows = wezterm.target_triple:find("windows") ~= nil

if is_windows then
	config.default_prog = { "pwsh.exe" }
	config.font_size = 13.0 -- Slightly smaller on Windows
	config.window_background_opacity = 1.0 -- Solid on Windows

	-- Use CTRL instead of CMD on Windows
	for _, key in ipairs(config.keys) do
		if key.mods:find("CMD") then
			key.mods = key.mods:gsub("CMD", "CTRL")
		end
	end
end

return config
