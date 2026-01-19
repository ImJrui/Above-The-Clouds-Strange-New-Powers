local ShopLocking = Class(function(self, inst)
    self.inst = inst
end)

function ShopLocking:LockShop(target, doer)
	if target.components.plrebalance_shoppedlockable and
		not target.saleitem and --item already locked
		not target.plrebalance_mayormandateitem and --ditto
		not target:HasTag("justsellonce") and --will not restock
		not target:HasTag("robbed") and --NO
		target.components.shopped:GetItemToSell() then
		local rv = target.components.plrebalance_shoppedlockable:Lock(target, doer.components.finiteuses:GetUses())
		if self.OnFinished then self.OnFinished(self.inst, rv) end
		return true
	end
end

return ShopLocking