local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

---pig queen
AddPrefabPostInit("pigman_queen", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    if inst.components.trader then
        local _ShouldAcceptItem = inst.components.trader.test
        
        inst.components.trader.test = function(inst, item)
            if item.prefab == "pigcrownhat" then
                local head_item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                if head_item and head_item.prefab == "pigcrownhat" then
                    return false
                end
            end
            
            if _ShouldAcceptItem then
                return _ShouldAcceptItem(inst, item)
            end
            
            return false
        end
    end
end)
