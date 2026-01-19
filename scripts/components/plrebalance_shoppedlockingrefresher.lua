local ShopLockingRefresher = Class(function(self, inst)
    self.inst = inst
end)

function ShopLockingRefresher:RefreshLockShop(target, doer, item)
	if target.components.plrebalance_shoppedlockable and
		target.plrebalance_mayormandateitem and --must be locked
		not target:HasTag("robbed") then --NO
		local rv = target.components.plrebalance_shoppedlockable:RefreshLock(target, doer, item.components.repairer.finiteusesrepairvalue)
		
		if item.components.stackable then --delete item, cannot use paymoney
			item.components.stackable:Get():Remove()
		else
			item:Remove()
		end
		return true
	end
end

return ShopLockingRefresher