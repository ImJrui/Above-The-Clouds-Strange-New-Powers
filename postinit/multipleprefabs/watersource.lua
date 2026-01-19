local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function SetAsWaterSource(inst)
    inst:AddTag("watersource")
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("watersource")
    inst.components.watersource.available = true
end

AddPrefabPostInit("sedimentpuddle", SetAsWaterSource)
AddPrefabPostInit("pugalisk_fountain", SetAsWaterSource)

AddPrefabPostInit("sprinkler", function(inst)
    inst:AddTag("structure")
    if not TheWorld.ismastersim then
        return
    end

    inst.SoilMoistureTask = 0

    local _UpdateSpray = inst.UpdateSpray
    inst.UpdateSpray = function(inst)
        _UpdateSpray(inst)
        
        inst.SoilMoistureTask = inst.SoilMoistureTask + 1
        if inst.SoilMoistureTask > 10 then
            local x, y, z = inst.Transform:GetWorldPosition()
            local size = 6.5

            for i = x-size, x+size do
                for j = z-size, z+size do
                    if TheWorld.Map:GetTileAtPoint(i, 0, j) == WORLD_TILES.FARMING_SOIL then
                        TheWorld.components.farming_manager:AddSoilMoistureAtPoint(i, y, j, 0.05)
                    end
                end
            end

            local ents = TheSim:FindEntities(x, y, z, size, nil, { "FX", "DECOR", "INLIMBO", "burnt" })
            for i, v in ipairs(ents) do
                if v.components.burnable ~= nil and v.components.witherable ~= nil then
                    v.components.witherable:Protect(TUNING.WATERINGCAN_PROTECTION_TIME)
                end
            end

            inst.SoilMoistureTask = 1
        end
    end

    if not inst.components.watersource then
        inst:AddComponent("watersource")
    end

    if not inst.components.machine then
        inst:AddComponent("machine")
    end
    local _TurnOn = inst.components.machine.turnonfn
    local _TurnOff = inst.components.machine.turnofffn
    inst.components.machine.turnonfn = function(inst)
        _TurnOn(inst)

        if not inst:HasTag("watersource") then
            inst:AddTag("watersource")
        end

        inst.components.watersource.available = true
    end
    inst.components.machine.turnofffn = function(inst)
        _TurnOff(inst)

        if inst:HasTag("watersource") then
            inst:RemoveTag("watersource")
        end

        inst.components.watersource.available = false
    end
end)