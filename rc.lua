-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local timer = (type(timer) == "table" and timer or require("gears.timer"))
local spawn_with_shell = awful.spawn.with_shell

--local awful_spawn = (type(awful.spawn) == "table" and awful.spawn or awful.util.spawn)
local awful_spawn = awful.spawn

awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")
local lain = require("lain")
local treetile = require("treetile")

-- Theme handling library
local beautiful = require("beautiful")
beautiful.init("/usr/share/awesome/themes/zenburn-custom/theme.lua")
--theme.font = "San Francisco Text 9"

-- Notification library
local naughty = require("naughty")

-- Menubar
local menubar = require ("menubar")
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = true

require ("eminent")
--local hints = require ("hints")
local keychains = require("keychains")
local revelation=require("revelation")
local drop = require("scratchdrop")
local capi = { tag = tag}

local hotkeys_popup = require("awful.hotkeys_popup").widget

function clip_translate()
    local clip = nil
    local ff = io.popen("xclip -o")
    clip = ff:read("*all")
    if clip then
       awful_spawn("gtranslate \"" .. clip .."\"",false)   --change path to script       
    end
end

function debuginfo( message )
    if type(message) == "table" then
        for k,v in pairs(message) do 
            naughty.notify({ text = "key: "..k.." value: "..tostring(v), timeout = 10 })
        end
    elseif type(message) == 'string' then 
        nid = naughty.notify({ text = message, timeout = 10 })
    else
        nid = naughty.notify({ text = tostring(message), timeout = 10 })
    end
end




-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- set locale
os.setlocale(os.getenv("LANG"))

-- Themes define colours, icons, and wallpapers

theme.lain_icons         = os.getenv("HOME") .. "/.config/awesome/lain/icons/layout/zenburn/"
theme.layout_termfair    = theme.lain_icons .. "termfair.png"
theme.layout_cascade     = theme.lain_icons .. "cascade.png"
theme.layout_cascadetile = theme.lain_icons .. "cascadebrowse.png"
theme.layout_centerwork  = theme.lain_icons .. "centerwork.png"
theme.layout_centerfair  = theme.lain_icons .. "centerfair.png"
theme.layout_treetile = os.getenv("HOME") .. "/.config/awesome/treetile/layout_icon.png"
theme.awful_widget_height           = 18
theme.awful_widget_margin_top       = 2
theme.tasklist_disable_icon         = false
--theme.tasklist_floating             = ""
--theme.tasklist_maximized_horizontal = ""
--theme.tasklist_maximized_vertical   = ""

revelation.init()

-- This is used later as the default terminal and editor to run.
--terminal = "lxterminal"
--terminal = "lilyterm"
--terminal = "terminator"
terminal = "termite"
--terminal = "xfce-terminal"
editor = os.getenv("EDITOR") or "gvim"
editor_cmd = terminal .. " -e " .. editor
val = nil
browser1="firefox"


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.

modkey = "Mod4"

lain.layout.termfair.nmaster = 2
lain.layout.termfair.ncol = 1
lain.layout.centerfair.nmaster = 2
lain.layout.centerfair.ncol = 1

-- Table of layouts to cover with awful.layout.inc, order matters.

layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    awful.layout.suit.magnifier,
    lain.layout.termfair,
    lain.layout.centerfair,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    treetile,
}
--}}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   {"hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -x man awesome &" },
   { "edit config", "gvim".. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

local function create_layoutitems()
    local layoutmenu = {}
    for i,_ in ipairs(layouts) do
        table.insert(layoutmenu, {" "..layouts[i].name, function () awful.layout.set(layouts[i]) 
            local name = awful.layout.getname(layouts[i])
            naughty.notify({text = '<span font_desc="Monaco 10">'..name..'</span>',
                            title = "current layout:", timeout=8,
                           screen=mouse.screen})
                       end, theme["layout_"..layouts[i].name]})
        --debuginfo(layouts[i].name)
    end
    return layoutmenu 
end

local mylayoutitems = create_layoutitems()
mylayoutmenu = awful.menu({items = mylayoutitems})


mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = "xterm" -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

markup = lain.util.markup

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %b %d, %H:%M ")
--mytextclock = awful.widget.textclock()

-- Create orglendar
-- switch lain calendar
lain.widgets.calendar:attach(mytextclock, {followmouse = true})
lain.widgets.contrib.task:attach(mytextclock, {followmouse = true})

-- creat pomodoro widget

mypomo = wibox.widget {
    max_value     = 100,
    value         = 0.0,
    forced_height = 20,
    forced_width  = 100,
    paddings      = 0,
    border_width  = 1,
    border_color  = '#474719',
    shape         = gears.shape.octogon,
    bar_shape     = gears.shape.octogon,
    background_color = beautiful.bg_normal,
    widget        = wibox.widget.progressbar,

}

--mypomo:set_ticks(true)
--mypomo:set_ticks_size(5)

mypomo:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" } }})
mypomo:buttons(awful.util.table.join (
          awful.button ({}, 1, function()
            spawn_with_shell("mypomo &")
          end),
          awful.button ({}, 3, function()
            spawn_with_shell("pkill mypomo && mypomo -c")
          end)
      ))

mypomo_margin = wibox.container.margin(mypomo, 2, 5)
mypomo_margin:set_top(4)
mypomo_margin:set_bottom(4)

mypomo_widget = wibox.container.background(mypomo_margin)
mypomo_widget:set_bgimage(beautiful.widget_bg)

-- mypomo container 
mypomo_txt = wibox.widget {
        markup = "<span foreground='#7493d2'> Stopped </span>",
        align  = 'right',
        widget = wibox.widget.textbox,
}

mypomo_container = wibox.widget {
    mypomo_widget,
    mypomo_txt,
    layout = wibox.layout.stack
}

-- mypomo wrapping with margin and background


mypomo_tooltip = awful.tooltip({objects = {mypomo_widget}})
mypomo_tooltip:set_text('Stopped')

local pomodoro_image_path = awful.util.getdir("config") .. "/icons/pomodoro_icon.png"

mypomo_img = wibox.widget.imagebox()
mypomo_img:set_image(pomodoro_image_path)
mypomo_img:set_resize (true)

-- Create Mail updater
mailconf = '/home/dccf87/.config/mail_servers.conf'
  --Icloud = {id = 'Icloud', file='/home/dccf87/.munread', cnt=0},
mails = { Gmail = {id = 'Gmail', file='/home/dccf87/.gunread', cnt=0},
          Durham = {id = 'Durham', file='/home/dccf87/.dunread', cnt=0},
          AIP = {id = 'AIP', file='/home/dccf87/.aunread', cnt=0}}

local mailhoover = require("mailhoover")
for k, t in pairs(mails) do
    t.wibox= wibox.widget.textbox()
    t.wibox:set_text(k.."  ?  ")
    mailhoover.addToWidget(t.wibox, t.file, t.id)
end

-- Create Weather widget
yawn = lain.widgets.weather({city_id = 2852458})

-- my volume widget

vol = wibox.widget.textbox()
mc12 = wibox.widget.textbox()

--mc12_card = "-c 4"
local ff = io.popen("aplay -l | grep -i MC12 | cut -f 1 -d: | grep -Eo '[0-9]'")
mc12_card = ff:read("*all")
mc12_card = "-c "..string.sub(mc12_card, 1,1)

alsacards = {main = {wibox = vol,
                    mixer = "xterm -e alsamixer",
                    header = 'Vol:',
                     card = "-c 0",
                  channel = "Master",
                     step = "5%" },
         mc12 = {  wibox  = mc12,
                    header = 'MC12:',
                    mixer = "xterm -e alsamixer "..mc12_card,
                     card = mc12_card,
                  channel = "PCM",
                     step = "5%" }}

for k,t in pairs(alsacards) do 
    t.wibox:buttons(awful.util.table.join (
          awful.button ({}, 1, function()
            awful_spawn(t.mixer)
          end),
          awful.button ({}, 3, function()
            spawn_with_shell(string.format("amixer %s set %s toggle", 
                t.card, t.channel))
            update_volume(t.wibox, t.header)
          end),
          awful.button ({}, 4, function()
            spawn_with_shell(string.format("amixer %s set %s %s+", 
                t.card, t.channel, t.step))
            update_volume(t.wibox, t.header)
          end),
          awful.button ({}, 5, function()
            spawn_with_shell(string.format("amixer %s set %s %s-", 
                t.card, t.channel, t.step))
            update_volume(t.wibox, t.header)
        end)
    ))
end

function update_volume(widget, header)
    if header == "MC12:" then 
       fd = io.popen("amixer get "..mc12_card.." PCM")
    else
       fd = io.popen("amixer sget Master")
    end
    local status = fd:read("*all")
    fd:close()
 
    --debuginfo(status)
   local volume = string.match(status, "(%d?%d?%d)%%")
   volume_num = string.format("% 3d", volume)
 
   status = string.match(status, "%[(o[^%]]*)%]")

   if string.find(status, "on", 1, true) then
       -- For the volume numbers
       volume =header.."<span foreground='#7493d2'>"..volume_num.."% </span>"
   else
       -- For the mute button
       --
       volume =header.." <span foreground='#7493d2'> M </span>"
       
   end
   widget:set_markup(volume)
end
 
update_volume(vol, 'Vol:')
update_volume(mc12, 'MC12:')

local mytimer = timer({ timeout = 5.0 })
mytimer:connect_signal("timeout", function () 
    update_volume(vol, 'Vol:')
    update_volume(mc12, 'MC12:')
end)

mytimer:start()


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytasklist = {}

taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function (t) t:view_only() end),
                    awful.button({ modkey }, 1, function (t) 
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )
tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      c:tags()[1]:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- {{{ Tags



--}}}


