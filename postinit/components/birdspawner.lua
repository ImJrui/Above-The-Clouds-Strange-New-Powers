local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local function IsInInterior(spawnpoint)
    local interiorspawner = TheWorld.components.interiorspawner
    return interiorspawner and interiorspawner:IsInInteriorRegion(spawnpoint.x, spawnpoint.z)
end

AddComponentPostInit("birdspawner", function(self, inst)
    if not TheWorld.ismastersim or TheWorld:HasTag("porkland") then
        return
    end

    -- PickBird can replace an empty interior bird list with a mutated bird after lunar hail.
    local _SpawnBird = self.SpawnBird
    function self:SpawnBird(spawnpoint, ...)
        if IsInInterior(spawnpoint) then
            return
        end
        return _SpawnBird(self, spawnpoint, ...)
    end

    -- Falling corpses use the same PickBird function.
    local _SpawnBirdCorpse = self.SpawnBirdCorpse
    function self:SpawnBirdCorpse(spawnpoint, ...)
        if IsInInterior(spawnpoint) then
            return
        end
        return _SpawnBirdCorpse(self, spawnpoint, ...)
    end
end)
