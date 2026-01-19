local RuinsRegenerating = Class(function(self, inst)
    self.inst = inst
end)

function RuinsRegenerating:RegenerateRuins(target, doer)
	if target.components.plrebalance_ruinsregeneratingtarget and not target:HasTag("plrebalance_cannotreset") then
		local rv = target.components.plrebalance_ruinsregeneratingtarget:RegenerateRuins(target)
		if self.OnFinished then self.OnFinished(self.inst, rv) end
		return true
	end
end

return RuinsRegenerating