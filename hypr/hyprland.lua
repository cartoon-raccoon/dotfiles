-- cartoon-raccoon's Hyprland config.
-- figlet fonts:
--  header: roman
--  subheader: fender

require("os")
require("io")
require("string")

env = require("env")
col = require("colors")

--                           .                              .            
--                         .o8                            .o8            
--  .ooooo.  oooo  oooo  .o888oo oo.ooooo.  oooo  oooo  .o888oo  .oooo.o 
-- d88' `88b `888  `888    888    888' `88b `888  `888    888   d88(  "8 
-- 888   888  888   888    888    888   888  888   888    888   `"Y88b.  
-- 888   888  888   888    888 .  888   888  888   888    888 . o.  )88b 
-- `Y8bod8P'  `V88V"V8P'   "888"  888bod8P'  `V88V"V8P'   "888" 8""888P' 
--                                888                                    
--                               o888o                                   

if env.on_desktop() then
    hl.monitor({
        output = "DP-1",
        mode = "3840x2160@160",
        scale = 1.5,
        position = "0x0",
        vrr = 1
    })
end

if env.on_laptop() then
end

--                                 o8o             .o8       oooo            
--                                 `"'            "888       `888            
-- oooo    ooo  .oooo.   oooo d8b oooo   .oooo.    888oooo.   888   .ooooo.   .oooo.o 
--  `88.  .8'  `P  )88b  `888""8P `888  `P  )88b   d88' `88b  888  d88' `88b d88(  "8 
--   `88..8'    .oP"888   888      888   .oP"888   888   888  888  888ooo888 `"Y88b.  
--    `888'    d8(  888   888      888  d8(  888   888   888  888  888    .o o.  )88b 
--     `8'     `Y888""8o d888b    o888o `Y888""8o  `Y8bod8P' o888o `Y8bod8P' 8""888P' 

-- General configuration settings.

hl.config({
    --                                              '||` 
    --                                               ||  
    -- .|''|, .|''|, `||''|,  .|''|, '||''|  '''|.   ||  
    -- ||  || ||..||  ||  ||  ||..||  ||    .|''||   ||  
    -- `|..|| `|...  .||  ||. `|...  .||.   `|..||. .||. 
    --     ||                                            
    --  `..|'                                            
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = col.borders.active:as_hl(),
            inactive_border = col.borders.inactive:as_hl(),
            nogroup_border_active = col.borders.nogroup.active:as_hl(),
            nogroup_border = col.borders.nogroup.inactive:as_hl(),
        },

        layout = "scrolling",

        allow_tearing = false
    },
    -- '||`                                    ||
    --  ||                                     ||
    --  ||   '''|.  '||  ||` .|''|, '||  ||` ''||'' 
    --  ||  .|''||   `|..||  ||  ||  ||  ||    ||   
    -- .||. `|..||.      ||  `|..|'  `|..'|.   `|..'
    --                ,  |'
    --                 ''                                  
    scrolling = {
        fullscreen_on_one_column = false,
        column_width = 1.0,
        explicit_column_widths = "0.5, 0.666667, 0.75, 1.0",
        focus_fit_method = 0,
        follow_focus = true,
        follow_min_visible = 0.5,
        wrap_focus = false,
        wrap_swapcol = false,
    },
    master = {
        new_on_top = true,
        mfact = 0.5,
        new_status = "slave",
        orientation = "left",
        slave_count_for_center_master = 2,
    },
    dwindle = {
        preserve_split = true
    },
    -- .|''|, '||''| .|''|, '||  ||` '||''|, 
    -- ||  ||  ||    ||  ||  ||  ||   ||  || 
    -- `|..|| .||.   `|..|'  `|..'|.  ||..|' 
    --     ||                         ||     
    --  `..|'                        .||     
    group = {
        insert_after_current = true,
        auto_group = false,
        drag_into_group = 1,
        merge_groups_on_drag = true,
        merge_floated_into_tiled_on_groupbar = true,

        col = {
            border_active = col.group.active:as_hl(),
            border_inactive = col.group.inactive:as_hl(),
            border_locked_active = col.group.locked.active:as_hl(),
            border_locked_inactive = col.group.locked.inactive:as_hl(),
        },

        groupbar = {
            font_size = 12,
            height = 18,
            col = {
                active = col.group.groupbar.active:as_hl(),
                inactive = col.group.groupbar.inactive:as_hl(),
            }
        }
    },
    --     ||`                            
    --     ||                             
    -- .|''||  .|''|, .|'', .|''|, '||''| 
    -- ||  ||  ||..|| ||    ||  ||  ||    
    -- `|..||. `|...  `|..' `|..|' .||.   
    decoration = {
        rounding = 5,
        dim_modal = true,
        dim_inactive = true,
        dim_strength = 0.1,

        blur = {
            enabled = true,
            size = 3,
            passes = 1
        },

        motion_blur = {
            enabled = false,
        }
    },
    input = {
        follow_mouse = true,
        mouse_refocus = true,

        touchpad = {
            natural_scroll = true,
        }
    },
    binds = {
        -- when moving to the currently focused workspace, go to the previous one instead
        workspace_back_and_forth = true,
        -- allow movefocus to work even when fullscreeened
        movefocus_cycles_fullscreen = true,

        window_direction_monitor_fallback = false,
        allow_pin_fullscreen = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
        enforce_permissions = false,
    },
    --             ''              
    -- '||),,(|,   ||  ('''' .|'', 
    --  || || ||   ||   `'') ||    
    -- .||    ||. .||. `...' `|..' 
    misc = {
        disable_hyprland_logo = true,
        font_family = "FontAwesome",
        force_default_wallpaper = false,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        enable_swallow = true,
        swallow_regex = "^(Alacritty)$",
        swallow_exception_regex = "(wev.*)|(zenity.*)|(hyprsysteminfo.*)",
        disable_autoreload = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    plugin = {
        scrolloverview = {
            gesture_distance = 300, -- how far is the "max" for the gesture
            scale = 0.5, -- preferred overview scale
            cross_monitor_drag = true, -- enable cross-monitor dragging and Hyprland adoption
            workspace_gap = 100,
            layout = "vertical", -- vertical, horizontal, or auto (per-monitor orientation)
            wallpaper = 2, -- 0: global only, 1: per-workspace only, 2: both
            blur = true, -- blur only the main overview wallpaper

            shadow = {
                enabled = true,
                range = 50,
            },
        },
    },
})

