--                     oooo                              
--                     `888                              
--  .ooooo.   .ooooo.   888   .ooooo.  oooo d8b  .oooo.o 
-- d88' `"Y8 d88' `88b  888  d88' `88b `888""8P d88(  "8 
-- 888       888   888  888  888   888  888     `"Y88b.  
-- 888   .o8 888   888  888  888   888  888     o.  )88b 
-- `Y8bod8P' `Y8bod8P' o888o `Y8bod8P' d888b    8""888P' 

require("string")
require("table")

local col = {}

--- Clamp a number between a range.
--- @param i number The number to clamp.
--- @param lower number The lower end of the clamp range.
--- @param upper number The upper end of the clamp range.
local function clamp(i, lower, upper)
    if i > upper then
        return upper
    elseif i < lower then
        return lower
    else
        return i
    end
end

--- @alias ColorMode
--- | "rgb"
--- | "rgba"
--- | "rgbdec"
--- | "rgbadec"
--- | "hex"
--- | "hexa"
--- | "argb"

--                     oooo                     
--                     `888                     
--  .ooooo.   .ooooo.   888   .ooooo.  oooo d8b 
-- d88' `"Y8 d88' `88b  888  d88' `88b `888""8P 
-- 888       888   888  888  888   888  888     
-- 888   .o8 888   888  888  888   888  888     
-- `Y8bod8P' `Y8bod8P' o888o `Y8bod8P' d888b    

--- @class Color a color that can be used in this config.
--- @field red integer The red component.
--- @field green integer The green component.
--- @field blue integer The blue component.
--- @field alpha integer|nil The alpha component, if present.
--- @field mode ColorMode The mode for printing.
Color = {}
Color.__index = Color

--- Create a new color.
--- @param red integer The red component. If above 255, it is clamped to 255.
--- @param green integer The green component. If above 255, it is clamped to 255.
--- @param blue integer The blue component. If above 255, it is clamped to 255.
--- @param alpha_or_mode integer|ColorMode? The alpha component. If present and above 255, it is clamped to 255.
--- @param mode ColorMode? The color mode. Defaults to "hex" if not present.
--- @return Color color The constructed color.
function Color.new(red, green, blue, alpha_or_mode, mode)
    red = clamp(red, 0, 255)
    green = clamp(green, 0, 255)
    blue = clamp(blue, 0, 255)
    local alpha
    if alpha_or_mode and type(alpha_or_mode) == "string" then
        mode = alpha_or_mode
    elseif alpha_or_mode and type(alpha_or_mode) == "number" then
        alpha = clamp(alpha_or_mode, 0, 255)
    end

    if alpha_or_mode == nil and mode == nil then
        mode = "hex"
    end

    local self = {
        red = red,
        green = green,
        blue = blue,
        alpha = alpha,
        mode = mode
    }

    self = setmetatable(self, Color)

    return self
end

--- Create a new color from a hex string of the format '#rrggbb' or 'rrggbb'.
--- @param str string The hex string to parse.
--- @param mode ColorMode? The mode to express the color.
--- @return Color color The parsed color.
function Color.fromhex(str, mode)
    local patt = "#?(%x%x)(%x%x)(%x%x)"
    local redr, greenr, bluer = string.match(str, patt)
    if redr == nil or greenr == nil or bluer == nil then
        error("unable to parse '" .. str .. "' as a color hex code")
    end

    local red = tonumber(redr, 16)
    local green = tonumber(greenr, 16)
    local blue = tonumber(bluer, 16)

    return Color.new(red, green, blue, 255, mode)
end

--- Create a new color from a hexa string of the format '#rrggbbaa' or 'rrggbbaa'.
--- @param str string The hex string to parse.
--- @param mode ColorMode? The mode to express the color.
--- @return Color color The parsed color.
function Color.fromhexa(str, mode)
    local patt = "#?(%x%x)(%x%x)(%x%x)(%x%x)"
    local redr, greenr, bluer, alphar = string.match(str, patt)
    if redr == nil or greenr == nil or bluer == nil or alphar == nil then
        error("unable to parse '" .. str .. "' as a color hex code")
    end

    local red = tonumber(redr, 16)
    local green = tonumber(greenr, 16)
    local blue = tonumber(bluer, 16)
    local alpha = tonumber(alphar, 16)

    return Color.new(red, green, blue, alpha, mode)
end

--- Set the red component of the Color.
--- @param red integer The red component. Clamped to 0, 255.
function Color:setr(red)
    red = clamp(red, 0, 255)
    self.red = red
end

--- Set the green component of the Color.
--- @param green integer The green component. Clamped to 0, 255.
function Color:setg(green)
    green = clamp(green, 0, 255)
    self.green = green
end

--- Set the blue component of the Color.
--- @param blue integer The blue component. Clamped to 0, 255.
function Color:setb(blue)
    blue = clamp(blue, 0, 255)
    self.blue = blue
end

--- Set the alpha component of the Color.
--- @param alpha integer The alpha component. Clamped to 0, 255.
function Color:seta(alpha)
    alpha = clamp(alpha, 0, 255)
    self.alpha = alpha
end

--- Set the red component of the Color, returning it.
--- @param red integer The red component to set.
--- @return Color
function Color:withr(red)
    self:setr(red)
    return self
end

--- Set the green component of the Color, returning it.
--- @param green integer The red component to set.
--- @return Color
function Color:withg(green)
    self:setg(green)
    return self
end

--- Set the blue component of the Color, returning it.
--- @param blue integer The red component to set.
--- @return Color
function Color:withb(blue)
    self:setb(blue)
    return self
end

--- Set the alpha component of the Color, returning it.
--- @param alpha integer The red component to set.
--- @return Color
function Color:witha(alpha)
    self:seta(alpha)
    return self
end

--- Returns the complementary colour of self, preserving the alpha and mode.
--- @return Color color The inverted color.
function Color:invert()
    local newred = 255 - self.red
    local newgreen = 255 - self.green
    local newblue = 255 - self.blue

    return Color.new(newred, newgreen, newblue, self.alpha, self.mode)
end

Color.__unm = Color.invert

--- Express the Color as an 'rgb(rrggbb)' string suitable for Hyprland.
--- @return string rgb The constructed rgb string.
function Color:rgb()
    local redstr = string.format("%02x", self.red)
    local greenstr = string.format("%02x", self.green)
    local bluestr = string.format("%02x", self.blue)

    return "rgb(" .. redstr .. greenstr .. bluestr .. ")"
end

--- Express the Color as an 'rgba(rrggbbaa)' string suitable for Hyprland.
--- @return string rgba The constructed rgba string.
function Color:rgba()
    local redstr = string.format("%02x", self.red)
    local greenstr = string.format("%02x", self.green)
    local bluestr = string.format("%02x", self.blue)
    local alpha = string.format("%02x", self.alpha or 255)

    return "rgba(" .. redstr .. greenstr .. bluestr .. alpha .. ")"
end

--- Express the Color as an 'rgb(rrr,ggg,bbb)' string suitable for Hyprland.
--- @return string rgbdec The constructed rgb string.
function Color:rgbdec()
    local redstr = tostring(self.red)
    local greenstr = tostring(self.green)
    local bluestr = tostring(self.blue)

    return "rgb(" .. redstr .. "," .. greenstr .. "," .. bluestr .. ")"
end

--- Express the Color as an 'rgba(rrr,ggg,bbb,a.aa)' string suitable for Hyprland.
--- @return string rgbadec The constructed rgba string.
function Color:rgbadec()
    local redstr = tostring(self.red)
    local greenstr = tostring(self.green)
    local bluestr = tostring(self.blue)
    local alpha = string.format("%.3f", (self.alpha or 255) / 255)

    return "rgba(" .. redstr .. "," .. greenstr .. "," .. bluestr .. "," .. alpha .. ")"
end

--- Convert the color to a hex string formatted '#rrggbb'.
--- @return string hex The formatted hex string.
function Color:hex()
    local redstr = string.format("%02x", self.red)
    local greenstr = string.format("%02x", self.green)
    local bluestr = string.format("%02x", self.blue)

    return "#" .. redstr .. greenstr .. bluestr
end

--- Convert the color to a hex string formatted '#rrggbbaa' (including alpha component).
--- @return string hexa The formatted hexa string.
function Color:hexa()
    local redstr = string.format("%02x", self.red)
    local greenstr = string.format("%02x", self.green)
    local bluestr = string.format("%02x", self.blue)
    local alpha = string.format("%02x", self.alpha or 255)

    return "#" .. redstr .. greenstr .. bluestr .. alpha
end

--- Convert the color to a legacy ARGB string formatted '0xaarrggbb'.
--- @return string argb The formatted argb string.
function Color:argb()
    local alpha = string.format("%02x", self.alpha or 255)
    local redstr = string.format("%02x", self.red)
    local greenstr = string.format("%02x", self.green)
    local bluestr = string.format("%02x", self.blue)

    return "0x" .. alpha .. redstr .. greenstr .. bluestr
end

--- Convert the color according to the `mode` passed.
--- @param mode ColorMode The mode to use.
--- @return string str The formatted string.
function Color:as_mode(mode)
    if mode == "rgb" then
        return self:rgb()
    elseif mode == "rgba" then
        return self:rgba()
    elseif mode == "rgbdec" then
        return self:rgbdec()
    elseif mode == "rgbadec" then
        return self:rgbadec()
    elseif mode == "hex" then
        return self:hex()
    elseif mode == "hexa" then
        return self:hexa()
    elseif mode == "argb" then
        return self:argb()
    else
        return self:rgba() -- fallback
    end
end

--- Convert the color to a hex string formatted '#xxxxxx'.
--- @return string str The formatted string.
function Color:tostring()
    return self:as_mode(self.mode)
end

Color.__tostring = Color.tostring

--- Convert the color into an object suitable for Hyprland.
--- @return string str A string formatted for Hyprland.
function Color:as_hl_col()
    return self:tostring()
end

--- Alias for Color:as_hl_col.
--- @return string str A string formatted for Hyprland.
function Color:as_hl()
    return self:as_hl_col()
end

--                                     .o8   o8o                            .   
--                                    "888   `"'                          .o8   
--  .oooooooo oooo d8b  .oooo.    .oooo888  oooo   .ooooo.  ooo. .oo.   .o888oo 
-- 888' `88b  `888""8P `P  )88b  d88' `888  `888  d88' `88b `888P"Y88b    888   
-- 888   888   888      .oP"888  888   888   888  888ooo888  888   888    888   
-- `88bod8P'   888     d8(  888  888   888   888  888    .o  888   888    888 . 
-- `8oooooo.  d888b    `Y888""8o `Y8bod88P" o888o `Y8bod8P' o888o o888o   "888" 
-- d"     YD                                                                    
-- "Y88888P'                                                                    