-- new screen function
awful.screen.connect_for_each_screen(function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- We need one layoutbox per screen.

    -- Define a tag table which hold all screen tags.

    tags = {
       names  = { " 1 "," 2 "," 3 "," 4 "," 5 ", " 6 "," 7 "," 8:vbox"," 9:www" },
       layout = { layouts[15], layouts[2], layouts[2], layouts[2], layouts[2],
                  layouts[2], layouts[2], layouts[2], layouts[1] }
    }

    awful.tag(tags.names,s,tags.layout)

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           --awful.button({ }, 1, function () awful.layout.inc(1, mouse.screen, layouts) end),
    awful.button({}, 1, function () mylayoutmenu:show({keygrabber=true}) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1, mouse.screen, layouts) end),
                           awful.button({ }, 4, function () awful.layout.inc(1, mouse.screen, layouts) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1, mouse.screen, layouts) end)))
    -- Create a taglist widget
    -- maybe like eminent
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Setup top wibox
    s.mywibox:setup {  
        layout = wibox.layout.align.horizontal,
        { -- left wiboxs
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox
    
        },
        s.mytasklist, -- Middle widget
        { -- right wiboxs
            layout = wibox.layout.fixed.horizontal,
            s.index == 1 and wibox.widget.systray(),
            mypomo_img,
            mypomo_container,
            s.index == 1 and mails.Gmail.wibox,
            s.index == 1 and mails.Durham.wibox or mails.AIP.wibox,
            s.index == 1 and vol or mc12,
            mytextclock,
            s.mylayoutbox
        },
    
    }

end)

    --if s == 2 then
        ----if type(mails[Icloud]) ~= nil then
            ----right_layout:add(mails.Icloud.wibox)
        ----end
        --right_layout:add(mails.AIP.wibox)
    --end

    --right_layout:add(vol)
    --right_layout:add(mc12)
    --right_layout:add(mytextclock)
    --right_layout:add(mylayoutbox[s])


main = {wibox = vol,
    mixer = "xterm -e alsamixer",
    header = 'Vol:',
     card = "-c 0",
  channel = "Master",
     step = "5%" }


function vol_up(cin)
    debuginfo('up')
    spawn_with_shell(string.format("amixer %s set %s %s+", 
        cin.card, cin.channel, cin.step))
    update_volume(cin.wibox, cin.header)
end


--}}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev),
    awful.button({ }, 10, function ()
        debuginfo('Volume up')
        spawn_with_shell(string.format("amixer %s set %s %s-", 
            main.card, main.channel, main.step))
        update_volume(main.wibox, main.header)
    end),
    awful.button({ }, 11, function ()
        debuginfo('Volume down')
        spawn_with_shell(string.format("amixer %s set %s %s-", 
            main.card, main.channel, main.step))
        update_volume(main.wibox, main.header)
    end)
))

-- }}}

