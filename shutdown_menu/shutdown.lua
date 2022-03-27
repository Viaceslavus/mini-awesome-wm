local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local home = os.getenv("HOME")

shutdown_menu = awful.menu({
    items = {
              {"Logout", function() awesome.quit() end, home.."/.config/awesome/shutdown_menu/icons/point.png"},
              {"Suspend", "systemctl suspend", home.."/.config/awesome/shutdown_menu/icons/point.png"},
              {"Restart", "shutdown -r now", home.."/.config/awesome/shutdown_menu/icons/point.png"},
              {"Shutdown", "shutdown now", home.."/.config/awesome/shutdown_menu/icons/point.png"}
            }
})

shutdown_icon = wibox.widget {
    image  = home.."/.config/awesome/shutdown_menu/icons/shutdown.png",
    resize = true,
    widget = wibox.widget.imagebox,
    forced_width = 30,
    forced_height = 30,
    opacity = 1,
    visible = true
}

local shutdown_menu_selected = false

shutdown_icon:connect_signal("button::press", function(_, _, _, _, _)
    if shutdown_menu_selected then
        shutdown_menu:hide()
        shutdown_menu_selected = false
    else
        shutdown_menu:show()
        shutdown_menu_selected = true
    end
end)