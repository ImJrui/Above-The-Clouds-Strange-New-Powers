local ShoppedLockable = Class(function(self, inst)
    self.inst = inst
end)

function ShoppedLockable:RefreshLock(inst, doer, charges)
	inst.plrebalance_mayormandatecharges = inst.plrebalance_mayormandatecharges + charges
	if inst.plrebalance_mayormandatecharges > TUNING.PLREBALANCE_MAXSHOPLOCK then
		local diff = inst.plrebalance_mayormandatecharges - TUNING.PLREBALANCE_MAXSHOPLOCK
		inst.plrebalance_mayormandatecharges = TUNING.PLREBALANCE_MAXSHOPLOCK
		PLREBALANCE_RefundMoney(doer, diff, TUNING.OINC_REPAIR_VALUE)
		doer.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/coins/3")
	end
	inst:PLRebalance_UpdateExtraVisualCharges()
end

function ShoppedLockable:Lock(inst, charges)
	local shopped = inst.components.shopped
	local itemToSell = shopped:GetItemToSell()
	local prefab = itemToSell.prefab
	if prefab == "blueprint" then
		prefab = itemToSell.recipetouse.."_blueprint"
	end
	inst.plrebalance_mayormandateitem = { prefab, shopped:GetCostPrefab(), shopped:GetCost() } --get current item and save it
	inst.plrebalance_mayormandatecharges = charges
	inst:PLRebalance_UpdateExtraVisualCharges()
end

return ShoppedLockable