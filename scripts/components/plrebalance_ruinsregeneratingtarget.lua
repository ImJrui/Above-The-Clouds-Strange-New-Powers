local RuinsRegeneratingTarget = Class(function(self, inst)
    self.inst = inst
end)

function RuinsRegeneratingTarget:RegenerateRuins(target)
	return self.OnRegenerateRuins(target)
end

return RuinsRegeneratingTarget