--- @class Gradient
--- @field cols Color[] the colours in the gradient.
--- @field angle integer the angle of the gradient.
--- @field mode ColorMode the mode of the gradient to print.
Gradient = {}
Gradient.__index = Gradient

--- Construct a new Gradient.
--- @param cols Color[] the colours in the gradient.
--- @param angle integer the angle of the gradient.
--- @param mode ColorMode? the mode of the gradient to print.
--- @return Gradient grad the constructed gradient.
function Gradient.new(cols, angle, mode)
    if #cols == 0 then
        error("Gradient colors must contain at least one element")
    end

    if mode == nil then
        mode = cols[1].mode
    end

    local self = {
        cols = cols,
        angle = angle,
        mode = mode
    }

    self = setmetatable(self, Gradient)

    return self
end

--- Add a new color to the gradient.
--- @param color Color The new color to add.
function Gradient:add_color(color)
    if #self.cols >= 10 then
        error("Maximum 10 colors can be added to a gradient")
    end
    if self.mode then
        color.mode = self.mode
    end
    table.insert(self.cols, color)
end

--- Insert a new color to the gradient at position `idx`.
--- @param color Color The new color to add.
--- @param idx integer The position of the color.
function Gradient:insert_color(color, idx)
    if #self.cols >= 10 then
        error("Maximum 10 colors can be added to a gradient")
    end
    if self.mode then
        color.mode = self.mode
    end
    table.insert(self.cols, idx, color)
