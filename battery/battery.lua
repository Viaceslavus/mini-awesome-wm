local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local open = io.open

battery = { }

battery.device = "/sys/class/power_supply/BAT0"
local capacity_info = battery.device.."/capacity"
local status_info = battery.device.."/status"

battery.percentage = "100%"
battery.charging_icon  = os.getenv("HOME").."/.config/awesome/battery/icons/charging.png"
battery.not_charging_icon = os.getenv("HOME").."/.config/awesome/battery/icons/not_charging.png"
battery.icon_opacity = 0.5
battery.update_timeout = 10

battery.percentage_text = wibox.widget{
    markup = ""..battery.percentage,
    align  = 'right',
    valign = 'center',
    font = "inconsolata bold 11",
    forced_width = 54,
    widget = wibox.widget.textbox
}

battery.battery_icon = wibox.widget {
    image  = battery.charging_icon,
    resize = true,
    valign = "center",
    halign = "center",
    widget = wibox.widget.imagebox,
    forced_width = 25,
    forced_height = 25,
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
    timeout   = battery.update_timeout,
    call_now  = true,
    autostart = true,
    callback  = function()
        local capacity = read_file(capacity_info)
        local capacity_number = string.gsub(capacity, "\n+", "")
        battery.percentage_text.markup = ""..capacity_number.."% "
        battery.percentage = tonumber(capacity_number)
        if capacity_number == 100 then
            battery.battery_icon.image = battery.charging_icon
        else
            local status_file = read_file(status_info)
            local status = string.gsub(status_file, "\n+", "")
            if string.find(status, "not") or string.find(status, "Not") then
                battery.battery_icon.image = battery.not_charging_icon
            else
                battery.battery_icon.image = battery.charging_icon
            end
        end
    end
}

return battery
