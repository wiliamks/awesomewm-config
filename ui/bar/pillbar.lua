-- wibar.lua
-- Wibar (top bar)
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local rubato = require("module.rubato")

-- Awesome Panel -----------------------------------------------------------

local panel_managers = {
    start = require("ui.pop.start"),
    notifs = require("ui.pop.notifs")
}

local icon1 = wibox.widget {
    widget = wibox.widget.imagebox,
    image = beautiful.distro_logo,
    resize = true
}

local awesome_icon = wibox.widget {
    {
        icon1,
        top = dpi(5),
        bottom = dpi(5),
        left = dpi(10),
        right = dpi(5),
        widget = wibox.container.margin
    },
    bg = beautiful.xcolor0,
    widget = wibox.container.background
}

awesome_icon:buttons(gears.table.join(awful.button({}, 1, function()
    panel_managers.start:toggle()
    panel_managers.notifs:toggle()
end)))

-- Battery Bar Widget ---------------------------------------------------------

local battery_text = wibox.widget {
    font = beautiful.font,
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local battery_icon = wibox.widget {
    font = beautiful.icon_font_name .. "10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local battery_pill = wibox.widget {
    {
        helpers.horizontal_pad(2),
        -- {battery_icon, top = dpi(1), widget = wibox.container.margin},
        -- helpers.horizontal_pad(3),
        -- helpers.horizontal_pad(10),
        {battery_text, top = dpi(1), widget = wibox.container.margin},
        helpers.horizontal_pad(2),
        layout = wibox.layout.fixed.horizontal
    },
    left = dpi(10),
    right = dpi(10),
    widget = wibox.container.margin
}

local battery_wrapper = wibox.widget {
    battery_pill,
    value = 20,
    max_value = 100,
    min_value = 0,
    border_width = 2,
    border_color = beautiful.xcolor0,
    color = beautiful.xcolor8,
    widget = wibox.container.radialprogressbar
}

local anim = rubato.timed {
    pos = 0,
    rate = 120,
    easing = rubato.quadratic,
    intro = 0.4,
    duration = 1
}

awesome.connect_signal("signal::battery", function(percentage, state)
    local value = percentage

    local bat_icon = ""

    if value >= 90 and value <= 100 then
        bat_icon = ""
    elseif value >= 70 and value < 90 then
        bat_icon = ""
    elseif value >= 60 and value < 70 then
        bat_icon = ""
    elseif value >= 50 and value < 60 then
        bat_icon = ""
    elseif value >= 30 and value < 50 then
        bat_icon = ""
    elseif value >= 15 and value < 30 then
        bat_icon = ""
    else
        bat_icon = ""
    end

    -- if charging
    if state == 1 then
        bat_icon = ""
        anim:subscribe(function(perc, time)
            battery_wrapper.value = perc
            if time == anim.duration then
                anim:reset()
                anim.pos = 0
                anim.target = 100
            end
        end)
        if anim.state == false then anim.target = 100 end
    else
        anim:unsubscribe()
        battery_wrapper.value = percentage
    end

    -- if full
    if state == 4 then
        bat_icon = ""
        -- battery_wrapper.color = beautiful.xcolor10
    else
        battery_wrapper.color = beautiful.xcolor8
    end

    battery_icon.markup = "<span foreground='" .. beautiful.xcolor12 .. "'>" ..
                              bat_icon .. "</span>"
    battery_text.markup = "<span foreground='" .. beautiful.xcolor12 .. "'>" ..
                              string.format("%1d", value) .. "%" .. "</span>"
end)

-- Date Widget ----------------------------------------------------------------

local date_text = wibox.widget {
    font = beautiful.font,
    format = "%d/%m/%y",
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

date_text.markup = "<span foreground='" .. beautiful.xcolor11 .. "'>" ..
                       date_text.text .. "</span>"

date_text:connect_signal("widget::redraw_needed", function()
    date_text.markup = "<span foreground='" .. beautiful.xcolor11 .. "'>" ..
                           date_text.text .. "</span>"
end)

local date_icon = wibox.widget {
    font = beautiful.icon_font_name .. "12",
    markup = "<span foreground='" .. beautiful.xcolor11 .. "'></span>",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local date_pill = wibox.widget {
    {
        {date_icon, top = dpi(1), widget = wibox.container.margin},
        helpers.horizontal_pad(10),
        {date_text, top = dpi(1), widget = wibox.container.margin},
        layout = wibox.layout.fixed.horizontal
    },
    left = dpi(10),
    right = dpi(10),
    widget = wibox.container.margin
}

-- Time Widget ----------------------------------------------------------------

local time_text = wibox.widget {
    font = beautiful.font,
    format = "%H:%M",
    align = "center",
    valign = "center",
    widget = wibox.widget.textclock
}

time_text.markup = "<span foreground='" .. beautiful.xcolor5 .. "'>" ..
                       time_text.text .. "</span>"

time_text:connect_signal("widget::redraw_needed", function()
    time_text.markup = "<span foreground='" .. beautiful.xcolor5 .. "'>" ..
                           time_text.text .. "</span>"
end)

local time_icon = wibox.widget {
    font = beautiful.icon_font_name .. "12",
    markup = "<span foreground='" .. beautiful.xcolor5 .. "'></span>",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local time_pill = wibox.widget {
    {
        {time_icon, top = dpi(1), widget = wibox.container.margin},
        helpers.horizontal_pad(10),
        {time_text, top = dpi(1), widget = wibox.container.margin},
        layout = wibox.layout.fixed.horizontal
    },
    left = dpi(10),
    right = dpi(10),
    widget = wibox.container.margin
}

-- Systray Widget -------------------------------------------------------------

local mysystray = wibox.widget.systray()
mysystray:set_base_size(beautiful.systray_icon_size)

local mysystray_container = {
    mysystray,
    left = dpi(8),
    right = dpi(8),
    widget = wibox.container.margin
}

-- Tasklist Buttons -----------------------------------------------------------

local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end), awful.button({}, 3, function()
        awful.menu.client_list({theme = {width = 250}})
    end), awful.button({}, 4, function() awful.client.focus.byidx(1) end),
                             awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

-- Playerctl Bar Widget -------------------------------------------------------

-- Title Widget
local song_title = wibox.widget {
    markup = "Nothing Playing",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local song_artist = wibox.widget {
    markup = "nothing playing",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local song_logo = wibox.widget {
    markup = '<span foreground="' .. beautiful.xcolor6 .. '"> </span>',
    font = beautiful.icon_font_name .. 12,
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local playerctl_bar = wibox.widget {
    {
        {
            song_logo,
            top = dpi(2),
            left = dpi(3),
            right = dpi(0),
            bottom = dpi(2),
            widget = wibox.container.margin
        },
        {
            {
                song_title,
                expand = "outside",
                layout = wibox.layout.align.vertical
            },
            top = dpi(1),
            left = dpi(10),
            right = dpi(10),
            widget = wibox.container.margin
        },
        {
            {
                song_artist,
                expand = "outside",
                layout = wibox.layout.align.vertical
            },
            top = dpi(1),
            left = dpi(10),
            widget = wibox.container.margin
        },
        spacing = 1,
        spacing_widget = {
            bg = beautiful.xcolor8,
            shape = gears.shape.powerline,
            widget = wibox.container.background
        },
        layout = wibox.layout.fixed.horizontal
    },
    left = dpi(10),
    right = dpi(13),
    widget = wibox.container.margin
}

playerctl_bar.visible = false

awesome.connect_signal("bling::playerctl::no_players",
                       function() playerctl_bar.visible = false end)

-- Get Title
awesome.connect_signal("bling::playerctl::title_artist_album",
                       function(title, artist, _)
    playerctl_bar.visible = true
    song_title.markup = '<span foreground="' .. beautiful.xcolor5 .. '">' ..
                            title .. "</span>"

    song_artist.markup = '<span foreground="' .. beautiful.xcolor4 .. '">' ..
                             artist .. "</span>"
end)

-- Create the Wibar -----------------------------------------------------------

local final_systray = wibox.widget {
    {
        mysystray_container,
        top = dpi(6),
        left = dpi(3),
        right = dpi(3),
        layout = wibox.container.margin
    },
    bg = beautiful.xcolor0,
    shape = helpers.rrect(12),
    widget = wibox.container.background
}

local wrap_widget = function(w)
    local wrapped = wibox.widget {
        w,
        top = dpi(8),
        left = dpi(4),
        bottom = dpi(8),
        right = dpi(4),
        widget = wibox.container.margin
    }
    return wrapped
end

local make_pill = function(w, c)
    local pill = wibox.widget {
        w,
        bg = c,
        shape = helpers.rrect(12),
        widget = wibox.container.background
    }
    return pill
end

screen.connect_signal("request::desktop_decoration", function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create layoutbox widget
    s.mylayoutbox = awful.widget.layoutbox(s)

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        type = "dock",
        ontop = false
    })

    -- Remove wibar on full screen
    local function add_wibar(c)
        if c.fullscreen or c.maximized then
            c.screen.mywibox.visible = true
        end
    end

    -- Hide bar when a splash widget is visible
    awesome.connect_signal("widgets::splash::visibility", function(vis)
        screen.primary.mywibox.visible = not vis
    end)

    client.connect_signal("request::unmanage", add_wibar)

    -- Create the taglist widget
    s.mytaglist = require("ui.widgets.pacman_taglist")(s)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        bg = beautiful.wibar_bg,
        style = {bg = beautiful.xcolor0, shape = helpers.rrect(12)},
        layout = {spacing = dpi(8), layout = wibox.layout.fixed.horizontal},
        widget_template = {
            {
                {
                    {
                        awful.widget.clienticon,
                        top = dpi(1),
                        bottom = dpi(1),
                        layout = wibox.container.margin
                    },
                    -- helpers.horizontal_pad(6),
                    -- {id = 'text_role', widget = wibox.widget.textbox},
                    layout = wibox.layout.fixed.horizontal
                },
                top = dpi(4),
                bottom = dpi(4),
                left = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin
            },
            id = "background_role",
            widget = wibox.container.background,
            create_callback = function(self, c, index, clients)
                self:connect_signal('mouse::enter', function()
                    self.border_color = beautiful.xcolor8
                    self.border_width = dpi(1)
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        true, c)
                end)
                self:connect_signal('mouse::leave', function()
                    self.border_width = dpi(0)
                    awesome.emit_signal("bling::task_preview::visibility", s,
                                        false, c)
                end)
            end
        }
    }

    -- Add widgets to the wibox
    s.mywibox:setup{
        layout = wibox.layout.align.vertical,
        nil,
        {
            {
                layout = wibox.layout.align.horizontal,
                expand = "none",
                {
                    layout = wibox.layout.fixed.horizontal,
                    helpers.horizontal_pad(4),
                    -- function to add padding
                    wrap_widget( --
                    -- function to add pill
                    make_pill({
                        awesome_icon,
                        {
                            s.mytaglist,
                            helpers.horizontal_pad(4),
                            layout = wibox.layout.fixed.horizontal
                        },
                        spacing = 14,
                        spacing_widget = {
                            color = beautiful.xcolor8,
                            shape = gears.shape.powerline,
                            widget = wibox.widget.separator
                        },
                        layout = wibox.layout.fixed.horizontal
                    }, beautiful.xcolor0)),
                    s.mypromptbox,
                   wrap_widget(s.mytasklist)
                },
                { wrap_widget(make_pill(playerctl_bar, beautiful.xcolor0))
, widget = wibox.container.constraint},
                {
                    wrap_widget(make_pill(time_pill, beautiful.xcolor0)),
                    wrap_widget(make_pill(date_pill, beautiful.xcolor0)),
		    --wrap_widget(make_pill(battery_wrapper, beautiful.xcolor0)),
		    wrap_widget(awful.widget.only_on_screen(final_systray,
							    screen[1])),
                    wrap_widget(make_pill(
                                    {
                            s.mylayoutbox,
                            top = dpi(5),
                            bottom = dpi(5),
                            right = dpi(8),
                            left = dpi(8),
                            widget = wibox.container.margin
                        }, beautiful.xcolor0)),
                    helpers.horizontal_pad(4),
                    layout = wibox.layout.fixed.horizontal
                }
            },
            widget = wibox.container.background,
            bg = beautiful.wibar_bg_secondary
        },
        { -- This is for a bottom border in the bar
            widget = wibox.container.background,
            --bg = beautiful.darker_bg,
            bg = beautiful.foreground,
            forced_height = beautiful.widget_border_width
        }
    }
end)

-- EOF ------------------------------------------------------------------------
