pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

beautiful.init("~/.config/awesome/themes/default/theme.lua")

require("screenshot.screenshot")
require("shutdown_menu.shutdown")

local volume = require("volume.volume")
local battery = require("battery.battery")

local workspaces_count = 5
local home = os.getenv("HOME")

volume { }
battery {
    not_charging_icon = home.."/.config/awesome/battery/icons/charging.png"
}

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

for s = 1, screen.count() do
	gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", home, "default")
beautiful.init(theme_path)

terminal = "alacritty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
file_manager="pcmanfm"
browser="brave-browser"
vscode="code"
modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
}

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}
local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                    menu = mymainmenu,
                                    opacity = 0.6,
                                    forced_width = 30,
                                    forced_height = 10 })

menubar.utils.terminal = terminal

mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()
mytextclock.format = " %a %d, %H:%M "

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    for i = 1, workspaces_count, 1 do
        if i == 1 then
            awful.tag.add(tostring(i), {
                layout             = awful.layout.layouts[2],
                screen             = s,
                selected = true,
                gap = 3,
                gap_single_client = false
            })
        else
            awful.tag.add(tostring(i), {
                layout             = awful.layout.layouts[2],
                screen             = s,
                gap = 3,
                gap_single_client = false
            })
        end
    end
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        style   = {
            shape = gears.shape.powerline
        },
        layout   = {
            spacing = -12,
            spacing_widget = {
                color  = '#21252b',
                shape  = gears.shape.powerline,
                widget = wibox.widget.separator,
            },
            layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'index_role',
                                widget = wibox.widget.textbox,
                            },
                            margins = 4,
                            widget  = wibox.container.margin,
                        },
                        widget = wibox.container.background,
                    },
                    {
                        {
                            id     = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget  = wibox.container.margin,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left  = 11,
                right = 11,
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
            -- Add support for hover colors and an index label
            create_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
                self:connect_signal('mouse::enter', function()
                    if self.bg ~= '#21252b' then
                        self.backup     = self.bg
                        self.has_backup = true
                    end
                    self.bg = '#21252b'
                end)
                self:connect_signal('mouse::leave', function()
                    if self.has_backup then self.bg = self.backup end
                end)
            end,
            update_callback = function(self, c3, index, objects) --luacheck: no unused args
                self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
            end,
        },
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
    screen   = s,
    filter   = awful.widget.tasklist.filter.currenttags,
    buttons  = tasklist_buttons,
    style    = {
        shape_border_width = 1,
        shape_border_color = '#777777',
        shape  = gears.shape.rounded_bar,
    },
    layout   = {
        spacing = 10,
        spacing_widget = {
            {
                forced_width = 5,
                shape        = gears.shape.circle,
                widget       = wibox.widget.separator
            },
            valign = 'center',
            halign = 'center',
            widget = wibox.container.place,
        },
        layout  = wibox.layout.flex.horizontal
    },
    widget_template = {
        {
            {
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = 2,
                    widget  = wibox.container.margin,
                },
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            left  = 10,
            right = 10,
            widget = wibox.container.margin
        },
        id     = 'background_role',
        widget = wibox.container.background,
    },
}

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox.bg = "#535d6c"
    s.mywibox.height = 100
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            volume_icon,
            volume_bar,
            battery_percentage,
            battery_icon,
            mytextclock,
            shutdown_icon,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

keyboard_layouts = {"us", "ua", "ru"}
cur_layout = 1

function set_layout()
    awful.util.spawn("setxkbmap "..keyboard_layouts[cur_layout])
end

function switch_layout() 
    if cur_layout >= 3 or cur_layout <= 0 then
        cur_layout = 1
    else
        cur_layout = cur_layout + 1
    end
    set_layout()
end

set_layout()

