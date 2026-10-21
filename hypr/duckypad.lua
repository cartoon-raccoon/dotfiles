--       .o8                        oooo                                               .o8  
--      "888                        `888                                              "888  
--  .oooo888  oooo  oooo   .ooooo.   888  oooo  oooo    ooo oo.ooooo.   .oooo.    .oooo888  
-- d88' `888  `888  `888  d88' `"Y8  888 .8P'    `88.  .8'   888' `88b `P  )88b  d88' `888  
-- 888   888   888   888  888        888888.      `88..8'    888   888  .oP"888  888   888  
-- 888   888   888   888  888   .o8  888 `88b.     `888'     888   888 d8(  888  888   888  
-- `Y8bod88P"  `V88V"V8P' `Y8bod8P' o888o o888o     .8'      888bod8P' `Y888""8o `Y8bod88P" 
--                                              .o..P'       888                            
--                                              `Y8P'       o888o                           

require("string")

---@alias DP.Command
---| "query-info"
---| "goto-profile-num"
---| "goto-profile-name"
---| "prev-profile"
---| "next-profile"
---| "set-rgb"
---| "reset"
---| "sleep"
---| "wake"
---| "dump-pgv"
---| "write-pgv"
---| "update-rtc"

dp = {}

local prefix = "duckyctl "

dp.profilemap = {
    [{ class = "zen", title = nil }] = "Browser",
    [{ class = "com.microsoft.VSCode", title = nil }] = "Code",
    [{ class = "discord", title = nil }] = "Discord",
    [{ class = "org.kde.dolphin", title = nil }] = "Files",
    [{ class = "nemo", title = nil }] = "Files",
    [{ class = "org.kde.okular", title = nil }] = "Reader",
    [{ class = "md.obsidian.Obsidian", title = nil}] = "Obsidian"
}

dp.last_profile = "General"
dp.fallback_profile = "General"

--- Match `pat` with `source`.
--- Returns true if `pat` or `source` are nil, or `source` matches `pat`.
local function single_match(pat, source)
    return pat == nil or source == nil or not (string.match(source, pat) == nil)
end

--- Match `class` and `title` with the pairs defined in `profilemap`, and returns any match.
--- If no matches are found, returns nil.
--- @param class string The class of the app to match.
--- @param title string The title of the app to match.
--- @return string|nil profile The matched profile, if any.
function dp.match(class, title)
    for k, v in pairs(dp.profilemap) do
        if single_match(k.class, class) and single_match(k.title, title) then
            return v
        end
    end

    return nil
end

--- Return the profile corresponding to the current active window.
--- @return string profile The profile matching the current active window.
function dp.active_window_profile()
    local win = hl.get_active_window()
    if win == nil then
        return dp.fallback_profile
    end

    return dp.match(win.class, win.title) or dp.fallback_profile
end

--- Send a command to the DuckyPad.
--- @param cmd DP.Command
--- @param args? table<string>
function dp.send_command(cmd, args)
    local command = prefix .. cmd
    if args then
        for i = 1,#args do
            command = command .. " " .. args[i]
        end
    end
    hl.exec_cmd(command)
end

dp.hook = hl.on("window.active", function(w)
    -- hl.notification.create({ text = "Class: " .. w.class .. " Title: " .. w.title, timeout = 2000 })
    if w.class == nil and w.title == nil then return end

    local profile = dp.match(w.class, w.title)
    if profile == nil then
        dp.last_profile = dp.fallback_profile
        dp.send_command("goto-profile-name", { dp.fallback_profile })
    else
        -- If the last profile matches the new profile, don't spin up a new process, just leave it and return
        if dp.last_profile == profile then
            return
        end

        dp.last_profile = profile
        dp.send_command("goto-profile-name", { profile })
    end
end)

return dp