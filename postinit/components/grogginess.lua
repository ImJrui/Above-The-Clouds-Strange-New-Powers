GLOBAL.setfenv(1, GLOBAL)

local Grogginess = require("components/grogginess")

local _FogProofChange = Grogginess.OnFogProofChange

function Grogginess.OnFogProofChange(inst, ...)
	if inst:HasTag("PorklandRebalance_WX_FogImmune")
        or inst:HasTag("PorklandRebalance_WX_FogImmune_Ally")
        or inst:HasTag("onfogproof")
		or inst:HasTag("fan_module_buff")
    then
		local self = inst.components.grogginess

		if not self then
			return
		end

		if self.foggygroggy then
			if inst.components.talker then
				inst.components.talker:Say(GetString(inst, "ANNOUNCE_DEHUMID"))
			end
		end

		self.foggygroggy = false
		return
	end
	_FogProofChange(inst, ...)
end