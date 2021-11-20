-- autostart.lua
-- Autostart Stuff Here
local awful = require("awful")

-- Add apps to autostart here
autostart_apps = {
    "xset -b", -- Disable bell 
    "blueman-applet", -- Bluetooth Systray Applet
    "nm-applet", -- Network Manager
    "cbatticon", -- Battery
    "fcitx", -- keybiard
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", -- Auth agent
    "picom", -- compositor
}

for app = 1, #autostart_apps do
    awful.spawn.single_instance(autostart_apps[app], awful.rules.rules)
end

-- EOF ------------------------------------------------------------------------
