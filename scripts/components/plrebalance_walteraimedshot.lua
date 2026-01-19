local WalterAimedShot = Class(function(self, inst)
    self.inst = inst
end)

function WalterAimedShot:DoAttack(inst, target, weapon)
	if weapon.components.weapon:CanRangedAttack() then
		weapon.components.weapon:LaunchProjectile(inst, target)
	end
end

return WalterAimedShot