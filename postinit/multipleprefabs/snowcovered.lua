local AddPrefabPostInitAny = AddPrefabPostInitAny
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInitAny(function(inst)
    if not inst:HasTag("SnowCovered") then
        return
    end

    -- Saved entities and newly built structures receive their final position after construction.
    inst:DoTaskInTime(0, function(inst)
        if inst:GetIsInInterior() then
            inst:RemoveTag("SnowCovered")
            inst.AnimState:Hide("snow")
        end
    end)
end)

-- Lunar hail shares the snow symbol and can refresh it independently of the SnowCovered tag.
if UpdateLunarHailBuildup then
    local _UpdateLunarHailBuildup = UpdateLunarHailBuildup
    function UpdateLunarHailBuildup(inst, ...)
        _UpdateLunarHailBuildup(inst, ...)
        if inst:GetIsInInterior() then
            inst.AnimState:Hide("snow")
        end
    end
end
