local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = require("helpers")
local dpi = beautiful.xresources.apply_dpi

local width = dpi(200)
local height = dpi(200)
local screen = awful.screen.focused()

local volume_icon = wibox.widget {
    markup = "<span foreground='" .. beautiful.xcolor4 .. "'><b></b></span>",
    align = 'center',
    valign = 'center',
    font = beautiful.font_name .. '70',
    widget = wibox.widget.textbox
}

local volume_adjust = wibox({
    screen = screen.primary,
    type = "notification",
    x = screen.geometry.width / 2 - width / 2,
    y = screen.geometry.height / 2,
    width = width,
    height = height,
    visible = false,
    ontop = true,
    bg = "#00000000"
})

local volume_value = wibox.widget {
    widget = wibox.widget.textbox,
    markup = "0%",
    align = 'center',
    valign = 'center',
    font = beautiful.font_name .. '25',
}

volume_adjust:setup{
    {
        layout = wibox.layout.align.vertical,
        {
            volume_icon,
            top = dpi(30),
            --left = dpi(50),
            --right = dpi(50),
            --bottom = dpi(15),
            widget = wibox.container.margin
        },
        {
            volume_value,
            --left = dpi(35),
            --right = dpi(35),
            bottom = dpi(35),
            --top = dpi(10),
            widget = wibox.container.margin
        }

    },
    shape = helpers.rrect(beautiful.border_radius),
    bg = beautiful.xbackground,
    border_width = beautiful.widget_border_width,
    border_color = beautiful.widget_border_color,
    widget = wibox.container.background
}

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer {
    timeout = 1,
    autostart = true,
    callback = function() volume_adjust.visible = false end
}

local Volume = { mt = {}, wmt = {} }

local function notify()
    local command = [[ bash -c "pulsemixer --get-volume | cut -c 1-3 | head -n1" ]]
    local mutedCommand = [[ bash -c "pulsemixer --get-mute" ]]

    awful.spawn.with_line_callback(mutedCommand, {
	stdout = function(muted)
	    if muted == "1" then
		volume_icon.markup = "<span foreground='" .. beautiful.xcolor4 ..
				     "'><b>ﳌ</b></span>"
	    else
		volume_icon.markup = "<span foreground='" .. beautiful.xcolor4 ..
					 "'><b></b></span>"
	    end
	end,
	stderr = function() end
    })

    awful.spawn.with_line_callback(command, {
	stdout = function(line)
	    volume_value.markup = line .. "%"
	    if volume_adjust.visible then
		hide_volume_adjust:again()
	    else
		volume_adjust.visible = true
		hide_volume_adjust:start()
	    end
	end,
	stderr = function() end
    })

end

function Volume:up()
    awful.spawn("pulsemixer --unmute --change-volume +5 --max-volume 100")
    notify()
end

function Volume:down()
    awful.spawn("pulsemixer --change-volume -5")
    notify()
end

function Volume:mute()
    awful.spawn("pulsemixer --toggle-mute")
    notify()
end

return Volume
