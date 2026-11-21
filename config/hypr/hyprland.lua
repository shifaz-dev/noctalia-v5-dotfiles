-- CachyOS Hyprland Configuration

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.defaults")
require("config.environment")
require("config.input")
require("config.keybinds")
require("config.misc")
require("config.monitors")
require("config.windowrules")
require("config.layerrules")

-- For Noctalia Color templates
local noctalia = require("noctalia")
noctalia.apply_theme()

-- Gradient active border from the current wallpaper palette
-- (must come after apply_theme, which sets a flat border)
hl.config({
    general = {
        col = {
            active_border = {
                colors = { noctalia.colors.primary, noctalia.colors.secondary },
                angle = 45,
            },
        },
    },
})
