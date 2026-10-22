--  .ooooo.  ooo. .oo.   oooo    ooo 
-- d88' `88b `888P"Y88b   `88.  .8'  
-- 888ooo888  888   888    `88..8'   
-- 888    .o  888   888     `888'    
-- `Y8bod8P' o888o o888o     `8'     

-- Variables that will be used everywhere.

env = {}

env.home_dir = os.getenv("HOME")

if env.home_dir == nil then
    error("Could not read $HOME")
end

env.config_dir = os.getenv("XDG_CONFIG_HOME") or env.home_dir .. "/.config"

env.hypr_dir = env.config_dir .. "/hypr"

--- Create the uwsm command to start `app`.
--- @param app string The name of the app to start.
--- @param ext boolean Whether to append a .desktop at the end.
--- @return string cmd The command to run.
local function uwsm(app, ext)
    if ext == nil then
        ext = false
    end
    local name = "uwsm app -- " .. app
    if ext then
        name = name .. ".desktop"
    end

    return name
end

--- Create the systemctl command to start the service with name `serv`.
--- @param serv string The name of the service to start.
--- @return string cmd The command to run.
local function systemctl(serv)
    return "systemctl --user start " .. serv .. ".service"
end

env.term = "Alacritty"

do
    local handle = io.popen("hostname", "r")
    if handle == nil then
        env.hostname = "cartoonraccoon-raccoonpc" -- ???
    else
        env.hostname = handle:read("l")
        handle:close()
    end
end

do
    local var = os.getenv("USE_NOCTALIA")
    if var == nil or not (var == "1") then
        env.using_noctalia = false
    elseif var == "1" then
        env.using_noctalia = true
    else
        env.using_noctalia = false
    end
end

-- Helper function to check if we are running on desktop.
local function on_desktop()
    return string.find(env.hostname, "raccoonpc")
end

-- Helper function to check if we are running on laptop.
local function on_laptop()
    return string.find(env.hostname, "cartoonraccoon")
end

local function plugin_is_loaded(name)
    for _, p in pairs(hl.get_loaded_plugins()) do
        if p.name == name then return true end
    end

    return false
end

env.uwsm = uwsm
env.systemctl = systemctl
env.on_desktop = on_desktop
env.on_laptop = on_laptop
env.plugin_is_loaded = plugin_is_loaded

return env