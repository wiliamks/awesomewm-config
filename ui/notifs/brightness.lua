local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi

local width = dpi(200)
local height = dpi(200)
local screen = awful.screen.focused()

local bright_icon = wibox.widget {
    markup = "<span foreground='" .. beautiful.xcolor4 .. "'><b></b></span>",
    align = 'center',
    valign = 'center',
    font = beautiful.font_name .. '70',
    widget = wibox.widget.textbox,
    background = "#00000000"
}

-- create the bright_adjust component
local bright_adjust = wibox({
    screen = screen.primary,
    type = "notification",
    --x = screen.geometry.width / 2,
    x = screen.geometry.width / 2 - width / 2,
    --y = screen.geometry.height / 2 - height / 2 + 300,
    y = screen.geometry.height / 2,
    width = width,
    height = height,
    visible = false,
    ontop = true,
    bg = "#00000000"
})

local bright_value = wibox.widget {
    widget = wibox.widget.textbox,
    markup = "0%",
    align = 'center',
    valign = 'center',
    font = beautiful.font_name .. '25',
}

bright_adjust:setup{
    {
        layout = wibox.layout.align.vertical,
        {
            bright_icon,
	    top = dpi(30),
            --left = dpi(50),
            --right = dpi(50),
	    --bottom = dpi(15),
	    widget = wibox.container.margin
        },
        {
            --bright_bar,
            bright_value,
	    --left = dpi(35),
	    --right = dpi(35),
	    bottom = dpi(35),
	    --top = dpi(10),
            widget = wibox.container.margin
        },
    },
    shape = helpers.rrect(beautiful.border_radius),
    bg = beautiful.xbackground,
    border_width = beautiful.widget_border_width,
    border_color = beautiful.widget_border_color,
    widget = wibox.container.background
}

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_bright_adjust = gears.timer {
    timeout = 1,
    autostart = true,
    callback = function() bright_adjust.visible = false end
}

local Brightness = { mt = {}, wmt = {} }

local function notify()
    local command = [[ bash -c "brightnessctl i | grep -oP '\(\K[^%\)]+'" ]]

    awful.spawn.with_line_callback(command, {
	stdout = function(line)
	    bright_value.markup = line .. "%"

	    if bright_adjust.visible then
	    	hide_bright_adjust:again()
	    else
		bright_adjust.visible = true
		hide_bright_adjust:start()
	    end
	end,
	stderr = function ()
	end
    })
end

function Brightness:up()
    awful.spawn("brightnessctl s 5%+")
    notify()
end

function Brightness:down()
    awful.spawn("brightnessctl s 5%-")
    notify()
end

return Brightness

--awesome.connect_signal("signal::brightness", function(value)
    --bright_bar.value = value
    --if bright_adjust.visible then
        --hide_bright_adjust:again()
    --else
        --bright_adjust.visible = true
        --hide_bright_adjust:start()
    --end
--end)
