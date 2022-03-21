local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local open = io.open

local capacity_info = "/sys/class/power_supply/BAT0/capacity"
local status_info = "/sys/class/power_supply/BAT0/status"

battery = { }

battery.percentage = "100%"
battery.charging_icon  = ""
battery.icon_opacity = 1

battery.percentage_text = wibox.widget{
    markup = " "..battery.percentage,
    align  = 'right',
    valign = 'center',
    font = "inconsolata bold 11",
    forced_width = 40,
    widget = wibox.widget.textbox
}

battery.battery_icon = wibox.widget {
    image  = battery.charging_icon,
    resize = true,
    valign = "center",
    halign = "center",
    widget = wibox.widget.imagebox,
    forced_width = 30,
    forced_height = 30,
    opacity = battery.icon_opacity,
    visible = true
}

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

gears.timer {
    timeout   = 10,
    call_now  = true,
    autostart = true,
    callback  = function()
        local capacity = read_file(capacity_info)
        local capacity_number = string.gsub(capacity, "\n+", "")
        battery.percentage_text.markup = " "..capacity_number.."%"
    end
}

return battery
