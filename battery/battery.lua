local gears = require("gears")
local wibox = require("wibox")
local open = io.open

battery = { }

battery.device = "/sys/class/power_supply/BAT0"
local capacity_info = battery.device.."/capacity"
local status_info = battery.device.."/status"

battery.percentage = "100%"
battery.charging_icon = os.getenv("HOME").."/.config/awesome/battery/icons/charging.png"
battery.not_charging_icon = os.getenv("HOME").."/.config/awesome/battery/icons/not_charging.png"
battery.icon_opacity = 0.5
battery.update_timeout = 10

function battery:init(args)
    self.charging_icon = args.charging_icon or battery.charging_icon
    self.not_charging_icon = args.not_charging_icon or battery.not_charging_icon
    self.icon_opacity = args.icon_opacity or battery.icon_opacity
    self.update_timeout = args.update_timeout or battery.update_timeout
    init_battery()
end

battery_percentage = wibox.widget{
    markup = ""..battery.percentage,
    align  = 'right',
    valign = 'center',
    font = "inconsolata bold 11",
    forced_width = 54,
    widget = wibox.widget.textbox
}

battery_icon = wibox.widget {
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
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a" 
    file:close()
    return content
end

function init_battery()
    local capacity = read_file(capacity_info)
    local capacity_number = string.gsub(capacity, "\n+", "")
    battery_percentage.markup = ""..capacity_number.."% "
    battery.percentage = tonumber(capacity_number)
    if capacity_number == 100 then
        battery_icon.image = battery.charging_icon
    else
        local status_file = read_file(status_info)
        local status = string.gsub(status_file, "\n+", "")
        if string.find(status, "not") or string.find(status, "Not") or string.find(status, "dis") or string.find(status, "Dis")
        then
            if battery.percentage ~= 100 then
                battery_icon.image = battery.not_charging_icon
            else
                battery_icon.image = battery.charging_icon
            end
        else
            battery_icon.image = battery.charging_icon
        end
    end
end

gears.timer {
    timeout   = battery.update_timeout,
    call_now  = true,
    autostart = true,
    callback  = init_battery
}

return setmetatable(battery, {
    __call = battery.init,
})
