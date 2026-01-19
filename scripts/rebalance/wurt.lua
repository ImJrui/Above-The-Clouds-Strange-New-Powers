local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

--Wurt

local FISH_PICKUP_TRANSFORMDATA = {
	["fish"] = { "pondfish", nil },
	["coi"] = { "pondcoi", "coi" },
}

local function WurtFishyPickup(inst, pickupguy, src_pos)
	if pickupguy.prefab == "wurt" and inst.floptask ~= nil then
		local pickupinstdata = FISH_PICKUP_TRANSFORMDATA[inst.prefab]
		local pondFish = SpawnPrefab(pickupinstdata[1])
		if pickupinstdata[2] then
			pondFish.components.inventoryitem:ChangeImageName(pickupinstdata[2])
		end
		pickupguy.components.inventory:GiveItem(pondFish, nil, Vector3(inst.Transform:GetWorldPosition()))
		inst:Remove()
		return true
	end
    if inst.PORKLANDREBALANCE_WURTFISHY then
        return inst:PORKLANDREBALANCE_WURTFISHY()
    end
end

function WurtFishy(inst)
    if not TheWorld.ismastersim then
        return
    end
	inst.PORKLANDREBALANCE_WURTFISHY = inst.components.inventoryitem.onpickupfn
    inst.components.inventoryitem:SetOnPickupFn(WurtFishyPickup)
end

local function on_is_coi(inst)
    if inst._is_coi:value() then
        inst.AnimState:SetBank("coi")
        inst.AnimState:SetBuild("coi")
        inst:SetPrefabNameOverride("coi")

        if TheWorld.ismastersim then
            inst.components.inventoryitem:ChangeImageName("coi")
        end
    end
end

function ReskinWurtFishy(inst)

    inst._is_coi = net_bool(inst.GUID, "pondfish._is_coi", "on_is_coi")
    inst:ListenForEvent("on_is_coi", on_is_coi)
	
	if inst.is_coi then
        inst._is_coi:set(true)
    end

    if not TheWorld.ismastersim then
        return
    end
	
    local on_save = inst.OnSave or function() end
    inst.OnSave = function(inst, data, ...)
        if inst._is_coi:value() then
            data._is_coi = true
        end
        return on_save(inst, data, ...)
    end

    local on_load = inst.OnLoad or function() end
    inst.OnLoad = function(inst, data, ...)
        if data and data._is_coi then
            inst._is_coi:set(true)
        end
        return on_load(inst, data, ...)
    end
end

AddPrefabPostInit("coi", WurtFishy)
AddPrefabPostInit("fish", WurtFishy)

AddPrefabPostInit("pondfish", ReskinWurtFishy)

--trawling

local LOOT_DEFS = require("prefabs/trawlnet_loot_defs")
local _GetLootTable = LOOT_DEFS.GetLootTable
local LILYPOND_LOOT = LOOT_DEFS.LILYPOND_LOOT

local WURT_COIREPLACE = {
	["coi"] = "pondcoi",
}

local WURT_LILYPOND = {}

for i = 1, #LILYPOND_LOOT do
	local repl = WURT_COIREPLACE[LILYPOND_LOOT[i][1]]
	WURT_LILYPOND[i] = LILYPOND_LOOT[i]
	if repl then WURT_LILYPOND[i][1] = repl end
end

function LOOT_DEFS.GetLootTable(inst)

	local owner = inst.components.inventoryitem.owner
    local sailor = nil

    if owner and owner.components.sailable then
        sailor = owner.components.sailable.sailor
    end
	
	if sailor.prefab == "wurt" then return WURT_LILYPOND end
	
    return _GetLootTable(inst)
end

