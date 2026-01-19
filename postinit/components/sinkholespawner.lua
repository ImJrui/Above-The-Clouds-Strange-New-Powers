local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)


AddComponentPostInit("sinkholespawner", function(self, inst)
    local _SpawnSinkhole = self.SpawnSinkhole
    function self:SpawnSinkhole(spawnpt)
        if spawnpt and TheWorld.Map:IsVisualInteriorAtPoint(spawnpt.x, spawnpt.y, spawnpt.z) then
            return
        end
        _SpawnSinkhole(self, spawnpt)
    end
end)