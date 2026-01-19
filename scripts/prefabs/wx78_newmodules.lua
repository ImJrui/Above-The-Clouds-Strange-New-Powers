local ModuleDefs = require("wx78_moduledefs")

local assets =
{
    Asset("ANIM", "anim/wx_newmodules.zip"),

    Asset("SCRIPT", "scripts/wx78_moduledefs.lua"),
}

local function on_module_removed(inst)
    if inst.components.finiteuses ~= nil then
        inst.components.finiteuses:Use()
    end
end

local function MakeModule(data)
    local prefabs = {}
    if data.extra_prefabs ~= nil then
        for _, extra_prefab in ipairs(data.extra_prefabs) do
            table.insert(prefabs, extra_prefab)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("chips")
        inst.AnimState:SetBuild("wx_newmodules")
        inst.AnimState:PlayAnimation(data.name)
        inst.scrapbook_anim = data.name

        if data.slots > 4 then
            MakeInventoryFloatable(inst, "med", 0.1, 0.75)
        else
            MakeInventoryFloatable(inst, nil, 0.1, (data.slots == 1 and 0.75) or 1.0)
        end

        --------------------------------------------------------------------------
        -- For client-side access to information that should not be mutated
        inst._netid = data.module_netid
        inst._slots = data.slots

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        --------------------------------------------------------------------------
        inst:AddComponent("inspectable")

        --------------------------------------------------------------------------
        inst:AddComponent("inventoryitem")

        --------------------------------------------------------------------------
        inst:AddComponent("upgrademodule")
        inst.components.upgrademodule:SetRequiredSlots(data.slots)
        inst.components.upgrademodule.onactivatedfn = data.activatefn
        inst.components.upgrademodule.ondeactivatedfn = data.deactivatefn
        inst.components.upgrademodule.onremovedfromownerfn = on_module_removed

        --------------------------------------------------------------------------
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.WX78_MODULE_USES)
        inst.components.finiteuses:SetUses(TUNING.WX78_MODULE_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        return inst
    end

    return Prefab("wx78module_"..data.name, fn, assets, prefabs)
end

local module_prefabs = {}

--new modules

local new_modules = {}

local EXTRA_DRYRATE = 2

local ATTACH_RADIUS = {}
ATTACH_RADIUS[1] = 5
ATTACH_RADIUS[2] = 10

local function fan_undryallies(inst)
	if inst.PorklandRebalance_LastDriedPlayers then
		for i, v in ipairs(inst.PorklandRebalance_LastDriedPlayers) do
			if v.PorklandRebalance_DryCount then
				v.PorklandRebalance_DryCount = v.PorklandRebalance_DryCount - 1
				if v.PorklandRebalance_DryCount == 0 then
					v:RemoveTag("PorklandRebalance_WX_FogImmune_Ally")
					v.components.grogginess.OnFogProofChange(v)
				end
			end
		end
	end
	inst.PorklandRebalance_LastDriedPlayers = {}
end

local function fan_dryallies(inst)
	inst.PorklandRebalance_numfan = (inst.PorklandRebalance_numfan or 0)
	
    local x, y, z = inst.Transform:GetWorldPosition()
	local all_targets = FindPlayersInRange(x, y, z, ATTACH_RADIUS[inst.PorklandRebalance_numfan] or 0, true)
	
	local new_lastdried = {}
	for i = 1, #all_targets do
		local player = all_targets[i]
		if player ~= inst then
			player:AddTag("PorklandRebalance_WX_FogImmune_Ally")
			player.components.grogginess.OnFogProofChange(player)
			player.PorklandRebalance_DryCount = (player.PorklandRebalance_DryCount or 0) + 1
			new_lastdried[#new_lastdried + 1] = player
		end
	end
	
	fan_undryallies(inst)
	
	inst.PorklandRebalance_LastDriedPlayers = new_lastdried
end

local function fan_activate(inst, wx)
	wx.PorklandRebalance_numfan = (wx.PorklandRebalance_numfan or 0) + 1
	wx:AddTag("PorklandRebalance_WX_FogImmune")
	wx.components.grogginess.OnFogProofChange(wx)

    wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate + EXTRA_DRYRATE
    wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate + EXTRA_DRYRATE
		
	if not wx.dryallies then wx.dryallies = wx:DoPeriodicTask(1, fan_dryallies) end

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(1)
    end
end

local function fan_deactivate(inst, wx)
	wx.PorklandRebalance_numfan = (wx.PorklandRebalance_numfan or 0) - 1
	if wx.PorklandRebalance_numfan == 0 then
		wx:RemoveTag("PorklandRebalance_WX_FogImmune")
		wx.components.grogginess.OnFogProofChange(wx)
		
		if wx.dryallies then
			fan_undryallies(inst)
			wx.dryallies:Cancel()
			wx.dryallies = nil
		end
	end

    wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate - EXTRA_DRYRATE
    wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate - EXTRA_DRYRATE

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(-1)
    end
end

local FAN_MODULE_DATA =
{
    name = "porklandrebalance_fan",
    slots = 3,
    activatefn = fan_activate,
    deactivatefn = fan_deactivate,
}

ModuleDefs.AddCreatureScanDataDefinition("gnat", "porklandrebalance_fan", 1)
new_modules[#new_modules + 1] = FAN_MODULE_DATA

local function filter_activate(inst, wx)
	wx.PorklandRebalance_numfilter = (wx.PorklandRebalance_numfilter or 0) + 1
	wx:AddTag("PorklandRebalance_WX_GasMask")
	if wx.PorklandRebalance_numfilter == 2 then
		wx:AddTag("prevents_hayfever")
	end
end

local function filter_deactivate(inst, wx)
	wx.PorklandRebalance_numfilter = (wx.PorklandRebalance_numfilter or 0) - 1
	wx:RemoveTag("prevents_hayfever")
	if wx.PorklandRebalance_numfilter == 0 then
		wx:RemoveTag("PorklandRebalance_WX_GasMask")
	end
end

local FILTER_MODULE_DATA =
{
    name = "porklandrebalance_filter",
    slots = 3,
    activatefn = filter_activate,
    deactivatefn = filter_deactivate,
}

ModuleDefs.AddCreatureScanDataDefinition("pangolden", "porklandrebalance_filter", 6)
new_modules[#new_modules + 1] = FILTER_MODULE_DATA

for _, def in ipairs(new_modules) do
	ModuleDefs.AddNewModuleDefinition(def)
    table.insert(module_prefabs, MakeModule(def))
end

return unpack(module_prefabs)
