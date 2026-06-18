local ModuleDefs = require("wx78_moduledefs")

GLOBAL.setfenv(1, GLOBAL)

local EXTRA_DRYRATE = 2

local ATTACH_RADIUS = {
    [1] = 5,
    [2] = 10,
}

local function NotifyFogProofChange(ent)
    local grogginess = ent ~= nil and ent.components ~= nil and ent.components.grogginess or nil
    if grogginess ~= nil and grogginess.OnFogProofChange ~= nil then
        grogginess.OnFogProofChange(ent)
    end
end

local function fan_undryallies(wx)
    if wx.PorklandRebalance_LastDriedPlayers ~= nil then
        for _, player in ipairs(wx.PorklandRebalance_LastDriedPlayers) do
            if player ~= nil and player:IsValid() and player.PorklandRebalance_DryCount ~= nil then
                player.PorklandRebalance_DryCount = player.PorklandRebalance_DryCount - 1
                if player.PorklandRebalance_DryCount <= 0 then
                    player.PorklandRebalance_DryCount = nil
                    player:RemoveTag("PorklandRebalance_WX_FogImmune_Ally")
                    NotifyFogProofChange(player)
                end
            end
        end
    end
    wx.PorklandRebalance_LastDriedPlayers = {}
end

local function fan_dryallies(wx)
    wx.PorklandRebalance_numfan = wx.PorklandRebalance_numfan or 0

    local fan_count = math.min(wx.PorklandRebalance_numfan, #ATTACH_RADIUS)
    local x, y, z = wx.Transform:GetWorldPosition()
    local all_targets = FindPlayersInRange(x, y, z, ATTACH_RADIUS[fan_count] or 0, true)

    local new_lastdried = {}
    for i = 1, #all_targets do
        local player = all_targets[i]
        if player ~= wx and player:IsValid() then
            player:AddTag("PorklandRebalance_WX_FogImmune_Ally")
            player.PorklandRebalance_DryCount = (player.PorklandRebalance_DryCount or 0) + 1
            NotifyFogProofChange(player)
            new_lastdried[#new_lastdried + 1] = player
        end
    end

    fan_undryallies(wx)

    wx.PorklandRebalance_LastDriedPlayers = new_lastdried
end

local function fan_activate(inst, wx)
    if wx == nil then
        return
    end

    wx.PorklandRebalance_numfan = (wx.PorklandRebalance_numfan or 0) + 1
    wx:AddTag("PorklandRebalance_WX_FogImmune")
    NotifyFogProofChange(wx)

    if wx.components.moisture ~= nil then
        wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate + EXTRA_DRYRATE
        wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate + EXTRA_DRYRATE
        inst.PorklandRebalance_MoistureApplied = true
    end

    if wx.dryallies == nil and wx.DoPeriodicTask ~= nil then
        wx.dryallies = wx:DoPeriodicTask(1, fan_dryallies)
    end

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(1)
        inst.PorklandRebalance_TemperatureApplied = true
    end
end

local function fan_deactivate(inst, wx)
    if wx == nil then
        return
    end

    wx.PorklandRebalance_numfan = math.max(0, (wx.PorklandRebalance_numfan or 1) - 1)
    if wx.PorklandRebalance_numfan == 0 then
        wx:RemoveTag("PorklandRebalance_WX_FogImmune")
        NotifyFogProofChange(wx)

        if wx.dryallies ~= nil then
            fan_undryallies(wx)
            wx.dryallies:Cancel()
            wx.dryallies = nil
        end
    end

    if inst.PorklandRebalance_MoistureApplied and wx.components.moisture ~= nil then
        wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate - EXTRA_DRYRATE
        wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate - EXTRA_DRYRATE
    end
    inst.PorklandRebalance_MoistureApplied = nil

    if inst.PorklandRebalance_TemperatureApplied and wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(-1)
    end
    inst.PorklandRebalance_TemperatureApplied = nil
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

local function update_filter_tags(wx)
    local numfilter = math.max(0, wx.PorklandRebalance_numfilter or 0)
    wx.PorklandRebalance_numfilter = numfilter

    if numfilter > 0 then
        wx:AddTag("PorklandRebalance_WX_GasMask")
    else
        wx:RemoveTag("PorklandRebalance_WX_GasMask")
    end

    if numfilter >= 2 then
        wx:AddTag("prevents_hayfever")
    else
        wx:RemoveTag("prevents_hayfever")
    end
end

local function filter_activate(inst, wx)
    if wx == nil then
        return
    end

    wx.PorklandRebalance_numfilter = (wx.PorklandRebalance_numfilter or 0) + 1
    update_filter_tags(wx)
end

local function filter_deactivate(inst, wx)
    if wx == nil then
        return
    end

    wx.PorklandRebalance_numfilter = math.max(0, (wx.PorklandRebalance_numfilter or 1) - 1)
    update_filter_tags(wx)
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

local function AddModuleDefinition(data)
    for _, module_def in ipairs(ModuleDefs.module_definitions) do
        if module_def.name == data.name then
            return
        end
    end

    ModuleDefs.AddNewModuleDefinition(data)
    table.insert(ModuleDefs.module_definitions, data)
end

ModuleDefs.AddCreatureScanDataDefinition("gnat", "porklandrebalance_fan", 1)
ModuleDefs.AddCreatureScanDataDefinition("peagawk", "porklandrebalance_filter", 4)

AddModuleDefinition(FAN_MODULE_DATA)
AddModuleDefinition(FILTER_MODULE_DATA)
