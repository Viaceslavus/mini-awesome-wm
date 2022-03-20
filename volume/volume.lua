local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

volume = { }

volume.initial_value = 25
volume.value = volume.initial_value
volume.bar_color = "#3a3a35"
volume.handle_color = "#3a3a35"
volume.volume_icon_image = os.getenv("HOME").."/.config/awesome/volume/icons/volume.png"
volume.mute_icon_image = os.getenv("HOME").."/.config/awesome/volume/icons/mute.png"
volume.bar_width = 80
volume.bar_height = 3
volume.icon_opacity = 0.7

local last_value = volume.initial_value

volume.volume_icon = wibox.widget {
    image  = volume.volume_icon_image,
    resize = true,
    valign = "center",
    halign = "right",
    widget = wibox.widget.imagebox,
    forced_width = 30,
    forced_height = 30,
    opacity = volume.icon_opacity,
    visible = true
}

volume.volume_bar = wibox.widget {
    bar_shape           = gears.shape.rounded_rect,
    bar_height          = volume.bar_height,
    bar_color           = volume.bar_color,
    handle_color        = volume.handle_color,
    handle_shape        = gears.shape.circle,
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    value               = volume.initial_value,
    widget              = wibox.widget.slider,
    forced_width = volume.bar_width,
    visible = true
}

local function _set_volume(new_value) 
    awful.util.spawn("amixer set Master " .. tostring(new_value .. "%"))
    last_value = volume.value
    volume.value = new_value

    if new_value <= 0 then
        volume.volume_icon.image = volume.mute_icon_image
    else
        volume.volume_icon.image = volume.volume_icon_image
    end
end

function volume.set_volume(new_value)
    volume.volume_bar.value = new_value
end

function volume.init_volume()
    volume.set_volume(volume.initial_value)
    _set_volume(volume.volume_bar.value)
end

volume.volume_bar:connect_signal("property::value", function(_, val)
    _set_volume(volume.volume_bar.value)
end)

volume.volume_icon:connect_signal("button::press", function(_, _, _, _, _)
    if volume.value > 0 then
        volume.set_volume(0)
    else
        volume.set_volume(last_value)
    end
end)


return volume
