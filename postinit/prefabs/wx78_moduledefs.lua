GLOBAL.setfenv(1, GLOBAL)

local wx78_moduledefs = require("wx78_moduledefs")
local module_definitions = wx78_moduledefs.module_definitions
local AddNewModuleDefinition = wx78_moduledefs.AddNewModuleDefinition
local GetModuleDefinitionFromNetID = wx78_moduledefs.GetModuleDefinitionFromNetID
local AddCreatureScanDataDefinition = wx78_moduledefs.AddCreatureScanDataDefinition
local GetCreatureScanDataDefinition = wx78_moduledefs.GetCreatureScanDataDefinition
local AddSpecialCreatureScanDataDefinition = wx78_moduledefs.AddSpecialCreatureScanDataDefinition

local EXTRA_DRYRATE = 2

local ATTACH_RADIUS = {
    [1] = 4,
    [2] = 6,
}

local function fan_activate(inst, wx)
    wx._fan_modules = (wx._fan_modules or 0) + 1

    if not wx.components.upgrademodulebuff then
        wx:AddComponent("upgrademodulebuff")
    end

    local data = {
        radius = ATTACH_RADIUS[wx._fan_modules] or ATTACH_RADIUS[#ATTACH_RADIUS],
        number = wx._fan_modules,
        onattachedfn = function(player)
            if not player:HasTag("fan_module_buff") then
                player:AddTag("fan_module_buff")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end,
        ondetachedfn = function(player)
            if player:HasTag("fan_module_buff") then
                player:RemoveTag("fan_module_buff")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end
    }

    wx.components.upgrademodulebuff:SetBuffer("fan_module_buff", data)
end

local function fan_deactivate(inst, wx)
    wx._fan_modules = (wx._fan_modules or 1) - 1
    if wx._fan_modules <= 0 then
        wx._fan_modules = nil
    end

    if wx.components.upgrademodulebuff then
        if wx._fan_modules and wx._fan_modules > 0 then
            local data = {
                radius = ATTACH_RADIUS[wx._fan_modules] or ATTACH_RADIUS[#ATTACH_RADIUS],
                number = wx._fan_modules,
            }
            wx.components.upgrademodulebuff:UpdateBuffer("fan_module_buff", data)
        else
            wx.components.upgrademodulebuff:RemoveBuffer("fan_module_buff")
        end
    end
end

local FAN_MODULE_DATA =
{
    name = "porklandrebalance_fan",
    type = CIRCUIT_BARS.BETA,
    slots = 3,
    activatefn = fan_activate,
    deactivatefn = fan_deactivate,
    overridebank = "chips",
    overridebuild = "wx_newmodules",
    overrideuibuild = "wx_circuits_porkland",
    overrideminiuibuild = "pl_status_wx",
}
table.insert(module_definitions, FAN_MODULE_DATA)

AddCreatureScanDataDefinition("gnat", "porklandrebalance_fan", 1)

---------------------------------------------------------------

local function filter_activate(inst, wx)
    wx:AddTag("wx78_filter_module")
end

local function filter_deactivate(inst, wx)
    wx:RemoveTag("wx78_filter_module")
end

local FILTER_MODULE_DATA =
{
    name = "porklandrebalance_filter",
    type = CIRCUIT_BARS.BETA,
    slots = 3,
    activatefn = filter_activate,
    deactivatefn = filter_deactivate,
    overridebank = "chips",
    overridebuild = "wx_newmodules",
    overrideuibuild = "wx_circuits_porkland",
    overrideminiuibuild = "pl_status_wx",
}
table.insert(module_definitions, FILTER_MODULE_DATA)

AddCreatureScanDataDefinition("peagawk", "porklandrebalance_filter", 4)
