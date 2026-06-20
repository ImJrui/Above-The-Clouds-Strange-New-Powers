local AddComponentPostInit = AddComponentPostInit
GLOBAL.setfenv(1, GLOBAL)

local Moisture = require("components/moisture")

function Moisture:IsImmuneFog()
    return self.inst:HasTag("immunefog")
end

local _GetMoistureRate = Moisture.GetMoistureRate
function Moisture:GetMoistureRate(...)

    if not self:IsImmuneFog() then
        return _GetMoistureRate(self, ...)
    end

    local rate = 0

    -- 天气影响

    if TheWorld.state.fogstate == FOG_STATE.FOGGY or TheWorld.state.fogstate == FOG_STATE.SETTING then
        rate = 0
    else
        rate = _GetMoistureRate(self, ...)
    end

    local x, _, z = self.inst.Transform:GetWorldPosition()
    if TheWorld.components.interiorspawner:IsInInteriorRegion(x, z) then
        rate = 0
    end

    -- 非天气影响

    if self.inst.components.inventory and self.inst.components.inventory:IsFloaterHeld() then
		rate = _GetMoistureRate(self, ...)
    end

    local waterproofmult = self:GetWaterproofness()
    rate = rate + self:GetExternalMoistureRate() * (1 - waterproofmult)

    return rate
end
