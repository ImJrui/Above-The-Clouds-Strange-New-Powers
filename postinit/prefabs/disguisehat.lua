local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("disguisehat", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local equippable = inst.components.equippable
    if equippable == nil then
        return
    end

    local _onequip = equippable.onequipfn
    local _onunequip = equippable.onunequipfn

    equippable:SetOnEquip(function(inst, owner)
        owner:AddTag("indisguise")
        if _onequip ~= nil then
            _onequip(inst, owner)
        end
    end)

    equippable:SetOnUnequip(function(inst, owner)
        owner:RemoveTag("indisguise")
        if _onunequip ~= nil then
            _onunequip(inst, owner)
        end
    end)
end)
