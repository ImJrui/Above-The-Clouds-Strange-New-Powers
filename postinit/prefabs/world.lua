local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("world", function(inst)
    if not TheWorld.components.interiorspawner then
        inst:AddComponent("interiorspawner")
    end

    if not TheNet:IsDedicated() then
        if not TheWorld.components.interiorhudindicatablemanager then
            inst:AddComponent("interiorhudindicatablemanager")
        end
    end

    if not TheWorld.ismastersim then
        return
    end

    if not TheWorld.components.worldtimetracker then
        inst:AddComponent("worldtimetracker")
    end

    inst:DoTaskInTime(0, function()
        if TheWorld:HasTag("porkland") then return end
    
        if not inst.components.interiorspawner then
            inst:AddComponent("interiorspawner")
        end

        local bsp = inst.components.birdspawner
        if not bsp or bsp._interior_patch then
            return
        end
        bsp._interior_patch = true

        local function IsInterior(x, z)
            local isp = inst.components.interiorspawner
            return isp and isp:IsInInteriorRegion(x, z) and isp:IsInInteriorRoom(x, z)
        end

        local _SpawnBird = bsp.SpawnBird
        function bsp:SpawnBird(spawnpoint, ignorebait)
            if spawnpoint then
                local x, _, z = spawnpoint:Get()
                if IsInterior(x, z) then
                    return nil
                end
            end
            return _SpawnBird(self, spawnpoint, ignorebait)
        end
    end)
end)