end

--- The number of colors in the Gradient.
--- @return integer size
function Gradient:len()
    return #self.cols
end

Gradient.__len = Gradient.len

--- Convert the Gradient to a string.
--- @return string str The converted string.
function Gradient:tostring()
    local colorlist = ""
    for i = 1,#self.cols do
        colorlist = colorlist .. self.cols[i]:as_mode(self.mode)
        if i < #self.cols then
            colorlist = colorlist .. ", "
        end
    end

    return "Gradient([" .. colorlist .. "], " .. self.angle .. ")"
end

Gradient.__tostring = Gradient.tostring

--- Express the gradient as an HL.Gradient object.
--- @return HL.Gradient
function Gradient:as_hl_grad()
    local outcols = {}
    for _, c in ipairs(self.cols) do
        table.insert(outcols, c:as_mode(self.mode))
    end
    return {
        colors = outcols,
        angle = self.angle
    }
end

--- Alias for Gradient:as_hl_grad.
--- @return HL.Gradient
function Gradient:as_hl()
    return self:as_hl_grad()
end

--                                  .o88o.  o8o             
--                                  888 `"  `"'             
--  .ooooo.   .ooooo.  ooo. .oo.   o888oo  oooo   .oooooooo 
-- d88' `"Y8 d88' `88b `888P"Y88b   888    `888  888' `88b  
-- 888       888   888  888   888   888     888  888   888  
-- 888   .o8 888   888  888   888   888     888  `88bod8P'  
-- `Y8bod8P' `Y8bod8P' o888o o888o o888o   o888o `8oooooo.  
--                                               d"     YD  
--                                               "Y88888P'  

--- @type ColorMode
col.default_mode = "rgba"

col.borders = {
    active = Gradient.new({ Color.fromhex("#a9c8fd"), Color.fromhex("#0a305d") }, 45, col.default_mode),
    inactive = Gradient.new({ Color.fromhex("#505050"), Color.fromhex("#808080") } , 45, col.default_mode),
    nogroup = {
        active = Color.fromhex("#ff7667", col.default_mode),
        inactive = Color.fromhex("#690005", col.default_mode),
    }
}

col.group = {
    active = Gradient.new({ Color.fromhex("#eab5ec"), Color.fromhex("#48214d") }, 45, col.default_mode),
    inactive = Gradient.new({ Color.fromhex("#505050"), Color.fromhex("#808080") } , 45, col.default_mode),
    locked = {
        active = Color.fromhex("#ff5500", col.default_mode):witha(0x66),
        inactive = Color.fromhex("#775500", col.default_mode):witha(0x66),
    },
    groupbar = {
        active = Color.fromhex("#a9c8fd", col.default_mode),
        inactive = Color.fromhex("#808080", col.default_mode),
    }
}

return col