-- {{{ Key bindings
--
globalkeys = awful.util.table.join(
    awful.key({}, "Print", function ()
        local conky = get_conky()
        if conky then 
            for k,c in  pairs(conky) do
                if c.hidden then
                    c.ontop = true
                    c.hidden = false
                else
                    c.ontop = false
                    c.hidden = true
                end
            end
        else
            naughty.notify({text="no conky"})
        end
    end),
    awful.key({modkey, "Shift"}, "s", hotkeys_popup.show_help,
             {description = "show help of keys", group="awesome"}),
    awful.key({ modkey, }, "Left",   awful.tag.viewprev,
             {description = "view previous", group = "tag"}),
    awful.key({ modkey, }, "Right",  awful.tag.viewnext,
             {description = "view next", group = "tag"}),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
             {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "a", function() 
                        revelation({rule={class="conky-semi"}, is_excluded=true}) end,
             {description = "revelation", group = "app"}),

    awful.key({            }, "F12", function () spawn_with_shell("wacom_led_switch") end,
             {description = "Change Wacom led", group = "app"}),

    awful.key({ modkey }, "`",
        function () drop(terminal,'top','center',0.7,0.7, true)  end,
             {description = "Drop Terminal", group = "app"}),

    awful.key({modkey, }, "e", 
         function () revelation({rule={class="conky-semi"}, is_excluded=true, curr_tag_only=true}) end,
             {description = "revelation of current tag", group = "app"}),

    awful.key({modkey, }, "Next", function ()
        debuginfo('Volume down')
        spawn_with_shell(string.format("amixer %s set %s %s-", 
            main.card, main.channel, main.step))
        update_volume(main.wibox, main.header)
    end,
             {description = "Volume down", group = "app"}),

    awful.key({modkey, }, "Prior", function ()
        debuginfo('Volume up')
        spawn_with_shell(string.format("amixer %s set %s %s+", 
            main.card, main.channel, main.step))
        update_volume(main.wibox, main.header)
    end,
             {description = "Volume up", group = "app"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.bydirection('down')
            if client.focus then client.focus:raise() end
        end,
             {description = "Move focus down", group = "client"}),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.bydirection('up')
            if client.focus then client.focus:raise() end
        end,
             {description = "Move focus up", group = "client"}),

    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.bydirection('right')
            if client.focus then client.focus:raise() end
        end,
             {description = "Move focus right", group = "client"}),

    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.bydirection('left')
            if client.focus then client.focus:raise() end
        end,
             {description = "Move focus left", group = "client"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end,
             {description = "Show menu", group = "awesome"}),

    -- Layout manipulation
    -- client move and resize
    awful.key({ modkey, "Shift"   }, "j", function () 
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                c:moveresize(0,-20,0,0)
            end 
        end,
             {description = "move client up, except treetile", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () 
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                c:moveresize(0, 20,0,0)  
            end 
        end, 
             {description = "move client down, except treetile", group = "client"}),

    awful.key({ modkey, "Shift"   }, "h", function ()
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                c:moveresize(-20,0,0,0) 
            else
                treetile.resize_client(-0.1)
            end 
        end,
             {description = "move client left, for treetile resize", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function () 
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                c:moveresize(20,0,0,0) 
            else
                treetile.resize_client(0.1)
            end 
        end,
             {description = "move client right, for treetile resize", group = "client"}),

    awful.key({modkey,}, "s", function ()  spawn_with_shell("dmenu_apps.sh") end,
             {description = "dmenu choose menu", group = "app"}),

    awful.key({modkey, "Control"}, "s", function() awful.client.swap.bydirection('left') 
             end,
             {description = "swap client", group = "client"}),

    awful.key({ modkey, "Control"   }, "h", function ()
        local llayout=awful.layout.get(mouse.screen)
        if llayout  == layouts[2] then
            awful.tag.incmwfact(-0.1)
        else
            awful.client.moveresize(0,0,-20,0) 
        end
       end),

    awful.key({ modkey, "Control"   }, "l", function () 
        local llayout  = awful.layout.get(mouse.screen)
        if llayout == layouts[2] then
            awful.tag.incmwfact(0.1)
        else
            awful.client.moveresize(0,0,20,0)  
        end
         end),

    awful.key({ modkey, "Control"   }, "j", function () awful.client.moveresize(0,0,0,20)    end),
    awful.key({ modkey, "Control"   }, "k", function () awful.client.moveresize(0,0,0,-20)    end),
    -- no two screen yet  --gq
    --  no I have two screen
    --
    awful.key({ modkey,  }, "[", function() awful.screen.focus_relative(-1)
                               end),
    awful.key({ modkey,  }, "]", function() awful.screen.focus_relative(1) end),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful_spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    --confict with gq naviate among cliens
    --awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    --awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    --awful.key({ modkey,           }, "space", 
        --function () awful.layout.inc(1, mouse.screen, layouts)
            --local layout = awful.layout.get(mouse.screen)
            --local name = awful.layout.getname(layout)
            --naughty.notify({text = '<span font_desc="Monaco 10">'..name..'</span>',
                            --title = "current layout:", timeout=8,
                           --screen=mouse.screen})
        --end),
    --awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1, mouse.screen, layouts)
            --local layout = awful.layout.get(mouse.screen)
            --local name = awful.layout.getname(layout)
            --naughty.notify({text = '<span font_desc="Monaco 10">'..name..'</span>',
                            --title = "current layout:", timeout=8,
                           --screen=mouse.screen})
    --end),
    --
    awful.key({ modkey, "Shift"   }, "space", function () mylayoutmenu:show({keygrabber=true}) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function ()
        local s = 
        spawn_with_shell("dmenu_run -i -p 'Run command:' -nb '" .. 
                beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
                "' -fn Monaco-9:normal'"..
                "' -sb '" .. beautiful.bg_focus .. 
                "' -sf '" .. beautiful.fg_focus .. "'") 
        end),
    --usefuleval, nil,
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  usefuleval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    awful.key({ modkey }, "p", function() awful.client.focus.history.previous() end),

    awful.key({modkey,   }, "c", function ()
        awful.prompt.run({  text = val and tostring(val),
            selectall = true,
            fg_cursor = "black",bg_cursor = "orange",
            prompt = "<span color='#ffffff'>Calc:</span> " }, mypromptbox[mouse.screen].widget,
            function(expr)
	       awful.util.eval("val="..expr)
	     cal_nau=naughty.notify({ text = expr .. ' = <span color="white">' .. val .. "</span>",
			       timeout = 30,
			       run = function() io.popen("echo -n ".. val .. " | xsel -i"):close()
			       naughty.destroy(cal_nau) 
			   end, })
	   end,
	   nil, awful.util.getdir("cache") .. "/calc")
	end),

    awful.key({ modkey,  }, "d", function ()
        local f = io.popen("xsel -o")
        local new_word = f:read("*a")
        f:close()

        if frame ~= nil then
            naughty.destroy(frame)
            frame = nil
            if old_word == new_word  then
                return
            end
        end

        old_word = new_word

        local fc = ""
        local f = io.popen("sdcv -n --utf8-output -u '牛津现代英汉双解词典' "..new_word.." | fold -s")

        for line in f:lines() do
            fc = fc..line..'\n'
        end

        f:close()
	--frame=naughty.notify({ text = fc, 
            --timeout = 30, width = 400})
        frame=naughty.notify({ text = '<span font_desc="San Francisco Text 9" color="white">'..fc..'</span>', 
            timeout = 30, width = 500})
    end),

    awful.key({modkey, "Shift"}, "d", function()
        info = true
        awful.prompt.run({ fg_cursor = "black",bg_cursor="orange",
	prompt = "<span color='#008DFA'>Dict:</span> "} , 
        mypromptbox[mouse.screen].widget,
        function(word)
                local f = io.popen("dict -d wn " .. word .. " 2>&1")
                local fr = ""
                for line in f:lines() do
                fr = fr .. line .. '\n'
	end
	f:close()
	naughty.notify({ text = '<span font_desc="San Francisco Text 9">'..fr..'</span>', timeout = 30, width = 400
        })
        end,
        nil, awful.util.getdir("cache") .. "/dict") 
      end),
    awful.key({modkey, "Shift"}, "t", clip_translate)
)

-- obsolete
--awful.key({ modkey, "Shift"   }, "r",      function (c) c:refresh()                       end),

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "f",      awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster(mouse.screen)) end),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]

                        if tag then
                            tag:view_only()
                        end
                    end,
                    {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag.
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


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c.opacity=1; c:raise(); end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
-- add keychains 
--
-- {{{ keychains configuration

--root.keys(globalkeys)
keychains.init(globalkeys)

keychains.add({modkey, "Shift"},"w","Web pages","/usr/share/icons/hicolor/16x16/apps/chromium.png",{

        b   =   {
            func    =   function()
                open_url("http://www.bricklink.com")
            end,
            info    =   "bricklink.com"
        },
        p   =   {
            func    =   function()
                open_url("http://awesome.naquadah.org/doc/api/")
            end,
            info    =   "awesome - api page"
        },
        a   =   {
            func    =   function()
                open_url("http://awesome.naquadah.org/")
            end,
            info    =   "awesome web page"
        },
        w   =   {
            func    =   function()
                open_url("http://awesome.naquadah.org/wiki/Main_Page")
            end,
            info    =   "awesome wiki"
        },
        u   =   {
            func    =   function()
                open_url("https://aur.archlinux.org/")
            end,
            info    =   "Arch aur"
        },
        k   =   {
            func    =   function()
                open_url("https://www.archlinux.org/packages/")
            end,
            info    =   "Arch packages"
        },
        t   =   {
            func = function()
                open_url("http://translate.google.com/")
            end,
            info    =   "Google translation"
        },

        f   =   {
            func = function()
                open_url("http://www.forvo.com/")
            end,
            info    =   "Forvo"
        }
    })

keychains.add({modkey, "Shift"},"p","Pomodoro", "/home/dccf87/.config/awesome/pomodoro.png",{
        b   =   {
            func    =   function()
                spawn_with_shell("mypomo &")
            end,
            info    =   "Pomodoro - start"
        },
        c   =   {
            func    =   function()
                spawn_with_shell("pkill mypomo && mypomo -c")
            end,
            info    =   "Pomodoro - cancel"
        },
    })

keychains.add({modkey, "Shift"},"u","Utils", "/usr/share/icons/hicolor/16x16/apps/blender.png",{
        c   =   {
            func    =   function()
                spawn_with_shell("restart_conky.sh &")
            end,
            info    =   "Restart conky"
        },

        w = {
            func = function()
                yawn.show(18)
            end,
            info = "Weather"
        },

        s = {
            func = function()
                local f = io.popen("xsel -o")
                local new_word = f:read("*a")
                f:close()
                spawn_with_shell("ff "..'"'..new_word..'"')
            end,
            info = "Search selected web"
            }
    })

keychains.add({modkey, }, "z", "Switch to Tag", "/usr/share/icons/hicolor/16x16/apps/blender.png", {
    q   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            tags[mouse.screen][1]:view_only()
        end,
        info    =   "Next screen tag - 1"
    },

    w   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            tags[mouse.screen][2]:view_only()
        end,
        info    =   "Next screen tag - 2"
    },

    e   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][3])
        end,
        info    =   "Next screen tag - 3"
    },

    r   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][4])
        end,
        info    =   "Next screen tag - 4"
    },

    t   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][5])
        end,
        info    =   "Next screen tag - 5"
    },

    y   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][6])
        end,
        info    =   "Next screen tag - 6"
    },
    u   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][7])
        end,
        info    =   "Next screen tag - 7"
    },
    i   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][8])
        end,
        info    =   "Next screen tag - 8"
    },
    o   =   {
        func    =   function()
            awful.screen.focus_relative(1)
            awful.tag.viewonly(tags[mouse.screen][9])
        end,
        info    =   "Next screen tag - 9"
    },
})