local switch_to_tag_rule=true

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Tab",  awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ "Mod1",           }, "Tab",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key({ modkey }, "Up",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- My shortcuts
    awful.key({ modkey },            "p",     function () awful.util.spawn("dmenu_run") end,
             {description = "run prompt", group = "launcher"}),
    awful.key({ modkey },            "b",
            function ()
                local cur_tag = awful.screen.focused().selected_tag

                if cur_tag then
                    if cur_tag.index == 2 then
                        switch_to_tag_rule = false
                    else
                        switch_to_tag_rule = true
                    end
                end
                awful.util.spawn(browser)
            end,
             {description = "run brave browser", group = "launcher"}),
    awful.key({ modkey },            "v",
            function ()
                local cur_tag = awful.screen.focused().selected_tag
                if cur_tag then
                    if cur_tag.index == 3 then
                        switch_to_tag_rule = false
                    else
                        switch_to_tag_rule = true
                    end
                end
                awful.util.spawn(vscode)
            end,
             {description = "run vscode", group = "launcher"}),
    awful.key({ modkey },            "/",     function () awful.util.spawn(file_manager) end,
             {description = "run file manager", group = "launcher"}),
    awful.key({ "Control" },            ";",
            function ()
                volume.set_volume(volume.value - 2)
            end,
            {description = "volume down", group = "system"}),
    awful.key({ "Control" },            "'",
            function ()
                volume.set_volume(volume.value + 2)
            end,
             {description = "volume up", group = "system"}),
    awful.key({ "Mod1"},         "Shift_L",     switch_layout,
             {description = "switch keyboard layout", group = "system"}),
    awful.key({ "Shift"},         "Alt_L",     switch_layout,
             {description = "switch keyboard layout", group = "system"}),

    awful.key({ modkey, "Shift"},         "Right",
                function()
                    local cur_tag = client.focus and client.focus.first_tag or nil
                    if cur_tag then
                        local next_tag = cur_tag.index
                        if cur_tag.index >= workspaces_count then
                            next_tag = 1
                        else
                            next_tag = cur_tag.index + 1
                        end
                        if client.focus then
                            local tag = client.focus.screen.tags[next_tag]
                            if tag then
                                client.focus:move_to_tag(tag)
                            end
                        end
                        awful.tag.viewnext()
                    end
                end,
             {description = "move client and focused window to next tag", group = "client"}),

    awful.key({ modkey, "Shift"},         "Left",
                function()
                    local cur_tag = client.focus and client.focus.first_tag or nil
                    if cur_tag then
                        local next_tag = cur_tag.index
                        if cur_tag.index <= 1 then
                            next_tag = workspaces_count
                        else
                            next_tag = cur_tag.index - 1
                        end
                        if client.focus then
                            local tag = client.focus.screen.tags[next_tag]
                            if tag then
                                client.focus:move_to_tag(tag)
                            end
                        end
                        awful.tag.viewprev()
                    end
                end,
             {description = "move client and focused window to previous tag", group = "client"}),

    awful.key({ }, "Print", scrot_full,
             {description = "Take a screenshot of entire screen", group = "screenshot"}),
    awful.key({ "Shift" }, "Print", scrot_window,
             {description = "Take a screenshot of focused window", group = "screenshot"}),

    awful.key({ modkey, "Shift" }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "r", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,  "Shift" },         "Down",     function (c) c:kill() end,
              {description = "close window in focus", group = "system"}),
    awful.key({ modkey,           }, "Down",
              function (c)
                  c.minimized = true
              end,
              {description = "minimize", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
for i = 1, workspaces_count do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
     },
     callback =  {
        function ()

        end
        }
    },

    { rule_any = { instance = {vscode}, class = {"Code"} },
      properties = {
            tag = "3",
            callback = function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[3]
                if tag and switch_to_tag_rule then
                    tag:view_only()
                end
                switch_to_tag_rule = true
            end
        }
    },

    { rule_any = { instance = {"brave-browser"}, class = {"Brave-browser"} },
      properties = {
            tag = "2",
            callback = function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[2]
                if tag and switch_to_tag_rule then
                    tag:view_only()
                end
                switch_to_tag_rule = true
            end
        }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",
          "copyq",
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",
          "Sxiv",
          "Tor Browser",
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },
}
-- }}}

-- {{{ Signals
client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.add_signal("focus",
        function(c)
            c.border_width = "0"
            c.border_color = beautiful.border_focus
        end)


client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- Autostart applications
awful.spawn.with_shell("compton")
awful.spawn.with_shell("xinput set-prop 'FTE1200:00 0B05:0201 Touchpad' 'libinput Tapping Enabled' 1")