--                        o8o                             
--                        `"'                             
--  .oooo.   ooo. .oo.   oooo  ooo. .oo.  .oo.    .oooo.o 
-- `P  )88b  `888P"Y88b  `888  `888P"Y88bP"Y88b  d88(  "8 
--  .oP"888   888   888   888   888   888   888  `"Y88b.  
-- d8(  888   888   888   888   888   888   888  o.  )88b 
-- `Y888""8o o888o o888o o888o o888o o888o o888o 8""888P'

hl.curve("easeOutCubic",   { type = "bezier", points = {{ 0.33, 1 }, { 0.68, 1 }}})
hl.curve("easeInOutCubic", { type = "bezier", points = {{ 0.65, 0 }, { 0.35, 1 }}})
hl.curve("easeOutQuart",   { type = "bezier", points = {{ 0.25, 1 }, { 0.50, 1 }}})
hl.curve("easeInOutQuart", { type = "bezier", points = {{ 0.76, 0 }, { 0.24, 1 }}})
hl.curve("easeOutQuint",   { type = "bezier", points = {{ 0.22, 1 }, { 0.36, 1 }}})
hl.curve("easeInOutQuint", { type = "bezier", points = {{ 0.83, 0 }, { 0.17, 1 }}})
hl.curve("easeOutExpo",    { type = "bezier", points = {{ 0.16, 1 }, { 0.30, 1 }}})
hl.curve("easeInOutExpo",  { type = "bezier", points = {{ 0.87, 1 }, { 0.13, 1 }}})

hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 5,
    curve = "default",
    bezier = "easeOutExpo",
    style = "popin"
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    curve = "default",
    bezier = "easeOutExpo",
    style = "slidevert"
})

-- todo: animations

--  o8o                                                      .            
--  `"'                                                    .o8            
-- oooo  ooo. .oo.  .oo.   oo.ooooo.   .ooooo.  oooo d8b .o888oo  .oooo.o 
-- `888  `888P"Y88bP"Y88b   888' `88b d88' `88b `888""8P   888   d88(  "8 
--  888   888   888   888   888   888 888   888  888       888   `"Y88b.  
--  888   888   888   888   888   888 888   888  888       888 . o.  )88b 
-- o888o o888o o888o o888o  888bod8P' `Y8bod8P' d888b      "888" 8""888P' 
--                          888                                           
--                         o888o                                          

-- import workspace functionality
ws = require("workspaces")
-- import window rules
wr = require("winrules")
-- import key bindings
kb = require("keybinds")
-- import duckypad hooks
dp = require("duckypad")

--  .ooooo.  oooo    ooo  .ooooo.   .ooooo.   .oooo.o 
-- d88' `88b  `88b..8P'  d88' `88b d88' `"Y8 d88(  "8 
-- 888ooo888    Y888'    888ooo888 888       `"Y88b.  
-- 888    .o  .o8"'88b   888    .o 888   .o8 o.  )88b 
-- `Y8bod8P' o88'   888o `Y8bod8P' `Y8bod8P' 8""888P' 

--- Starts the shell program(s).
function start_shell()
    if not env.using_noctalia then
        hl.exec_cmd(env.systemctl("hyprpolkitagent"))
        hl.exec_cmd(env.systemctl("start-waybar"))
        hl.exec_cmd(env.systemctl("swaync"))
        -- swayosd
        -- awww
        -- hyprlock
        -- hypridle
        -- snappy-switcher
        -- vicinae
    else
        hl.exec_cmd(env.systemctl("noctalia"))
    end
end

hl.on("hyprland.start", function()
    start_shell()

    -- Sync the duckyPad's real time clock.
    dp.send_command("update-rtc")
    -- Set persistent global var #2 to 0, meaning window manager in use is currently Hyprland.
    dp.send_command("write-pgv", { "-i", "2=0" })

    -- Reload Hyprland plugin state
    hl.exec_cmd("hyprpm reload -n")

    hl.exec_cmd(env.uwsm("easyeffects", false))
    -- `code` forks, so this rule won't work. It is instead caught by winrules.workspace.code_on_dev.
    -- However, we leave it here as a representation of intent.
    hl.exec_cmd(env.uwsm("code", false), { workspace = ws.dev:sel_id(true) })
    hl.exec_cmd(env.uwsm("discord", false), { workspace = ws.chat:sel_id(true) })
    hl.exec_cmd(env.uwsm("spotify-launcher", true), { workspace = ws.chat:sel_id(true) })
    hl.exec_cmd(env.uwsm("zen-browser", false), { workspace = ws.main:sel_id(true) })
end)