--no need because that the keychinas.init will do it
--root.keys(globalkeys)

local function layout_key_table()
    local key_table = {}
    local sub_layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    awful.layout.suit.magnifier,
    lain.layout.termfair,
    lain.layout.centerfair,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    treetile}
    for i,_ in ipairs(sub_layouts) do

        local name = awful.layout.getname(sub_layouts[i])
        key_table[tostring(i)] = { func = function () awful.layout.set(sub_layouts[i]) end,
                        info = 'Change layout to '..name}
    end
    return key_table
end

keychains.add({modkey, },"space","Change layout", "/usr/share/icons/hicolor/16x16/apps/blender.png", layout_key_table())


keychains.add({modkey, },"\\","treetile", "/usr/share/icons/hicolor/16x16/apps/blender.png",{
        s   =   {
            func    =  treetile.horizontal,
            info    =   "split by vertical line (|) "
        },

        v = {
            func    =   treetile.vertical,
            info    =   "split by horizonal line (-)"
        },
    })

keychains.start(15)

-- }}}

-- {{{ Rules
--
--

awful.rules.rules = {
    -- All clients will match this rule.
      --properties = { border_width = beautiful.border_width,

    {rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }},

    {rule_any = {
        class = {
            "MPlayer",
            "sun-awt-X11-XFramePeer",
            "pinetry",
            "Gimp",
            "jetbrains-pycharm",
            "xpad",
            "Display",
            "XVroot",
            "Wine"},

      properties = { 
          floating = true },
     }},
    
     { rule = { class = "Firefox" },
       properties = {maximized_horizontal=false,maximized_vertical=false,floating=true},
       callback= function(c) c:move_to_tag(c.screen.tags[9]) 
            c.screen.tags[9]:view_only()
       end},


    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    { rule_any = {
        type = {"dialog" },
        name = { 
            "Figure", 
            "IDL",
            "Gnuplot",
            "Choose a filename",}
      }, 
      properties = { maximized_horizontal=false,maximized_vertical=false,
        floating=true,
        focus=true },
      callback=function(c) add_titlebar(c) end,
    },


    --{ rule = { type = "dialog"}, properties={border_width = 0}},

    --{ rule = { class = "VirtualBox" },properties={}, callback=function(c) awful.client.movetotag(tags[mouse.screen][8],c)
      --end},
    --{ rule = { name = "Windows7" },properties={maximized_horizontal=true,maximized_vertical=true}, callback=function(c) awful.client.movetotag(tags[mouse.screen][8],c)
      --end},
    --{ rule = { name = "Windows8" },properties={maximized_horizontal=true,maximized_vertical=true},callback=function(c) awful.client.movetotag(tags[mouse.screen][8],c)
      --end},

     { rule = { class = "Tilda" },
       properties = {maximized_horizontal=false,maximized_vertical=false,floating=true},
    },

     { rule = { name = "Guake!" },
       properties = {maximized_horizontal=false,maximized_vertical=false,floating=true},
    },

     { rule = { name = "Guake" },
       properties = {maximized_horizontal=false,maximized_vertical=false,floating=true},
    },
     { rule = { class = "Gvim" },
       properties = {size_hints_honor=false, border_width=0},
    },
    { rule = { class = "conky-semi" },
       properties = {floating=true,
                     sticky = true,
                     ontop = false,
                     focusable = false,
                     hidden = true,
                     --size_hints = {"program_position", "program_size"}
                     },
    },
     { rule = { name = "gqpc" },
       properties = {maximized_horizontal=false,maximized_vertical=false,floating=true},
    },

     { rule = { class = "Synapse" },
       properties = {border_width = 0},
    },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if awful.layout.get(c.screen) == awful.layout.suit.floating then
        c.floating = true
    end

    if not startup  then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
         if awful.layout.get(c.screen).name ~= "treetile" then
             awful.client.setslave(c)
         end

        -- Put windows in a smart way, only if they does not set an initial position.
        --awful.placement.no_overlap(c)
        --awful.placement.no_offscreen(c)
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false 
    --local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        add_titlebar(c)
    end 
end)
--}}}

