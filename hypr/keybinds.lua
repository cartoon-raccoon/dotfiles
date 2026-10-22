-- oooo                               .o8        o8o                    .o8  
-- `888                              "888        `"'                   "888  
--  888  oooo   .ooooo.  oooo    ooo  888oooo.  oooo  ooo. .oo.    .oooo888   .oooo.o 
--  888 .8P'   d88' `88b  `88.  .8'   d88' `88b `888  `888P"Y88b  d88' `888  d88(  "8 
--  888888.    888ooo888   `88..8'    888   888  888   888   888  888   888  `"Y88b.  
--  888 `88b.  888    .o    `888'     888   888  888   888   888  888   888  o.  )88b 
-- o888o o888o `Y8bod8P'     .8'      `Y8bod8P' o888o o888o o888o `Y8bod88P" 8""888P' 
--                       .o..P'                                                       
--                       `Y8P'                                                        

local ws = require("workspaces")
local env = require("env")
local dp = require("duckypad")

local soview = hl.plugin.scrolloverview
local hy3 = hl.plugin.hy3

kb = {}

local mainmod = "SUPER"

kb.mainmod = mainmod

--- Set a bind table that maps a different bind for each layout. This lets the same keybind trigger
--- a different dispatcher depending on the current layout of the workspace.
--- @param bind_table table
--- @return function
local function per_layout(bind_table)
    return function ()
        local workspace = hl.get_active_special_workspace() or
                          hl.get_active_workspace()

        if not workspace then
            return
        end

        local layout = workspace.tiled_layout

        if bind_table[layout] then
            hl.dispatch(bind_table[layout])
        end
    end
end

--       .o8   o8o                                                       
--      "888   `"'                                                       
--  .oooo888  oooo   .oooo.o oo.ooooo.   .oooooooo  .ooooo.  ooo. .oo.   
-- d88' `888  `888  d88(  "8  888' `88b 888' `88b  d88' `88b `888P"Y88b  
-- 888   888   888  `"Y88b.   888   888 888   888  888ooo888  888   888  
-- 888   888   888  o.  )88b  888   888 `88bod8P'  888    .o  888   888  
-- `Y8bod88P" o888o 8""888P'  888bod8P' `8oooooo.  `Y8bod8P' o888o o888o 
--                            888       d"     YD                        
--                           o888o      "Y88888P'                        

--- Generate the dispatcher to toggle the launcher window.
--- If running Noctalia, calls `noctalia msg panel-toggle`.
--- Otherwise, calls Vicinae.
--- @param cmd boolean Whether to open the launcher or the command runner.
local function runlauncher(cmd)
    if env.using_noctalia then
        if cmd then
            return hl.dsp.exec_cmd("noctalia msg panel-toggle nocode-96/cmd-runner:panel")
        else
            return hl.dsp.exec_cmd("noctalia msg panel-toggle launcher")
        end
    else
        return hl.dsp.no_op() -- todo: setup vicinae
    end
end

kb.runlauncher = runlauncher

--- Generate the dispatcher to increase volume.
--- If running Noctalia, calls `noctalia msg`, otherwise calls `wpctl`.
local function volup()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg volume-up 5")
    else
        return hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_SINK@ 5%+") -- todo: integrate swayosd
    end
end

kb.volup = volup

--- Generate the dispatcher to decrease volume.
--- If running Noctalia, calls `noctalia msg`, otherwise calls `wpctl`.
local function voldn()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg volume-down 5")
    else
        return hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-")
    end
end

--- Generate the dispatcher to toggle mute.
--- If running Noctalia, calls `noctalia msg`, otherwise calls `wpctl`.
local function volmute()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg volume-mute")
    else
        return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle")
    end
end

local function mediaplaypause()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg media play-pause")
    else
        return hl.dsp.exec_cmd("playerctl play-pause")
    end
end

local function medianext()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg media next")
    else
        return hl.dsp.exec_cmd("playerctl next")
    end
end

local function mediaprev()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg media previous")
    else
        return hl.dsp.exec_cmd("playerctl previous")
    end
end

--- Generate the dispatcher to take a screenshot. The command generated depends on the mode.
--- If running Noctalia, calls `noctalia msg screenshot-*`, otherwise uses a custom `grim` script.
--- There are three modes:
--- - "window": take a screenshot of the current window.
--- - "region": interactively screenshot a selected region.
--- - "monitor": screenshot the active monitor.
--- If mode is invalid, returns a no-op dispatcher.
--- @param mode "window"|"region"|"monitor" The mode to use when generating the command.
--- @return HL.Dispatcher
local function screenshot(mode)
    if env.using_noctalia then
        if mode == "window" then
            return hl.dsp.no_op()
        elseif mode == "region" then
            return hl.dsp.exec_cmd("noctalia msg screenshot-region")
        elseif mode == "monitor" then
            return hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen pick")
        end
    else
        if mode == "window" then
            return hl.dsp.exec_cmd("~/.grim.sh -w")
        elseif mode == "region" then
            return hl.dsp.exec_cmd("~/.grim.sh -r")
        elseif mode == "monitor" then
            return hl.dsp.exec_cmd("~/.grim.sh -m")
        end
    end

    return hl.dsp.no_op()
end

--- Generate the dispatcher to activate the window switcher. The command generated depends on the mode.
local function winswitch(mode)
    if env.using_noctalia then
        if mode == "monitor" then
            return hl.dsp.exec_cmd("noctalia msg window-switcher hold")
        elseif mode == "workspace" then
            return hl.dsp.no_op()
        end
    else
        return hl.dsp.no_op() -- todo: snappy-switcher
    end

    return hl.dsp.no_op()
end

local function locksession()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg session lock")
    else
        return hl.dsp.exec_cmd("loginctl lock-session")
    end
end

local function sessionmenu()
    if env.using_noctalia then
        return hl.dsp.exec_cmd("noctalia msg panel-toggle session")
    else
        return hl.dsp.no_op() -- todo: find a session panel provider
    end
end

--                                                               oooo  
--                                                               `888  
--  .oooooooo  .ooooo.  ooo. .oo.    .ooooo.  oooo d8b  .oooo.    888  
-- 888' `88b  d88' `88b `888P"Y88b  d88' `88b `888""8P `P  )88b   888  
-- 888   888  888ooo888  888   888  888ooo888  888      .oP"888   888  
-- `88bod8P'  888    .o  888   888  888    .o  888     d8(  888   888  
-- `8oooooo.  `Y8bod8P' o888o o888o `Y8bod8P' d888b    `Y888""8o o888o 
-- d"     YD                                                           
-- "Y88888P'                                                           

--- Keybinds for controlling the terminal.
kb.term = {
    floating = hl.bind(mainmod .. " + grave",
        hl.dsp.exec_cmd(env.uwsm(env.term, true), { float = true, size = { 1100, 850 } }),
        { description = "Launch floating terminal" }
    ),
    tiled = hl.bind(mainmod .. " + SHIFT + grave",
        hl.dsp.exec_cmd(env.uwsm(env.term, true)), { description = "Launch terminal tiled" }
    )
}

--- Keybinds for controlling the launcher.
kb.launcher = {
    app = hl.bind(mainmod .. " + R", runlauncher(false), { description = "Open the launcher" }),
    cmd = hl.bind(mainmod .. " + SHIFT + R", runlauncher(true), { description = " Run a command" }),
}

--- Keybinds for media control (volume, media control, screenshot).
kb.media = {
    volume = {
        up = hl.bind("XF86AudioRaiseVolume", 
            volup(), { description = "Volume up", locked = true, submap_universal = true }
        ),
        down = hl.bind("XF86AudioLowerVolume",
            voldn(), { description = "Volume down", locked = true, submap_universal = true }
        ),
        mute = hl.bind("XF86AudioMute",
            volmute(), { description = "Toggle mute", locked = true, submap_universal = true }
        ),
    },
    playpause = hl.bind("XF86AudioPlay",
        mediaplaypause(), { description = "Media play/pause", locked = true, submap_universal = true }
    ),
    next = hl.bind("XF86AudioNext",
        medianext(), { description = "Media next", locked = true, submap_universal = true }
    ),
    prev = hl.bind("XF86AudioPrev",
        mediaprev(), { description = "Media previous", locked = true, submap_universal = true }
    ),
    screenshot = {
        region = hl.bind(
            "Print", screenshot("region"),
            { repeating = false, description = "Take a screenshot of a region", submap_universal = true }
        ),
        monitor = hl.bind(
            "SHIFT + Print", screenshot("monitor"),
            { repeating = false, description = "Take a screenshot of a whole monitor", submap_universal = true }
        )
    }
}

kb.session = {
    winswitcher = {
        alttab = hl.bind("ALT + Tab", winswitch("monitor"), { repeating = false }),
        modtab = hl.bind(mainmod .. " + Tab", winswitch("workspace"), { repeating = false })
    },
    overview = {
        open = hl.bind(mainmod .. " + O", soview.overview("toggle all")),
        mouse = hl.bind(mainmod .. " + mouse:274", soview.overview("toggle all")),
    },
    locksession = hl.bind(mainmod .. " + CTRL + L",
        locksession(), { repeating = false, description = "Lock the session" }
    ),
    sessionmenu = hl.bind("CTRL + ALT + Delete",
        sessionmenu(), { repeating = false, description = "Open the session menu", submap_universal = true }
    ),
    shutdown = hl.bind(mainmod .. " + CTRL + Q",
        hl.dsp.exec_cmd("hyprshutdown"), { repeating = false, description = "Exit Hyprland gracefully" }
    )
}

--- Keybind to reload the configuration.
kb.reload_cfg = hl.bind(mainmod .. " + CTRL + R",
    hl.dsp.exec_cmd("hyprctl reload"), { repeating = false, description = "Reload Hyprland config" }
)

kb.hyprkill = hl.bind(mainmod .. " + SHIFT + K",
    hl.dsp.exec_cmd("hyprctl kill"), { repeating = false, description = "Run hyprctl kill" }
)

--- Drag-based mouse bindings.
kb.mouse = {
    movewin = hl.bind(mainmod .. " + mouse:272", 
        hl.dsp.window.drag(), { description = "Move window interactively", mouse = true }
    ),
    resizewin = hl.bind(mainmod .. " + mouse:273",
        hl.dsp.window.resize(), { description = "Resize window interactively", mouse = true }
    ),
    resizewinratio = hl.bind(mainmod .. " + SHIFT + mouse:273",
        hl.dsp.window.resize({keep_aspect_ratio = true}),
        { description = "Resize window, keeping aspect ratio", mouse = true }
    )
}

--                  oooo                                      
--                  `888                                      
-- oooo oooo    ooo  888  oooo   .oooo.o oo.ooooo.   .ooooo.  
--  `88. `88.  .8'   888 .8P'   d88(  "8  888' `88b d88' `"Y8 
--   `88..]88..8'    888888.    `"Y88b.   888   888 888       
--    `888'`888'     888 `88b.  o.  )88b  888   888 888   .o8 
--     `8'  `8'     o888o o888o 8""888P'  888bod8P' `Y8bod8P' 
--                                        888                 
--                                       o888o                

--- Bindings for focusing between workspaces.
--- 
--- Keybind model: Mod + <workspace key> focuses workspace, Mod + ALT + <workspace_key> focuses the workspace on the
--- other monitor. Static workspaces have no corresponding ALT bind.
--- 
--- There are no bindings for moving workspaces between monitors, as that is not part of the workspace model.
kb.wkspc = {
    enter = hl.bind(mainmod .. " + Return",
        hl.dsp.focus({ workspace = ws.main:sel_id(), }), { description = "Focus on the main workspace" }
    ),
    main = hl.bind(mainmod .. " + A",
        hl.dsp.focus({ workspace = ws.main:sel_id(), }), { description = "Focus on workspace Main" }
    ),
    dev = hl.bind(mainmod .. " + S",
        hl.dsp.focus({ workspace = ws.dev:sel_id() }), { description = "Focus on workspace Dev" }
    ),
    chat = hl.bind(mainmod .. " + D",
        hl.dsp.focus({ workspace = ws.chat:sel_id() }), { description = "Focus on workspace Chat" }
    ),
    music = hl.bind(mainmod .. " + F",
        hl.dsp.focus({ workspace = ws.music:sel_id() }), { description = "Focus on workspace Music" }
    ),

    -- Mod + G and Mod + H are reserved for future static workspaces on a second monitor.

    --- Dynamic workspaces.
    dynamic = {
        currmon = {
            hl.bind(mainmod .. " + 1", ws.dsp.focus_dyn_wkspc_curr_mon(1)),
            hl.bind(mainmod .. " + 2", ws.dsp.focus_dyn_wkspc_curr_mon(2)),
            hl.bind(mainmod .. " + 3", ws.dsp.focus_dyn_wkspc_curr_mon(3)),
            hl.bind(mainmod .. " + 4", ws.dsp.focus_dyn_wkspc_curr_mon(4)),
            hl.bind(mainmod .. " + 5", ws.dsp.focus_dyn_wkspc_curr_mon(5)),
            hl.bind(mainmod .. " + 6", ws.dsp.focus_dyn_wkspc_curr_mon(6)),
            hl.bind(mainmod .. " + 7", ws.dsp.focus_dyn_wkspc_curr_mon(7)),
            hl.bind(mainmod .. " + 8", ws.dsp.focus_dyn_wkspc_curr_mon(8)),
            hl.bind(mainmod .. " + 9", ws.dsp.focus_dyn_wkspc_curr_mon(9)),
        },
        othermon = {
            -- fixme: once I get a second monitor
            -- Mod + ALT + 1-9: focus to dynamic workspace on other monitor
        }
    },
    avail = hl.bind(mainmod .. " + 0", function()
        -- get the first available dynamic workspace or the first dynamic on current monitor
        local first = ws.first_empty_dyn_wkspc() or Workspace.currdyn(1)
        local active = hl.get_active_workspace()
        if active == nil then
            return -- fixme
        end
        if tonumber(first.id) == active.id then
            hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = first:sel_id() }))
        end
    end),
    prev = hl.bind(mainmod .. " + Backspace",
        hl.dsp.focus({ workspace = "previous" }), { description = "Focus on the last visited workspace" }
    ),
    minimized = hl.bind(mainmod .. " + CTRL + X",
        hl.dsp.workspace.toggle_special(ws.specials.minimized.name),
        { description = "Toggle minimized special workspace" }
    ),
}

