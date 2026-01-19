require 'prefabutil'
local CreateInterior = require("prefabs/skyworthy_shop_gen")

local assets=
{
	Asset("ANIM", "anim/portal_hamlet.zip"),
	Asset("ANIM", "anim/portal_hamlet_build.zip"),
	Asset("ANIM", "anim/wormhole_hamlet.zip"),
	Asset("MINIMAP_IMAGE", "portal_ham"),
}

local prefabs = {}

local SHOPSOUND_ENTER1 = "dontstarve_DLC003/common/objects/store/door_open"
local SHOPSOUND_ENTER2 = "dontstarve_DLC003/common/objects/store/door_entrance"

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:SetTime(0.65 * inst.AnimState:GetCurrentAnimationLength())
	inst.AnimState:PushAnimation("idle_off")
end

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil and inst:GetCurrentPlatform() == nil then
            inst._pfpos = inst:GetPosition()
            local x, _, z = inst._pfpos:Get()
            for delta_x = 0, 1 do
                for delta_z = 0, 1 do
                    TheWorld.Pathfinder:AddWall(x + delta_x - 0.5, 0, z + delta_z - 0.5)
                end
            end
        end
    elseif inst._pfpos ~= nil then
        local x, _, z = inst._pfpos:Get()
        for delta_x = 0, 1 do
            for delta_z = 0, 1 do
                TheWorld.Pathfinder:RemoveWall(x + delta_x - 0.5, 0, z + delta_z - 0.5)
            end
        end
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function UseDoor(inst, data)
    if inst.use_sounds and data and data.doer and data.doer.SoundEmitter then
        for _, sound in ipairs(inst.use_sounds) do
            data.doer:DoTaskInTime(FRAMES * 2, function()
                data.doer.SoundEmitter:PlaySound(sound)
            end)
        end
    end
end

local function OnSave(inst, data)
    data.interiorID = inst.interiorID
end

local function OnLoad(inst, data)
    if not data then
        return
    end
	
    if data.interiorID then
        inst.interiorID = data.interiorID
    end
end

local function MakeObstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function OnRemove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("portal_ham.tex")
	
	inst.entity:AddNetwork()

	anim:SetBank("skyworthy")
    anim:SetBuild("skyworthy")
	anim:PlayAnimation("place")
	anim:PushAnimation("idle_off")

    inst.scrapbook_anim = "idle_off"
		
    inst:AddTag("porkland_portal")
	inst:AddTag("structure")

	inst.entity:SetPristine()
	
	--shop parts
	
    inst:AddTag("client_forward_action_target")

	inst:AddTag("shop_music")
	
	------- Copied from prefabs/wall.lua -------
	inst._pfpos = nil
	inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
	MakeObstacle(inst)
	-- Delay this because makeobstacle sets pathfinding on by default
	-- but we don't to handle it until after our position is set
	inst:DoTaskInTime(0, InitializePathFinding)

	inst:ListenForEvent( "onbuilt", function()		
		inst.AnimState:PlayAnimation("place")
		inst.AnimState:PushAnimation("idle_off")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/skyworthy/place")				
	end)
    inst:ListenForEvent("onremove", OnRemove)

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")

	inst.no_wet_prefix = true

	--[[inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true]]--

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)	

	--SaveGameIndex:RegisterWorldEntrance(inst, "porkland_portal")
    --inst:ListenForEvent("onremove", function() SaveGameIndex:DeregisterWorldEntrance(inst) end)

	--shop parts
	
	inst:AddComponent("door")
	inst.components.door.outside = true
	
    inst:ListenForEvent("usedoor", UseDoor)

    inst:DoTaskInTime(0, CreateInterior)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	
	MakeHauntableWork(inst)

    return inst
end

return Prefab( "skyworthy_shop", fn, assets, prefabs),	--需要改成"pig_shop"..name的格式，否则室内会因为爆炸产生地震，先保留以防旧档出问题
	   MakePlacer("skyworthy_shop_placer", "skyworthy", "skyworthy", "idle_off"),
	   Prefab( "pig_shop_skyworthy", fn, assets, prefabs),
	   MakePlacer("pig_shop_skyworthy_placer", "skyworthy", "skyworthy", "idle_off")