--{{{ mail updater
local mail_timer = timer({timeout = 30.0})
mail_timer:connect_signal("timeout", function()
    for k,t in pairs(mails) do 
        local fg = io.open(t.file)
        local l = nil
        if fg~= nil then 
            l = fg:read("*l")
            if l == nil or tonumber(l) == 0 then
                l = t.id..":<span> <b> 0 </b> </span>"
                t.cnt=0
            else
                if tonumber(l) > t.cnt then
                    tosay = "you got "..tostring(tonumber(l)-t.cnt)..t.id
                    --os.execute("esp "..tosay.." &")
                end
                t.cnt=tonumber(l)
                l = t.id..":<span color='red'> <b> "..l.." </b> </span>"
            end
        else
            l = t.id.." ? "
            t.cnt=0
        end
        fg:close()

        t.wibox:set_markup(l)
        --if k ~= 'AIP' then 
        spawn_with_shell("unread.py "..mailconf.." "..t.id.." > "..t.file .. " &")
        spawn_with_shell("echo 'collectgarbage('collect')' | awesome-client")
        --end
    end
end)

if mail_timer.started then
    mail_timer:stop()
else
    mail_timer:start()
end
--
----}}}

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--client.add_signal("focus", function(c) c.border_color = beautiful.border_focus
   --c.opacity=1 
   --end)
