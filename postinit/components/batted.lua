local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("batted", function(self)
    local _LongUpdate = self.LongUpdate

    function self:LongUpdate(dt)
        if #AllPlayers == 0 then
            return
        end
        _LongUpdate(self, dt)
    end
end)



