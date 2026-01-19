local assets =
{
    Asset("ANIM", "anim/plrebalance_ruinsresetfx.zip"),
}

local function animover(inst)
	if inst.AnimState:AnimDone() then
		inst:Remove()
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	
    inst.Transform:SetScale(2.7, 2.7, 2.7)

    inst.AnimState:SetBank("plrebalance_ruinsresetfx")
    inst.AnimState:SetBuild("plrebalance_ruinsresetfx")
	local anim = "ghost"..math.random(1,6)
    inst.AnimState:PlayAnimation(anim)
	inst.AnimState:SetFinalOffset(7)

    inst.entity:SetPristine()
	--non networked
    inst.entity:SetCanSleep(false)
    inst.persists = false
	
	inst:AddTag("FX")
    inst:AddTag("NOCLICK")
	
	inst:ListenForEvent("animover", animover)

    return inst
end

return Prefab("plrebalance_ruinsresetfx", fn, assets)
