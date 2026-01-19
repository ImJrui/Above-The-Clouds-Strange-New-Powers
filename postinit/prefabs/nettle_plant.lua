local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function GrowFromSeed(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("grow", false)
    inst.AnimState:PushAnimation("idle", true)
end

local function postinit_fn(inst)
	if not TheWorld.ismastersim then
		return inst
	end

	inst.growfromseed = GrowFromSeed
    
    local _onpickedfn = inst.components.pickable.onpickedfn
    inst.components.pickable.onpickedfn = function(inst, picker, ...)
        if _onpickedfn then
            _onpickedfn(inst, picker, ...)
        end
        if math.random() < 0.01 then
            local seed = SpawnPrefab("nettle_sapling_item")
            local inventory = picker ~= nil and picker.components.inventory or nil
            local pt = inst:GetPosition()
            if inventory then
                inventory:GiveItem(seed)
            else
                -- inst.components.lootdropper:SpawnLootPrefab("nettle_sapling_item", pt)
                seed.Transform:SetPosition(pt:Get())
                Launch(seed, picker, 1.5)
            end
        end
    end
end

AddPrefabPostInit("nettle", postinit_fn)