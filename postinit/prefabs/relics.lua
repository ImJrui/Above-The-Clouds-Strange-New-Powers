local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

--relics
AddPrefabPostInit("relics_4", function (inst)
    inst:AddTag("irreplaceable")
end)

AddPrefabPostInit("relics_5", function (inst)
    inst:AddTag("irreplaceable")
end)

local function CanNotMineRelicBeforDislodged(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    
    if not inst.components.workable or not inst.components.dislodgeable then
        return
    end
    
    inst.components.workable:SetWorkAction(nil)
    
    local _ondislodgedfn = inst.components.dislodgeable.ondislodgedfn
    
    local function ondislodgedfn(inst)
        if _ondislodgedfn then
            _ondislodgedfn(inst)
        end
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
    end
    inst.components.dislodgeable:SetOnDislodgedFn(ondislodgedfn)
end

AddPrefabPostInit("pig_ruins_sow", CanNotMineRelicBeforDislodged)
AddPrefabPostInit("pig_ruins_truffle", CanNotMineRelicBeforDislodged)