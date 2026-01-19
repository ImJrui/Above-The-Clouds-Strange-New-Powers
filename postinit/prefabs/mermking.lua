local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local function BonestaffPreserverRate(inst, item)
	return (item ~= nil and item.prefab == "bonestaff") and 0 or nil
end

local function item_is_trident(item) return item.prefab == "bonestaff" or item.prefab == "trident" end
local function item_is_crown(item) return item.prefab == "ruinshat" end
local function item_is_marblearmor(item) return item.prefab == "armor_metalplate" or item.prefab == "armormarble" end

local function HasTrident(inst)
    return (inst.components.inventory:FindItem(item_is_trident) ~= nil)
end

local function HasCrown(inst)
    return (inst.components.inventory:FindItem(item_is_crown) ~= nil)
end

local function HasPauldron(inst)
    return (inst.components.inventory:FindItem(item_is_marblearmor) ~= nil)
end

AddPrefabPostInit("mermking", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(BonestaffPreserverRate)

    local _test = inst.components.trader.test
    inst.components.trader.test = function(inst, item, giver)
        local giver_skilltreeupdater = giver.components.skilltreeupdater
        if TheWorld:HasTag("porkland") and giver:HasTag("merm") and giver_skilltreeupdater then
            if (item.prefab == "bonestaff"
                and giver_skilltreeupdater:IsActivated("wurt_mermkingtrident")
                and inst.components.inventory:FindItem(item_is_trident) == nil)
                or
                ((item.prefab == "armor_metalplate")
                and giver_skilltreeupdater:IsActivated("wurt_mermkingshoulders")
                and inst.components.inventory:FindItem(item_is_marblearmor) == nil )
            then
                return true
            end
        end

        if _test then
            return _test(inst, item, giver)
        end
    end

    local _onaccept = inst.components.trader.onaccept
    inst.components.trader.onaccept = function(inst, giver, item)
        if TheWorld:HasTag("porkland") then
            if item.prefab == "bonestaff" then
                inst.sg:GoToState("get_trident")
                TheWorld:PushEvent("onmermkingtridentadded")
            elseif item.prefab == "armor_metalplate" and not inst._shoulders_data then
                inst.sg:GoToState("get_pauldron")
                TheWorld:PushEvent("onmermkingpauldronadded")
            end
        end

        if _onaccept then
            _onaccept(inst, giver, item)
        end
    end
    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(src, data, newents)
        if TheWorld:HasTag("porkland") then
            if HasTrident(src) then
                src.AnimState:OverrideSymbol("trident", "mermkingswaps", "trident")
                TheWorld:PushEvent("onmermkingtridentadded")
            end

            if HasCrown(src) then
                src.AnimState:OverrideSymbol("crown", "mermkingswaps", "crown")
                TheWorld:PushEvent("onmermkingcrownadded")
            end

            if HasPauldron(src) then
                src.AnimState:OverrideSymbol("shoulder_lilly", "mermkingswaps", "shoulder_lilly")
                TheWorld:PushEvent("onmermkingpauldronadded")
            end
        end

        if _OnLoad then
            _OnLoad(src, data, newents)
        end
    end
end)