--                   o8o                    .o8                             
--                   `"'                   "888                             
-- oooo oooo    ooo oooo  ooo. .oo.    .oooo888   .ooooo.  oooo oooo    ooo 
--  `88. `88.  .8'  `888  `888P"Y88b  d88' `888  d88' `88b  `88. `88.  .8'  
--   `88..]88..8'    888   888   888  888   888  888   888   `88..]88..8'   
--    `888'`888'     888   888   888  888   888  888   888    `888'`888'    
--     `8'  `8'     o888o o888o o888o `Y8bod88P" `Y8bod8P'     `8'  `8'     

--- The Minimization System
--- 
--- The minimization system revolves around the "minimized" special workspace, defined in workspaces.lua.
--- There are two operations defined on this system: minimize and deminimize. "Minimize" sends the currently
--- active window to the "minimized" special workspace, and "deminimize" moves the last-minimized window out
--- of the special workspace back to the currently active workspace.
---
--- Minimized windows are disambiguated using the tag system. When a window is minimized, it is assigned a unique
--- tag of the format "minimized<x>", where `x` is its index in the minimized workspace. When "deminimize" is called,
--- it regenerates the tag from the number of windows in the special workspace, and pulls the window with that tag
--- back to the active workspace. The tag is then cleared from that window.

--- "Minimizes" a window by tagging it accordingly and sending it to the "minimized" special workspace.
local function minimize()
    local spwksp = hl.get_active_special_workspace()
    if spwksp and spwksp.name == ws.specials.minimized:sel_id() then
        -- local wksp = hl.get_active_workspace()
        -- hl.dispatch(hl.dsp.window.move({ workspace = wksp }))

        -- do nothing if we are in the minimized workspace
        hl.notification.create({
            text = "Already in special:minimized, ignoring keybind",
            timeout = 1000,
            icon = "info",
        })
        return
    end

    local minwksp = hl.get_workspace(ws.specials.minimized:sel_id())
    local tag = nil
    if minwksp then
        -- get the number of windows currently in the workspace, use that to create the tag
        local num_minimized = minwksp.windows + 1
        tag = ws.specials.minimized.name .. num_minimized
    else
        -- if there is no minimized workspace, this is the first window to be sent there
        tag = ws.specials.minimized.name .. 1
    end

    -- tag our active window
    hl.dispatch(hl.dsp.window.tag({ tag = tag, window = hl.get_active_window() }))
    -- send to the workspace
    hl.dispatch(hl.dsp.window.move({ workspace = ws.specials.minimized:sel_id(), follow = false }))
end

--- "Deminimizes" the last minimized window by moving it back to the current active workspace.
local function deminimize()
    local minwksp = hl.get_workspace(ws.specials.minimized:sel_id())
    -- if no minimized workspace, there are no minimized windows, return
    if minwksp == nil then return end

    -- get the number of windows currently in the workspace, use that to create the tag
    local num_minimized = minwksp.windows
    local tag = ws.specials.minimized.name .. num_minimized
    -- move the window with that tag to the active workspace
    hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:" .. tag }))
    -- untag the window with that tag
    hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:" .. tag }))
end

--- Window control keybinds.
kb.window = {
    close = hl.bind(mainmod .. " + Q",
        hl.dsp.window.close(), { repeating = false, description = "Close active window" }
    ),
    maximize = hl.bind(mainmod .. " + M",
        hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
        { repeating = false, description = "Toggle maximized on active window" }
    ),
    minimize = hl.bind(mainmod .. " + X", minimize,
        { repeating = false, description = "Minimize active window (send to special:minimized)" }
    ),
    deminimize = hl.bind(mainmod .. " + SHIFT + X", deminimize,
        { repeating = false, description = "Deminimize the last minimized window"}
    ),
    fullscreen = hl.bind(mainmod .. " + SHIFT + M",
        hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
        { repeating = false, description = "Toggle fullscreen on active window" }
    ),
    float = hl.bind(mainmod .. " + T",
        hl.dsp.window.float({ action = "toggle" }),
        { repeating = false,  description = "Toggle active window floating" }
    ),
    pin = hl.bind(mainmod .. " + P",
        hl.dsp.window.pin({ action = "toggle" }),
        { repeating = false, description = "Toggle active window pin" }
    ),
    deny = hl.bind(mainmod .. " + Delete", -- fixme: not working
        hl.dsp.window.deny_from_group({ action = "toggle" }),
        { repeating = false, description = "Deny active window from group" }
    ),
    move = {
        --- Move the window and focus to the new workspace.
        focus = {
            main  = hl.bind(mainmod .. " + SHIFT + A",
                hl.dsp.window.move({ workspace = ws.main:sel_id()}),
                { repeating = false, description = "Move active window to and focus on Main workspace" }
            ),
            dev   = hl.bind(mainmod .. " + SHIFT + S",
                hl.dsp.window.move({ workspace = ws.dev:sel_id()}),
                { repeating = false, description = "Move active window to and focus on Dev workspace" }
            ),
            chat  = hl.bind(mainmod .. " + SHIFT + D",
                hl.dsp.window.move({ workspace = ws.chat:sel_id()}),
                { repeating = false, description = "Move active window to and focus on Chat workspace" }
            ),
            music = hl.bind(mainmod .. " + SHIFT + F",
                hl.dsp.window.move({ workspace = ws.music:sel_id()}),
                { repeating = false, description = "Move active window to and focus on Music workspace" }
            ),
            dynamic = {
                currmon = {
                    hl.bind(mainmod .. " + SHIFT + 1", ws.dsp.move_to_dyn_wkspc_curr_mon(1, true)),
                    hl.bind(mainmod .. " + SHIFT + 2", ws.dsp.move_to_dyn_wkspc_curr_mon(2, true)),
                    hl.bind(mainmod .. " + SHIFT + 3", ws.dsp.move_to_dyn_wkspc_curr_mon(3, true)),
                    hl.bind(mainmod .. " + SHIFT + 4", ws.dsp.move_to_dyn_wkspc_curr_mon(4, true)),
                    hl.bind(mainmod .. " + SHIFT + 5", ws.dsp.move_to_dyn_wkspc_curr_mon(5, true)),
                    hl.bind(mainmod .. " + SHIFT + 6", ws.dsp.move_to_dyn_wkspc_curr_mon(6, true)),
                    hl.bind(mainmod .. " + SHIFT + 7", ws.dsp.move_to_dyn_wkspc_curr_mon(7, true)),
                    hl.bind(mainmod .. " + SHIFT + 8", ws.dsp.move_to_dyn_wkspc_curr_mon(8, true)),
                    hl.bind(mainmod .. " + SHIFT + 9", ws.dsp.move_to_dyn_wkspc_curr_mon(9, true)),
                },
                othermon = {
                    -- fixme: once I get a second monitor
                    -- Mod + SHIFT + ALT + 1-9: move active window to dynamic workspace on other monitor
                }
            },
            avail = hl.bind(mainmod .. " + SHIFT + 0", function()
                -- get the first available dynamic workspace or the first dynamic on current monitor
                local first = ws.first_empty_dyn_wkspc() or Workspace.currdyn(1)
                local active = hl.get_active_workspace()
                if active == nil then
                    return -- fixme
                end
                if tonumber(first.id) == active.id then
                    hl.dispatch(hl.dsp.window.move({ workspace = "previous" }))
                else
                    hl.dispatch(hl.dsp.window.move({ workspace = first:sel_id() }))
                end
            end),
            prev = hl.bind(mainmod .. " + SHIFT + Backspace", hl.dsp.window.move({ workspace = "previous" }))
        },
        --- Move the window without focusing to the new workspace.
        silent = {
            main  = hl.bind(mainmod .. " + CTRL + A", 
                hl.dsp.window.move({ workspace = ws.main:sel_id(), follow = false }),
                { repeating = false, description = "Move active window to Main workspace without focusing" }
            ),
            dev   = hl.bind(mainmod .. " + CTRL + S",
                hl.dsp.window.move({ workspace = ws.dev:sel_id(), follow = false }),
                { repeating = false, description = "Move active window to Dev workspace without focusing" }
            ),
            chat  = hl.bind(mainmod .. " + CTRL + D",
                hl.dsp.window.move({ workspace = ws.chat:sel_id(), follow = false }),
                { repeating = false, description = "Move active window to Chat workspace without focusing" }
            ),
            music = hl.bind(mainmod .. " + CTRL + F",
                hl.dsp.window.move({ workspace = ws.music:sel_id(), follow = false }),
                { repeating = false, description = "Move active window to Music workspace without focusing" }
            ),
            dynamic = {
                --- Move to the dynamic workspaces on the current monitor.
                currmon = {
                    hl.bind(mainmod .. " + CTRL + 1", ws.dsp.move_to_dyn_wkspc_curr_mon(1, false)),
                    hl.bind(mainmod .. " + CTRL + 2", ws.dsp.move_to_dyn_wkspc_curr_mon(2, false)),
                    hl.bind(mainmod .. " + CTRL + 3", ws.dsp.move_to_dyn_wkspc_curr_mon(3, false)),
                    hl.bind(mainmod .. " + CTRL + 4", ws.dsp.move_to_dyn_wkspc_curr_mon(4, false)),
                    hl.bind(mainmod .. " + CTRL + 5", ws.dsp.move_to_dyn_wkspc_curr_mon(5, false)),
                    hl.bind(mainmod .. " + CTRL + 6", ws.dsp.move_to_dyn_wkspc_curr_mon(6, false)),
                    hl.bind(mainmod .. " + CTRL + 7", ws.dsp.move_to_dyn_wkspc_curr_mon(7, false)),
                    hl.bind(mainmod .. " + CTRL + 8", ws.dsp.move_to_dyn_wkspc_curr_mon(8, false)),
                    hl.bind(mainmod .. " + CTRL + 9", ws.dsp.move_to_dyn_wkspc_curr_mon(9, false)),
                },
                --- Move to the dynamic workspaces on the other monitor.
                othermon = {
                    -- fixme: once I get a second monitor
                    -- Mod + CTRL + ALT + 1-9: move active window to dynamic workspace on other monitor (no focus)
                }
            },
            avail = hl.bind(mainmod .. " + CTRL + 0", function()
                -- get the first available dynamic workspace or the first dynamic on current monitor
                local first = ws.first_empty_dyn_wkspc() or Workspace.currdyn(1)
                local active = hl.get_active_workspace()
                if active == nil then
                    return -- fixme
                end
                if tonumber(first.id) == active.id then
                    hl.dispatch(hl.dsp.window.move({ workspace = "previous", follow = false }))
                else
                    hl.dispatch(hl.dsp.window.move({ workspace = first:sel_id(), follow = false }))
                end
            end),
            prev = hl.bind(mainmod .. " + CTRL + Backspace",
                hl.dsp.window.move({ workspace = "previous", follow = false })
            )
        }
    }
}

--       .o8   o8o           
--      "888   `"'           
--  .oooo888  oooo  oooo d8b 
-- d88' `888  `888  `888""8P 
-- 888   888   888   888     
-- 888   888   888   888     
-- `Y8bod88P" o888o d888b    

--- Returns a dispatcher that focuses on the layout-dependent "previous" window.
--- Note: This returns a dispatcher; it does not run the commmand itself.
local function dirprev()
    return per_layout({
        scrolling = hl.dsp.layout("focus l"),
        master = hl.dsp.window.cycle_next({ next = false, tiled = true }),
        monocle = hl.dsp.layout("cycleprev")
    })
end

--- Returns a dispatcher that focuses on the layout-dependent "next" window.
--- Note: This returns a dispatcher; it does not run the commmand itself.
local function dirnext()
    return per_layout({
        scrolling = hl.dsp.layout("focus r"),
        master = hl.dsp.window.cycle_next({ next = true, tiled = true }),
        monocle = hl.dsp.layout("cyclenext")
    })
end

--- Returns a dispatcher that moves the active window "left", depending on the layout.
--- Note: This returns a dispatcher; it does not run the commmand itself.
local function moveleft()
    return per_layout({
        scrolling = hl.dsp.layout("swapcol l"),
        master = hl.dsp.no_op() -- todo
    })
end

--- Returns a dispatcher that moves the active window "right", depending on the layout.
--- Note: This returns a dispatcher; it does not run the commmand itself.
local function moveright()
    return per_layout({
        scrolling = hl.dsp.layout("swapcol r"),
        master = hl.dsp.no_op() -- todo
    })
end

--- Focuses on the previous group member or the previous window, depending on current focus position.
--- 
--- Note: This *is* a dispatcher; it does not return one.
--- It should not be called in a binding definition.
local function focus_grp_left_or_prev()
    local win = hl.get_active_window()
    if win == nil then return end
    local group = win.group
    if group and group.current_index > 1 then
        -- if we have a group and not at the beginning, move within the group
        hl.dispatch(hl.dsp.group.prev())
    else
        -- else, move between windows
        hl.dispatch(dirprev())
    end
end

--- Focuses on the next group member or the next window, depending on current focus position.
--- 
--- Note: This *is* a dispatcher; it does not return one.
--- It should not be called in a binding definition.
local function focus_grp_right_or_next()
    local win = hl.get_active_window()
    if win == nil then return end
    local group = win.group
    if group and group.current_index < group.size then
        -- if we have a group and not at the end, move within the group
        hl.dispatch(hl.dsp.group.next())
    else
        -- else, move between windows
        hl.dispatch(dirnext())
    end
end

--- Moves the focused window left within the group, or moves the group left,
--- depending on focused window position.
--- 
--- Note: This *is* a dispatcher; it does not return one.
--- It should not be called in a binding definition.
local function move_grp_left_or_prev()
    local win = hl.get_active_window()
    if win == nil then return end
    local group = win.group
    if group and group.current_index > 1 then
        hl.dispatch(hl.dsp.group.move_window({ forward = false, }))
    else
        hl.dispatch(moveleft())
    end
end

--- Moves the focused window right within the group, or moves the group right,
--- depending on focused window position.
--- 
--- Note: This *is* a dispatcher; it does not return one.
--- It should not be called in a binding definition.
local function move_grp_right_or_next()
    local win = hl.get_active_window()
    if win == nil then return end
    local group = win.group
    if group and group.current_index < group.size then
        hl.dispatch(hl.dsp.group.move_window({ forward = true, }))
    else
        hl.dispatch(moveright())
    end
end

--- Directional navigation keybinds.
kb.dir = {
    mouse = {
        up = hl.bind(mainmod .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }),
            { description = "Focus on the previous workspace" }
        ),
        down = hl.bind(mainmod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }),
            { description = "Focus on the next workspace" }
        ),
        left = {
            coarse = hl.bind(mainmod .. " + CTRL + SHIFT + mouse_up", dirprev()),
            fine = hl.bind(mainmod .. " + SHIFT + mouse_up", focus_grp_left_or_prev)
        },
        right = {
            coarse = hl.bind(mainmod .. " + CTRL + SHIFT + mouse_down", dirnext()),
            fine = hl.bind(mainmod .. " + SHIFT + mouse_down", focus_grp_right_or_next),
        }
    },
    focus = {
        up = hl.bind(mainmod .. " + Up", hl.dsp.focus({ workspace = "m-1" })),
        down = hl.bind(mainmod .. " + Down", hl.dsp.focus({ workspace = "m+1" })),
        left = {
            --- Move by window.
            coarse = hl.bind(mainmod .. " + CTRL + Left", dirprev()),
            --- Move within groups first, then by window.
            fine = hl.bind(mainmod .. " + Left", focus_grp_left_or_prev)
        },
        right = {
            --- Move by window.
            coarse = hl.bind(mainmod .. " + CTRL + Right", dirnext()),
            --- Move within groups first, then by window.
            fine = hl.bind(mainmod .. " + Right", focus_grp_right_or_next)
        },
    },
    move = {
        up = hl.bind(mainmod .. " + SHIFT + Up", hl.dsp.window.move({ workspace = "m-1" })),
        down = hl.bind(mainmod .. " + SHIFT + Down", hl.dsp.window.move({ workspace = "m+1" })),
        left = {
            coarse = hl.bind(mainmod .. " + CTRL + SHIFT + Left", moveleft()),
            fine = hl.bind(mainmod .. " + SHIFT + Left", move_grp_left_or_prev),
        },
        right = {
            coarse = hl.bind(mainmod .. " + CTRL + SHIFT + Right", moveright()),
            fine = hl.bind(mainmod .. " + SHIFT + Right", move_grp_right_or_next),
        },
        mouse = {
            left = hl.bind(mainmod .. " + mouse_left", moveleft()),
            right = hl.bind(mainmod .. " + mouse_right", moveright()),
            -- todo: coarse and fine
        }
    },
    monitor = {
        -- fixme: once I get a second monitor
        focus = {
            -- Mod + ALT + Left/Right: focus to monitor left or right
        },
        move = {
            -- Mod + SHIFT + ALT + Left/Right: move active window to monitor left or right
            -- Mod + CTRL + ALT + Left/Right: move active window to monitor left or right, no focus
        }
    }
    -- todo (ALL): add descriptions
}

-- oooo                                                  .   
-- `888                                                .o8   
--  888   .oooo.   oooo    ooo  .ooooo.  oooo  oooo  .o888oo 
--  888  `P  )88b   `88.  .8'  d88' `88b `888  `888    888   
--  888   .oP"888    `88..8'   888   888  888   888    888   
--  888  d8(  888     `888'    888   888  888   888    888 . 
-- o888o `Y888""8o     .8'     `Y8bod8P'  `V88V"V8P'   "888" 
--                 .o..P'                                    
--                 `Y8P'                                     

--- Layout-specific keybinds.
kb.layout = {
    --- Controls for the width of the layout's central window.
    --- On scrolling, this is the current focused window; on master, this is the master window.
    width = {
        --- Increase the width of the central window.
        up = hl.bind(mainmod .. " + equal",
            per_layout({
                scrolling = hl.dsp.layout("colresize +0.2"),
                master = hl.dsp.layout("mfact +0.02"),
                monocle = hl.dsp.no_op(),
            }),
            { description = "Increase the size of the layout's central window" }
        ),
        --- Decrease the width of the central window.
        down = hl.bind(mainmod .. " + minus",
            per_layout({
                scrolling = hl.dsp.layout("colresize -0.2"),
                master = hl.dsp.layout("mfact -0.02"),
                monocle = hl.dsp.no_op(),
            }),
            { description = "Decrease the size of the layout's central window" }
        ),
        --- Cycle between a set of pre-defined widths.
        cycle = hl.bind(mainmod .. " + E",
            per_layout({
                scrolling = hl.dsp.layout("colresize +conf"),
                master = hl.dsp.no_op(),
                monocle = hl.dsp.no_op(),
            }),
            { description = "Cycle through the sizes of the layout's central window" }
        ),
    },
    --- Controls for cycling windows within a layout.
    cycle = {
        --- Controls for cycling focus.
        focus = {
            left = hl.bind(mainmod .. " + Prior",
                per_layout({
                    scrolling = hl.dsp.layout("focus l"),
                    master = hl.dsp.layout("cycleprev loop"),
                    monocle = hl.dsp.no_op(), -- todo
                })
            ),
            right = hl.bind(mainmod .. " + Next",
                per_layout({
                    scrolling = hl.dsp.layout("focus r"),
                    master = hl.dsp.layout("cyclenext loop"),
                    monocle = hl.dsp.no_op(), -- todo
                })
            )
        },
        --- Controls for cycling window position.
        move = {
            left = hl.bind(mainmod .. " + SHIFT + Prior",
                per_layout({
                    scrolling = hl.dsp.layout("swapcol l"),
                    master = hl.dsp.layout("rollprev"),
                    monocle = hl.dsp.no_op(), -- todo
                })
            ),
            right = hl.bind(mainmod .. " + SHIFT + Next",
                per_layout({
                    scrolling = hl.dsp.layout("swapcol r"),
                    master = hl.dsp.layout("rollnext"),
                    monocle = hl.dsp.no_op(), -- todo
                })
            )
        }
    },
    absorb_or_expel = {
        left = hl.bind(mainmod .. " + comma",
            per_layout({
                scrolling = hl.dsp.layout("consume_or_expel prev"),
                master = hl.dsp.layout("addmaster"),
                monocle = hl.dsp.no_op(),
            })
        ),
        right = hl.bind(mainmod .. " + period",
            per_layout({
                scrolling = hl.dsp.layout("consume_or_expel next"),
                master = hl.dsp.layout("removemaster"),
                monocle = hl.dsp.no_op(),
            })
        ),
    },
}

--  .oooooooo oooo d8b  .ooooo.  oooo  oooo  oo.ooooo.  
-- 888' `88b  `888""8P d88' `88b `888  `888   888' `88b 
-- 888   888   888     888   888  888   888   888   888 
-- `88bod8P'   888     888   888  888   888   888   888 
-- `8oooooo.  d888b    `Y8bod8P'  `V88V"V8P'  888bod8P' 
-- d"     YD                                  888       
-- "Y88888P'                                 o888o      

--- Create a dispatcher that:
--- - If the current window is already in a group, it moves it out in the specified direction.
--- - Otherwise, it moves the current window into or creates a new group in the specified direction.
---   - If the remaining group has one member remaining, it removes that member as well to delete
---     the group.
local function move_into_or_out_of_group(direction)
    --- If the current window is already in a group, move it out in the given direction.
    --- Otherwise, move into or create a new group in the given direction.
    return function()
        local window = hl.get_active_window()
        if window == nil then return end
        local group = window.group
        if group == nil then
            hl.dispatch(hl.dsp.window.move({ into_or_create_group = direction }))
        else
            hl.dispatch(hl.dsp.window.move({ out_of_group = direction}))
            -- if the group only has one remaining member, remove it to delete the group
            if group.size == 1 then
                group:remove(group.current)
            end
        end
    end
end

--- Group manipulation keybinds.
kb.group = {
    toggle = hl.bind(mainmod .. " + W", 
        hl.dsp.group.toggle(), { description = "Toggle grouping on the current window" }
    ),
    enterexit = {
        left = hl.bind(mainmod .. " + BracketLeft",
            move_into_or_out_of_group("l"),
            { description = "Move current window into or out of group to the left" }
        ),
        right = hl.bind(mainmod .. " + BracketRight",
            move_into_or_out_of_group("r"),
            { description = "Move current window into or out of group to the right"}
        ),
        mouse = {
            left = hl.bind(mainmod .. " + mouse:275", move_into_or_out_of_group("l"),
                { description = "Move current window into or out of a group to the left" }
            ),
            right = hl.bind(mainmod .. " + mouse:276", move_into_or_out_of_group("r"),
                { description = "Move current window into or out of a group to the right" }
            ),
        }
    },
    move = {
        left = hl.bind(mainmod .. " + SHIFT + BracketLeft",
            hl.dsp.group.move_window({ forward = false, }),
            { description = "Move active window backwards within a group" }
        ),
        right = hl.bind(mainmod .. " + SHIFT + BracketRight",
            hl.dsp.group.move_window({ forward = true, }),
            { description = "Move active window forwards within a group" }
        ),
        -- mouse = {
        --     left = hl.bind(mainmod .. " + SHIFT + mouse_left",
        --         hl.dsp.group.move_window({ forward = false, })
        --     ),
        --     right = hl.bind(mainmod .. " + SHIFT + mouse_right",
        --         hl.dsp.group.move_window({ forward = true, })
        --     ),
        -- }
    }
}

--                       .o8                                              
--                      "888                                              
--  .oooo.o oooo  oooo   888oooo.  ooo. .oo.  .oo.    .oooo.   oo.ooooo.  
-- d88(  "8 `888  `888   d88' `88b `888P"Y88bP"Y88b  `P  )88b   888' `88b 
-- `"Y88b.   888   888   888   888  888   888   888   .oP"888   888   888 
-- o.  )88b  888   888   888   888  888   888   888  d8(  888   888   888 
-- 8""888P'  `V88V"V8P'  `Y8bod8P' o888o o888o o888o `Y888""8o  888bod8P' 
--                                                              888       
--                                                             o888o      

--- Keybind submaps.
kb.submaps = {
    group = {
        bind = hl.bind(mainmod .. " + K", hl.dsp.submap("GROUP")),
        submap = hl.define_submap("GROUP", function()
            hl.bind("Return", hl.dsp.group.toggle())
            hl.bind("Delete", hl.dsp.window.move({out_of_group = true}))

            -- todo

            hl.bind(mainmod .. " + K", hl.dsp.submap("reset"))
            hl.bind("escape", hl.dsp.submap("reset"))
        end)
    },
    overview = {
        bind = kb.session.overview.open,
        submap = hl.define_submap("scrolloverview", function()
            -- arrow keys and WASD (for left hand use)
            hl.bind("Left", soview.navigate("left"))
            hl.bind("Right", soview.navigate("right"))
            hl.bind("Up", soview.navigate("up"))
            hl.bind("Down", soview.navigate("down"))

            hl.bind("W", soview.navigate("up"))
            hl.bind("A", soview.navigate("left"))
            hl.bind("S", soview.navigate("down"))
            hl.bind("D", soview.navigate("right"))

            hl.bind("SHIFT + mouse_up", soview.navigate("left"))
            hl.bind("SHIFT + mouse_down", soview.navigate("right"))
            hl.bind("mouse_up", soview.navigate("up"))
            hl.bind("mouse_down", soview.navigate("down"))

            hl.bind("mouse:272", function()
                -- Select the clicked window, or just the workspace if no window was clicked, then close
                soview.overview("select")
                soview.window("select")
                soview.overview("off")
            end, { mouse = true })

            hl.bind("Q", soview.window("close"))
            hl.bind("mouse:273", soview.window("close"))

            hl.bind("Escape", soview.overview("close all"))
            hl.bind(mainmod .. " + O", soview.overview("close all"))
            hl.bind(mainmod .. " + mouse:274", 
                soview.overview("close all"), { mouse = true }
            )
        end)
    },
    layout = {
        --- The bind to open the layout control submap.
        --- 
        --- Since the submap opened (and hence the duckyPad profile) is dependent on the current layout,
        --- Hyprland must send some data to the duckyPad so it knows which profile to open. This is done
        --- using duckyPad's persistent global variables (PGVs), which can be set through USB HID via the
        --- duckyctl command. When the keybind is triggered, Hyprland runs duckyctl through the duckypad
        --- module and sets PGV3 to 1 for scrolling, 2 for master. The corresponding script on the duckyPad
        --- runs the keybind, waits 25ms for Hyprland to set the PGV, and then reads the PGV to decide
        --- which profile to activate. The duckyPad script then resets the PGV to 0, but for cases where
        --- the keybind is run from the keyboard (and not duckyPad), in which case the script to reset the
        --- PGV isn't running, the keybind also sets a 100ms timer to reset the PGV via duckyctl.
        bind = hl.bind(mainmod .. " + L", per_layout({
            scrolling = function()
                dp.send_command("write-pgv", {"-i", "3=1"})
                hl.dispatch(hl.dsp.submap("SCROLL"))
                hl.timer(function()
                    dp.send_command("write-pgv", {"-i", "3=0"})
                end, { timeout = 100, type = "oneshot"})
            end,
            master = function()
                dp.send_command("write-pgv", {"-i", "3=2"})
                hl.dispatch(hl.dsp.submap("MASTER"))
                hl.timer(function()
                    dp.send_command("write-pgv", {"-i", "3=0"})
                end, { timeout = 100, type = "oneshot"})
            end
        })),
        submap = {
            scroll = hl.define_submap("SCROLL", function()
                -- todo

                hl.bind(mainmod .. " + L", hl.dsp.submap("reset"))
                hl.bind("escape", hl.dsp.submap("reset"))
            end),
            master = hl.define_submap("MASTER", function()
                -- todo

                hl.bind(mainmod .. " + L", hl.dsp.submap("reset"))
                hl.bind("escape", hl.dsp.submap("reset"))
            end)
        }
    },
    launch = {
        -- todo
    },
    hackery = {
        -- todo
    },
    design = {
        -- todo
    },
    gaming = {
        -- todo
    },
    plumbing = {
        bind = hl.bind(mainmod .. " + CTRL + SHIFT + escape",  function()
            hl.notification.create({
                text = "You are entering plumbing mode, make sure you know what you're doing!",
                timeout = 3000,
                icon = "warning"
            })
            hl.dispatch(hl.dsp.submap("PLUMBING"))
        end),
        submap = hl.define_submap("PLUMBING", function()

            hl.bind(mainmod .. " + Delete", hl.dsp.window.clear_tags({ window = "^(tag:minimized[0-9]+)$"}),
                { repeating = false, description = "Clear all minimized tags from windows" }
            )

            -- fixme: once I get a second monitor
            -- keybinds to move workspaces between monitors

            hl.bind("escape", hl.dsp.submap("reset"))
        end)
    }

}

--- Reserved bindings.
kb.reserved = {
    hl.bind(mainmod .. " + G", hl.dsp.no_op()),
    hl.bind(mainmod .. " + SHIFT + G", hl.dsp.no_op()),
    hl.bind(mainmod .. " + CTRL + G", hl.dsp.no_op()),

    hl.bind(mainmod .. " + H", hl.dsp.no_op()),
    hl.bind(mainmod .. " + SHIFT + H", hl.dsp.no_op()),
    hl.bind(mainmod .. " + CTRL + H", hl.dsp.no_op()),

    hl.bind(mainmod .. " + escape", hl.dsp.no_op()),
    hl.bind(mainmod .. " + SHIFT + escape", hl.dsp.no_op()),
    hl.bind(mainmod .. " + CTRL + escape", hl.dsp.no_op()),
    hl.bind(mainmod .. " + ALT + escape", hl.dsp.no_op()),

    --todo: add more
}

kb.per_layout = per_layout

return kb