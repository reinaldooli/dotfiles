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

-- Per-machine overrides (untracked). Same split as ~/.gitconfig.local and
-- ~/.zsh.local.d.
--
-- ~/.wezterm.local.lua must RETURN a table of settings; it cannot assign to
-- `config` directly, because dofile runs the file as its own chunk which
-- cannot see this file's locals. Example:
--
--     return { font_size = 14, color_scheme = "Tokyo Night" }
--
-- A missing file is fine -- pcall swallows the error.
local ok, overrides = pcall(dofile, wezterm.home_dir .. "/.wezterm.local.lua")
if ok and type(overrides) == "table" then
  for key, value in pairs(overrides) do
    config[key] = value
  end
end

-- and finally, return the configuration to wezterm
return config