local assets =
{
    Asset("ANIM", "anim/moonrock_idol.zip"),
    Asset("INV_IMAGE", "moonrockidolon"),
}

local function reroll()
    giver:PushEvent("ms_playerreroll")
    if giver.components.inventory ~= nil then
        giver.components.inventory:DropEverything()
    end

	if giver.components.leader ~= nil then
		local followers = giver.components.leader.followers
		for k, v in pairs(followers) do
			if k.components.inventory ~= nil then
				k.components.inventory:DropEverything()
			elseif k.components.container ~= nil then
				k.components.container:DropEverything()
			end
		end
	end

    inst._savedata[giver.userid] = giver.SaveForReroll ~= nil and giver:SaveForReroll() or nil
    TheWorld:PushEvent("ms_playerdespawnanddelete", giver)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moonrock_idol")
    inst.AnimState:SetBuild("moonrock_idol")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("donotautopick")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    --inst:AddComponent("tool")
    --inst.components.tool:SetAction(ACTIONS.PORKLANDREBALANCE_REPICK)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1)
    inst.components.finiteuses:SetUses(1)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PORKLANDREBALANCE_REPICK, 1)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("vortexeye", fn, assets)
