-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

-- config.color_scheme = '3024 Night'
-- config.color_scheme = 'Aci (Gogh)'
-- config.color_scheme = 'Adventure'
-- config.color_scheme = 'Afterglow (Gogh)'
config.color_scheme = 'arcoiris'

config.window_background_opacity = 0.85
config.macos_window_background_blur = 10

-- and finally, return the configuration to wezterm
return config