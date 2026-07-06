GLOBAL.setfenv(1, GLOBAL)

local wx78_moduledefs = require("wx78_moduledefs")
local module_definitions = wx78_moduledefs.module_definitions
local AddNewModuleDefinition = wx78_moduledefs.AddNewModuleDefinition
local GetModuleDefinitionFromNetID = wx78_moduledefs.GetModuleDefinitionFromNetID
local AddCreatureScanDataDefinition = wx78_moduledefs.AddCreatureScanDataDefinition
local GetCreatureScanDataDefinition = wx78_moduledefs.GetCreatureScanDataDefinition
local AddSpecialCreatureScanDataDefinition = wx78_moduledefs.AddSpecialCreatureScanDataDefinition

local ATTACH_RADIUS = {
    [0] = 0,
    [1] = 4,
    [2] = 6,
}

local ATTACH_BONUS = {
    [0] = 1.0,
    [1] = 0.6,
    [2] = 0.3,
}

local function fan_activate(inst, wx)
    wx._fan_modules = (wx._fan_modules or 0) + 1

    if not wx.components.upgrademodulebuff then
        wx:AddComponent("upgrademodulebuff")
    end

    local data = {
        radius = ATTACH_RADIUS[wx._fan_modules] or ATTACH_RADIUS[#ATTACH_RADIUS],
        bonus = wx._fan_modules,
        onattachedfn = function(player)
            if not player:HasTag("immunefog") then
                player:AddTag("immunefog")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end,
        ondetachedfn = function(player)
            if player:HasTag("immunefog") then
                player:RemoveTag("immunefog")
            end
            if player.components.grogginess then
                player.components.grogginess.OnFogProofChange(player)
            end
        end,
        onupdatedfn = function(player, bonus)
            player.fogover_alpha = ATTACH_BONUS[bonus] or ATTACH_BONUS[#ATTACH_BONUS]
        end,
    }

    wx.components.upgrademodulebuff:AddAuraSource("fan_module_buff", data)
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
                bonus = wx._fan_modules,
            }
            wx.components.upgrademodulebuff:UpdateAura("fan_module_buff", data)
        else
            wx.components.upgrademodulebuff:RemoveAura("fan_module_buff")
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

AddNewModuleDefinition(FAN_MODULE_DATA)
---------------------------------------------------------------

local function filter_activate(inst, wx)
    wx._filter_modules = (wx._filter_modules or 0) + 1

    if not wx.components.upgrademodulebuff then
        wx:AddComponent("upgrademodulebuff")
    end

    local data = {
        radius = ATTACH_RADIUS[wx._filter_modules] or ATTACH_RADIUS[#ATTACH_RADIUS],
        bonus = wx._filter_modules,
        onattachedfn = function(player)
            if not player:HasTag("immunehayfever") then
                player:AddTag("immunehayfever")
            end
        end,
        ondetachedfn = function(player)
            if player:HasTag("immunehayfever") then
                player:RemoveTag("immunehayfever")
            end
        end
    }

    wx.components.upgrademodulebuff:AddAuraSource("filter_module_buff", data)
end

local function filter_deactivate(inst, wx)
    wx._filter_modules = (wx._filter_modules or 1) - 1
    if wx._filter_modules <= 0 then
        wx._filter_modules = nil
    end

    if wx.components.upgrademodulebuff then
        if wx._filter_modules and wx._filter_modules > 0 then
            local data = {
                radius = ATTACH_RADIUS[wx._filter_modules] or ATTACH_RADIUS[#ATTACH_RADIUS],
                bonus = wx._filter_modules,
            }
            wx.components.upgrademodulebuff:UpdateAura("filter_module_buff", data)
        else
            wx.components.upgrademodulebuff:RemoveAura("filter_module_buff")
        end
    end
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

AddNewModuleDefinition(FILTER_MODULE_DATA)
