--                  oooo                                      
--                  `888                                      
-- oooo oooo    ooo  888  oooo   .oooo.o oo.ooooo.   .ooooo.  
--  `88. `88.  .8'   888 .8P'   d88(  "8  888' `88b d88' `"Y8 
--   `88..]88..8'    888888.    `"Y88b.   888   888 888       
--    `888'`888'     888 `88b.  o.  )88b  888   888 888   .o8 
--     `8'  `8'     o888o o888o 8""888P'  888bod8P' `Y8bod8P' 
--                                        888                 
--                                       o888o                 

local table = require("table")

--- The Workspace Model
--- 
--- Every day I thank Hyprland for moving to Lua so I can build this in the config instead of in scripts.
--- The workspace model builds on Hyprland's own workspace model, and also takes some inspiration from
--- Niri. It works as follows:
--- 
--- Workspaces are found on monitors. There are two monitors in this setup: the primary one (DP-1) and
--- the secondary one (DP-2). No need to generalize to an arbitrary monitor count.
--- 
--- There are two main kinds of workspaces: Static and Dynamic (There is a third kind of workspace,
--- special, but that's just a regular Hyprland special workspace). Workspaces, regardless of type,
--- always appear on a fixed monitor, and cannot move between monitors. Because of this, the Hyprland ID
--- space is split into two spaces:
--- - IDs 1-100: IDs on the primary monitor.
--- - IDs 100+: IDs on the secondary monitor.
--- Since negative IDs cannot be explicitly assigned in Hyprland (which would be the best convention for
--- static workspaces), static workspaces instead take up the first IDs in their respective monitor's
--- ID space, and dynamic workspaces take up the rest. In the case of the primary monitor, there are 4
--- static workspaces, so they take IDs 1-4. There are currently no static workspaces on the secondary
--- monitor, so its dynamic workspaces get the full 100+ ID space.
--- 
--- Each dynamic workspace is temporary, i.e. it gets deleted when it is empty and is switched away from,
--- and each also gets an index. It is important to distinguish this from its ID. Indexes are
--- monitor-specific, as opposed to IDs that are global, and they always start from 1. So, dynamic
--- 1 on the primary monitor has ID 5 (1 + 4, the number of static workspaces). The index of a dynamic
--- workspace can be calculated by subtracting its monitor's offset from its ID.
--- 
--- Dynamic workspaces are named using the convention <prefix><idx>, where prefix is monitor dependent.
--- The primary monitor prefix is "P", while the secondary monitor prefix is "S". While we could use
--- hooks to dynamically rename dynamic workspaces as they are created, we never bound any key beyond 9,
--- so currently the rules are just handwritten, as it's unlikely we'll be using anything beyond index 9.
--- 
--- There is also the concept of ID validity (within this model). IDs are valid with respect to a monitor,
--- and to their parity. That is, IDs are invalid if they are negative, or they are outside their monitor's
--- ID range. For example, ID 5 can be valid for the primary monitor, but invalid for the secondary monitor.
--- 
--- It is important to note that nothing actually stops this model from being broken. You can easily run
--- a move-workspace-to-monitor dispatcher in `hyprctl dispatch` and move workspace 5 to the secondary
--- monitor. We make a best effort at enforcement by not actually binding move-workspace-to-monitor
--- dispatchers to keys, as well as through hooks and rules to enforce the ID and naming convention.

---@alias WorkspaceType
---| "static"
---| "dynamic"
---| "special"

---@class Workspace
---@field type WorkspaceType The type of workspace.
---@field id integer The ID of the workspace.
---@field name string The name of the workspace.
---@field mon string The monitor of the workspace.
---@field sel_id fun(self: Workspace, silent: boolean?):string
---@field sel_name fun(self: Workspace, silent: boolean?):string
---@field rule fun(self: Workspace, default: boolean?, persistent: boolean?):HL.WorkspaceRule
Workspace = {}
Workspace.__index = Workspace

-- A specification for a workspace.

---@class WorkspaceSpec
---@field animation? string
---@field border_size? integer|boolean
---@field decorate? boolean
---@field default? boolean
---@field default_name? string
---@field enabled? boolean
---@field float_gaps? integer|HL.CssGap
---@field gaps_in? integer|HL.CssGap
---@field gaps_out? integer|HL.CssGap
---@field layout? string
---@field layout_opts? table<string, string|number|boolean>
---@field monitor? string
---@field no_border? boolean
---@field no_rounding? boolean
---@field no_shadow? boolean
---@field on_created_empty? string
---@field persistent? boolean

ws = {}

--- Construct a new Workspace.
--- @param type WorkspaceType The type of workspace.
--- @param id integer The id of the workspace.
--- @param name string The name of the workspace.
--- @param mon string The name of the workspace's monitor.
function Workspace.new(type, id, name, mon)
    local self = {
        type = type,
        id = id,
        name = name,
        mon = mon
    }

    self = setmetatable(self, Workspace)

    return self
end

--- Express the Workspace's ID as a string.
function Workspace:idstr()
    return tostring(self.id)
end

--- Construct a workspace selector based on its ID.
--- If silent is true, appends " silent" to the end to create a silent workspace selector.
---@param silent? boolean
---@return string
function Workspace:sel_id(silent)
    if silent == nil then
        silent = false
    end
    local selector = self:idstr()
    if self.type == "special" then
        selector = "special:" .. self.name
    end
    if silent then
        selector = selector .. " silent"
    end

    return selector
end

--- Construct a workspace selector based on its name.
--- If silent is true, appends " silent" to the end to create a silent workspace selector.
--- @param silent? boolean
--- @return string
function Workspace:sel_name(silent)
    if silent == nil then
        silent = false
    end
    local selector = "name:" .. self.name
    if self.type == "special" then
        selector = "special:" .. self.name
    end
    if silent then
        selector = selector .. " silent"
    end

    return selector
end

--- Construct a Hyprland workspace rule from `wkspc`.
--- This constructs the default rule. If
--- @param spec? WorkspaceSpec
--- @return HL.WorkspaceRule
function Workspace:rule(spec)
    -- !!! This is incomplete. Do not use it.

    -- fixme: integrate spec

    if self.type == "static" then
        return hl.workspace_rule({
            workspace = self:idstr(),
            default_name = self.name,
            monitor = self.mon,
        })
    elseif self.type == "dynamic" then
        return hl.workspace_rule({
            workspace = self:idstr(),
            default_name = self.name,
            monitor = self.mon
            -- leave out default and persistent
        })
    else
        return hl.workspace_rule({
            workspace = self:sel_name(),
            monitor = self.mon
        })
    end
end

ws.monitors = {
    primary = "DP-1",
    secondary = "DP-2",
}

--- Given an id `id` and a monitor `mon`, convert `id` into a dynamic index
--- with respect to `mon`.
--- If `id` is invalid with respect to `mon`, the returned value will be <= 0.
--- @param id string|number The id to convert.
--- @param mon string The monitor to take reference from.
local function id_to_idx(id, mon)
    if type(id) == "string" then
        id = tonumber(id) or 0
    end

    if mon == ws.monitors.primary then
        return id - 4
    elseif mon == ws.monitors.secondary then
        return id - 100
    else
        return -1
    end
end

ws.reserved_names = { "Main", "Dev", "Chat", "Music" }

--- Check if `name` is a reserved name.
--- @param name string The name to check.
--- @return boolean is_reserved
local function is_reserved_name(name)
    if name == nil then
        return false
    end
    for _, n in ipairs(ws.reserved_names) do
        if name == n then
            return true
        end
    end

    return false
end

--- Rename the current workspace to `name`.
--- Will send an error notification if the current workspace is static, or `name` is reserved.
--- @param name string The new name for the workspace.
local function rename_workspace(name)
    local wksp = hl.get_active_workspace()
    if wksp == nil then return end

    if wksp.is_persistent then
        hl.notification.create({
            text = "Cannot rename static workspace " .. wksp.name,
            timeout = 3000,
            icon = "error"
        })
        return
    end

    if is_reserved_name(name) then
        hl.notification.create({
            text = "Cannot rename workspace to a reserved name " .. name,
            timeout = 3000,
            icon = "error",
        })
        return
    end

    hl.dispatch(hl.dsp.workspace.rename({ workspace = wksp, name = name }))
end

--- Construct a static workspace from an id, name, and monitor.
--- @param id integer The id of the workspace.
--- @param name string The name of the workspace.
--- @param mon? string The monitor the workspace should appear on.
function Workspace.static(id, name, mon)
    if mon == nil then
        mon = ws.monitors.primary
    end
    return Workspace.new("static", id, name, mon)
end

--- Construct a dynamic workspace from its index and monitor.
---@param idx number The index of the workspace.
---@param mon string The monitor to use.
---@return Workspace ws The workspace.
function Workspace.dyn(idx, mon)
    if mon == ws.monitors.primary then
        return Workspace.new("dynamic", idx + 4, "P" .. idx, mon)
    elseif mon == ws.monitors.secondary then
        return Workspace.new("dynamic", idx + 100, "S" .. idx, mon)
    else
        -- fixme: error handling
        return Workspace.new("dynamic", idx + 4, tostring(idx), mon)
    end
end

--- Construct a dynamic workspace on the primary monitor.
--- @param idx number
--- @return Workspace
function Workspace.pridyn(idx)
    return Workspace.dyn(idx, ws.monitors.primary)
end

--- Construct a dynamic workspace on the secondary monitor.
--- @param idx integer
--- @return Workspace
function Workspace.secdyn(idx)
    return Workspace.dyn(idx, ws.monitors.secondary)
end

--- Construct a dynamic workspace on the current monitor.
--- @param idx number
--- @return Workspace
function Workspace.currdyn(idx)
    local mon = hl.get_active_monitor()
    return Workspace.dyn(idx, mon.name)
end

--- Construct a special workspace from its name and monitor.
--- Note that ID in special workspaces is always invalid, and should not be used.
--- @param name string The name of the workspace.
--- @param mon? string The monitor of the workspace.
--- @return Workspace
function Workspace.special(name, mon)
    if mon == nil then
        mon = ws.monitors.primary
    end
    return Workspace.new("special", -1, name, mon)
end

ws.main = Workspace.static(1, "Main", ws.monitors.primary)

ws.dev = Workspace.static(2, "Dev", ws.monitors.primary)

ws.chat = Workspace.static(3, "Chat", ws.monitors.primary)

ws.music = Workspace.static(4, "Music", ws.monitors.primary)

local dyns = {
    Workspace.pridyn(1),
    Workspace.pridyn(2),
    Workspace.pridyn(3),
    Workspace.pridyn(4),
    Workspace.pridyn(5),
    Workspace.pridyn(6),
    Workspace.pridyn(7),
    Workspace.pridyn(8),
    Workspace.pridyn(9),
}

ws.specials = {
    minimized = Workspace.special("minimized")
}

--- Get all the workspaces on the current active monitor.
--- @return HL.Workspace[]
local function wkspcs_on_active_mon()
    local mon = hl.get_active_monitor()
    if mon == nil then return {} end
    local wss = hl.get_workspaces()

    local result = {}

    for i = 1, #wss do
        if wss[i].monitor.name == mon.name then
            table.insert(result, wss[i])
        end
    end

    return result
end

--- Get all the dynamic workspaces on the current active monitor.
--- @return HL.Workspace[]
local function dyn_wkspcs_on_active_mon()
    -- fixme: make a filter function
    local mon = hl.get_active_monitor()
    if mon == nil then return {} end
    local wss = hl.get_workspaces()

    local result = {}

    for i = 1, #wss do
        if wss[i].monitor.name == mon.name and not wss[i].is_persistent and not wss[i].special then
            table.insert(result, wss[i])
        end
    end

    return result
end

--- Gets the first empty dynamic workspace on the current monitor, or nil if there is none.
--- @return Workspace|nil workspace The first empty dynamic workspace.
local function first_empty_dyn_wkspc()
    local mon = hl.get_active_monitor()
    if mon == nil then return end

    local ds = dyn_wkspcs_on_active_mon()
    if #ds == 0 then
        return Workspace.currdyn(1)
    end

    local array = {}
    for i = 1,#ds do
        local ws = ds[i]
        array[id_to_idx(ws.id, mon.name)] = ws
    end

    for i = 1,9 do
        local ws = array[i]
        if ws == nil or ws.windows == 0 then
            return Workspace.currdyn(i)
        end
    end

    return nil
end

--- Create a dispatcher that focuses on the dynamic workspace with index `idx`, on the current monitor.
--- @param idx number The index of the target workspace.
--- @return function dispatcher The dispatcher.
local function focus_dyn_wkspc_curr_mon_dispatcher(idx)
    return function()
        local target = Workspace.currdyn(idx)
        hl.dispatch(hl.dsp.focus({ workspace = target:sel_id() }))
    end
end

--- Create a dispatcher that moves the active window to the dynamic workspace with index `idx`, on the
--- current monitor.
--- @param idx number The index of the target workspace.
--- @param follow boolean? Whether to focus after moving.
--- @return function dispatcher The dispatcher.
local function move_to_dyn_wkspc_curr_mon_dispatcher(idx, follow)
    return function()
        local target = Workspace.currdyn(idx)
        hl.dispatch(hl.dsp.window.move({ workspace = target:sel_id(), follow = follow }))
    end
end

ws.rules = {
    static = {
        main = hl.workspace_rule({
            workspace = ws.main:idstr(),
            default_name = ws.main.name,
            monitor = ws.main.mon,
            default = true,
            persistent = true,
        }),
        dev = hl.workspace_rule({
            workspace = ws.dev:idstr(),
            default_name = ws.dev.name,
            monitor = ws.dev.mon,
            persistent = true,
        }),
        chat = hl.workspace_rule({
            workspace = ws.chat:idstr(),
            default_name = ws.chat.name,
            monitor = ws.chat.mon,
            persistent = true,
        }),
        music = hl.workspace_rule({
            workspace = ws.music:idstr(),
            default_name = ws.music.name,
            monitor = ws.music.mon,
            persistent = true,
            layout = "master",
            layout_opts = {
                orientation = "center"
            }
        }),
    },
    dynamic = {
        -- fixme: add monitor rule once I get a second monitor
        hl.workspace_rule({ workspace = dyns[1]:idstr(), default_name = dyns[1].name }),
        hl.workspace_rule({ workspace = dyns[2]:idstr(), default_name = dyns[2].name }),
        hl.workspace_rule({ workspace = dyns[3]:idstr(), default_name = dyns[3].name }),
        hl.workspace_rule({ workspace = dyns[4]:idstr(), default_name = dyns[4].name }),
        hl.workspace_rule({ workspace = dyns[5]:idstr(), default_name = dyns[5].name }),
        hl.workspace_rule({ workspace = dyns[6]:idstr(), default_name = dyns[6].name }),
        hl.workspace_rule({ workspace = dyns[7]:idstr(), default_name = dyns[7].name }),
        hl.workspace_rule({ workspace = dyns[8]:idstr(), default_name = dyns[8].name }),
        hl.workspace_rule({ workspace = dyns[9]:idstr(), default_name = dyns[9].name }),
    },
    special = {
        minimized = hl.workspace_rule({ workspace = ws.specials.minimized:sel_name() })
    }
}

ws.hook = hl.on("workspace.created", function(wkspc)
    if wkspc.is_persistent then return end

    local mon = hl.get_active_monitor()
    if mon == nil then return end

    local prefix
    if mon.name == ws.monitors.primary then
        prefix = "P"
    elseif mon.name == ws.monitors.secondary then
        prefix = "S"
    else
        prefix = "X" -- shouldn't happen but to be safe
    end

    -- todo: conform new ws to workspace model and naming convention
end)

ws.Workspace = Workspace

ws.id_to_idx = id_to_idx

ws.is_reserved_name = is_reserved_name
ws.rename_workspace = rename_workspace
ws.dyns = dyns
ws.wkspcs_on_active_mon = wkspcs_on_active_mon
ws.dyn_wkspcs_on_active_mon = dyn_wkspcs_on_active_mon
ws.first_empty_dyn_wkspc = first_empty_dyn_wkspc
ws.dsp = {
    focus_dyn_wkspc_curr_mon = focus_dyn_wkspc_curr_mon_dispatcher,
    move_to_dyn_wkspc_curr_mon = move_to_dyn_wkspc_curr_mon_dispatcher,
}
return ws