--client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal 
    --c.opacity=0.9
--end)

--awful.spawn("/home/dccf87/.scripts/get_dbus.sh")
--awful.spawn("tilda &")
--awful.spawn("udiskie &")


-- }}}
--
--{{{ Additonal functions


function open_url(url)
    spawn_with_shell("ffurl "..url)
end

function run_once(prg,arg_string,pname)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " &)")
    else
        spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. " &)")
    end
end

function get_conky()
    local clients = client.get()
    local conky = {}
    local i = 1
    for key, c in pairs(clients) do
        if c.class == "conky-semi" then
            conky[i] = c
            i = i + 1
        end
    end
    return conky
end

function get_client(s)
    local clients = client.get()
    local mc = nil
    local i = 1
    while clients[i]
    do
        if clients[i].class == s
        then
            mc = clients[i]
        end
        i = i + 1
    end
    return mc
end

function raise_conky()
    local conky = get_conky()
    if conky
    then
        conky.ontop = true
    end
end

function lower_conky()
    local conky = get_conky()
    if conky
    then
        conky.ontop = false
    end
end

--}}}
--
function add_titlebar(c) --{{{
    --local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(awful.titlebar.widget.iconwidget(c))

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    ---- The title goes in the middle
    --local title = awful.titlebar.widget.titlewidget(c)
    --title:buttons(awful.util.table.join(
            --awful.button({ }, 1, function()
                --client.focus = c
                --c:raise()
                --awful.mouse.client.move(c)
            --end),
            --awful.button({ }, 3, function()
                --client.focus = c
                --c:raise()
                --awful.mouse.client.resize(c)
            --end)
            --))

    ---- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    --layout:set_left(left_layout)
    layout:set_right(right_layout)
    --layout:set_middle(title)

    awful.titlebar(c):set_widget(layout)
    awful.titlebar.show(c)
end

--}}}

 --{{{Auto Spawn
--spawn_with_shell("/home/dccf87/.scripts/get_dbus.sh")
spawn_with_shell("/home/dccf87/bin/setcolor")

-- replaced by systemd
run_once("fcitx")
run_once("clipit")
run_once("synapse")

-- }}}

