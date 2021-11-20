-- Credits to https://github.com/WillPower3309/awesome-widgets/blob/master/wallpaper-blur.lua
-- @author William McKinnon
-- I tried implementing this with `gears.wallpaper` but the latency was just too much, so feh is preferable here
local awful = require("awful")

--local wallpaper = beautiful.wallpaper
--local wallpaper = "/home/wiliamks/.wallpaper/mechanical/347UR-Kurosawa-Dia-次は-わたくしですわね-S-I-Collection-AHYMU3.png"
local wallpaper = "~/.config/awesome/images/4k.jpg"

awful.spawn.with_shell("feh --bg-fill " .. wallpaper)
