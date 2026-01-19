local assets =
{
    Asset("ANIM", "anim/shoplocker.zip"),
}

local function OnFinished(inst, regenType)
	inst:Remove()
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/coins/3")
	end
end

local function SERVER_PlayFuelSound(inst)
	local owner = inst.components.inventoryitem.owner
	if owner == nil then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/coins/3")
	else
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

local function GetRepairCheck(self, repairvalue)
	self.plrebalance_prerepairvalue = self.current
	return self:old_Repair(repairvalue)
end

local function OnRepaired(inst, doer, repair_item)
	SERVER_PlayFuelSound(inst)

    if not TheWorld.ismastersim then
        return inst
    end
	
	--refund extra oincs
	local finiteuses = inst.components.finiteuses
	local diff = finiteuses.current - finiteuses.plrebalance_prerepairvalue
	local value = repair_item.components.repairer.finiteusesrepairvalue
	if diff < value then
		PLREBALANCE_RefundMoney(doer, value - diff, TUNING.OINC_REPAIR_VALUE)
	end
end

local function OnDurabilityChanged(inst, data)
	-- local index = 4 - math.floor(data.percent * 3)
	local index
	if data.percent == 0 then
		index = 4
	elseif data.percent < 0.5 then
		index = 3
	elseif data.percent < 1 then
		index = 2
	else -- data.percent == 1
		index = 1
	end

	if index == 4 then
		inst:RemoveTag("plrebalance_shoplockerhascharges")
	else
		inst:AddTag("plrebalance_shoplockerhascharges")
	end

	inst.AnimState:PlayAnimation("idle"..index, true)
	if index == 1 then
		inst.components.inventoryitem:ChangeImageName("shoplocker")
	else
		inst.components.inventoryitem:ChangeImageName("shoplocker"..index)
	end
end

local function OnPutInInventory(inst)
	local percent = inst.components.finiteuses:GetPercent()
	inst:PushEvent("percentusedchange", {percent = percent})
	inst.components.finiteuses:SetUses(inst.components.finiteuses:GetUses())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("shoplocker")
    inst.AnimState:SetBuild("shoplocker")
    inst.AnimState:PlayAnimation("idle1", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	
    inst:AddComponent("plrebalance_shoppedlocking")
	inst:AddTag("finiteusesrepairable")
	inst.components.plrebalance_shoppedlocking.OnFinished = OnFinished
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PLREBALANCE_MAXSHOPLOCK)
    inst.components.finiteuses:SetUses(10)
    inst.components.finiteuses.old_Repair = inst.components.finiteuses.Repair
	inst.components.finiteuses.Repair = GetRepairCheck
	
	inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.OINC
    inst.components.repairable.noannounce = true
	inst.components.repairable.onrepaired = OnRepaired

    MakeHauntableLaunch(inst)
	
	inst:ListenForEvent("percentusedchange", OnDurabilityChanged)

    return inst
end

return Prefab("shoplocker", fn, assets)
