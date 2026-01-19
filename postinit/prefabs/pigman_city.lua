local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local wanteditems = {
    ["pigman_storeowner_shopkeep"] = {
        ["radish"] = 1,
        ["aloe"] = 1,
        ["carrot"] = 1,
        ["durian"] = 1,
        ["pomegranate"] = 1,
        ["watermelon"] = 1,
        ["corn"] = 1,
        ["eggplant"] = 1,
        ["pumpkin"] = 2,
        ["tomato"] = 2,
        ["potato"] = 3,
        ["onion"] = 3,
        ["garlic"] = 3,
        ["asparagus"] = 3,
        ["dragonfruit"] = 5,
        ["pepper"] = 5,
    }
}

local function ShouldAcceptItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        return false
    end
    
    if wanteditems[inst.prefab] and wanteditems[inst.prefab][item.prefab]then
        return true
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    local num = wanteditems[inst.prefab] and wanteditems[inst.prefab][item.prefab] or 1
    if item:HasTag("stale") then
        num = math.max(math.floor(num/2), 1)
        inst.components.talker:Say(STRINGS.CITY_PIG_STOREOWNER_ACCEPT_ITEM_STALE)
    elseif item:HasTag("spoiled") then
        num = 1
        inst.components.talker:Say(STRINGS.CITY_PIG_STOREOWNER_ACCEPT_ITEM_SPOILED)
    else
        inst.components.talker:Say(STRINGS.CITY_PIG_STOREOWNER_ACCEPT_ITEM)
    end

    for i = 1, num do
        giver.components.inventory:GiveItem(SpawnPrefab("oinc"))
    end
end

local function TradeExtraItems(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.trader then
        local _ShouldAcceptItem = inst.components.trader.test
        inst.components.trader.test = function(inst, item)
            if ShouldAcceptItem(inst, item) then
                return true
            end

            if _ShouldAcceptItem then
                return _ShouldAcceptItem(inst, item)
            end
            
            return false
        end

        local _onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            if wanteditems[inst.prefab] and wanteditems[inst.prefab][item.prefab] then
                return OnGetItemFromPlayer(inst, giver, item)
            end
            
            if _onaccept then
                return _onaccept(inst, giver, item)
            end
        end
    end
end

AddPrefabPostInit("pigman_storeowner_shopkeep", TradeExtraItems)