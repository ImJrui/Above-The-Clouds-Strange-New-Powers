local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local postinit_fn = function(inst)
    if not TheWorld.ismastersim then
        return
    end
    local _test = inst.components.trader.test

    local skyworthymanager = TheWorld.components.skyworthymanager

    inst.components.trader.test = function(inst, item, giver)
        if item.prefab == skyworthymanager.trinket_pigking then
            return true
        end
        if item:HasTag("irreplaceable") then
            return false
        end
        if _test then
            return _test(inst, item, giver)
        end
    end
end

AddPrefabPostInit("pigking", postinit_fn)