local awful = require("awful")
local wibox = require("wibox")
local home = os.getenv("HOME")

shutdown = {}

shutdown.icon = home.."/.config/awesome/shutdown/icons/shutdown.png"
shutdown.icon_opacity = 1
shutdown.shutdown_icon = home.."/.config/awesome/shutdown/icons/point.png"
shutdown.restart_icon = home.."/.config/awesome/shutdown/icons/point.png"
shutdown.suspend_icon = home.."/.config/awesome/shutdown/icons/point.png"
shutdown.logout_icon = home.."/.config/awesome/shutdown/icons/point.png"

function shutdown:init(args)
    self.icon = args.icon or shutdown.icon
    self.icon_opacity = args.icon_opacity or shutdown.icon_opacity
    self.shutdown_icon = args.shutdown_icon or shutdown.shutdown_icon
    self.restart_icon = args.restart_icon or shutdown.restart_icon
    self.suspend_icon = args.suspend_icon or shutdown.suspend_icon
    self.logout_icon = args.logout_icon or shutdown.logout_icon
end


shutdown.shutdown_menu = awful.menu({
    items = {
              {"Logout", function() awesome.quit() end, shutdown.logout_icon},
              {"Suspend", "systemctl suspend", shutdown.suspend_icon},
              {"Restart", "shutdown -r now", shutdown.restart_icon},
              {"Shutdown", "shutdown now", shutdown.shutdown_icon}
            }
})

shutdown_icon = wibox.widget {
    image  = shutdown.icon,
    resize = true,
    widget = wibox.widget.imagebox,
    forced_width = 30,
    forced_height = 30,
    opacity = shutdown.icon_opacity,
    visible = true
}

local shutdown_menu_selected = false

shutdown_icon:connect_signal("button::press", function(_, _, _, _, _)
    if shutdown_menu_selected then
        shutdown.shutdown_menu:hide()
        shutdown_menu_selected = false
    else
        shutdown.shutdown_menu:show()
        shutdown_menu_selected = true
    end
end)


return setmetatable(shutdown, {
    __call = shutdown.init,
})