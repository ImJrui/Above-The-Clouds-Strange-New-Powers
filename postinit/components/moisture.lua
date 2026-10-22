local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local Moisture = require("components/moisture")

function Moisture:IsImmuneFog()
    return self.inst:HasTag("immunefog")
end

local __GetMoistureRateAssumingFog = Moisture._GetMoistureRateAssumingFog
function Moisture:_GetMoistureRateAssumingFog()
    if self:IsImmuneFog() then
        return 0
    end
    return __GetMoistureRateAssumingFog(self)
end