function usefuleval(s)--{{{
        local f, err = load("return "..s);
        ----local _ENV=_G
        if not f then
                f, err = load(s);
        end
        
        if f then
                --setfenv(f, _G);
                local ret = { pcall(f) };
                if ret[1] then
                        -- Ok
                        table.remove(ret, 1)
                        local highest_index = #ret;
                        for k, v in pairs(ret) do
                                if type(k) == "number" and k > highest_index then
                                        highest_index = k;
                                end
                                ret[k] = select(2, pcall(tostring, ret[k])) or "<no value>";
                        end
                        -- Fill in the gaps
                        for i = 1, highest_index do
                                if not ret[i] then
                                        ret[i] = "nil"
                                end
                        end
                        if highest_index > 0 then
                                --mypromptbox[mouse.screen].text = awful.util.escape("Result"..(highest_index > 1 and "s" or "")..": "..tostring(table.concat(ret, ", ")));
                                naughty.notify({ text=awful.util.escape("Result"..(highest_index > 1 and "s" or "")..": "..tostring(table.concat(ret, ", ")))
                                , screen = mouse.screen });
                        else
                                --mypromptbox[mouse.screen].text = "Result: Nothing";
                                naughty.notify({ text="Result: Nothing" , screen = mouse.screen });
                        end
                else
                        err = ret[2];
                end
        end
        if err then
                naughty.notify({ text=awful.util.escape("Error: "..tostring(err)) , screen = mouse.screen });
                --mypromptbox[mouse.screen].text = awful.util.escape("Error: "..tostring(err));
        end
end--}}}

-- {{{ Roatating wallpapers
local wrotator = require("wrotator")

homedir = os.getenv("HOME")
wp_timeout  = 600
wp_path = homedir.."/.config/wallpapers/"
wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end

wrotator({path=wp_path, filter=wp_filter, timeout = wp_timeout})

if wrotator.wp_timer.started then
  wrotator.wp_timer:stop()
else
  wrotator.wp_timer:start()
end

 
-- }}}


function test_match()
    local clientlist = awful.client.visible()
    for i,thisclient in pairs(clientlist) do 
        --x = awful.rules.match
        x = awful.rules.match(thisclient, {class="Firefox"}, true)
        debuginfo(tostring(x))
    end
end

