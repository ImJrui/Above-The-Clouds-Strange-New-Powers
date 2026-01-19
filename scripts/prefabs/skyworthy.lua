local assets=
{
	Asset("ANIM", "anim/skyworthy.zip"),
	Asset("MINIMAP_IMAGE", "portal_ham"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:SetTime(0.65 * inst.AnimState:GetCurrentAnimationLength())
	inst.AnimState:PushAnimation("idle_off")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/skyworthy/place")
end

local function LinkedWorldType()
    return TheWorld:HasTag("porkland") and PL_WORLDTYPE.FOREST or PL_WORLDTYPE.PORKLAND
end
local function OnTravelDestinationConfirmed(inst, doer, destination_id)
    if not inst.components.activatable.inactive then
        return -- 如果处于激活状态（inactive 为 false），则返回，防止冲突
    end

    inst.components.worldmigrator.enabled = true
    inst.components.worldmigrator.linkedWorldType = Shard_GetConnectedWorldType(destination_id)
    inst.components.worldmigrator.linkedWorld = nil -- 可以让他尝试默认连接
    TheWorld:PushEvent("ms_registermigrationportal", inst)
    Shard_UpdatePortalState(inst)

    inst.components.worldmigrator:SetDestinationWorld(destination_id, true)

    if not inst.components.worldmigrator:IsActive() then
        inst.components.worldmigrator:SetEnabled(false)  -- 检查迁移器是否可激活
        return
    end

    inst.components.worldmigrator:Activate(doer)
    inst.components.worldmigrator:SetEnabled(false)
end

local function OnActivate(inst, doer)
    inst.components.activatable.inactive = true -- 激活后，将 inactive 设置为 true，防止重复激活

    local str = STRINGS.UI.SAVEINTEGRATION
    local title, text, cancel = str.CHOOSE_DEST_TITLE, str.CHOOSE_DEST_BODY, str.CANCEL
    local buttons = {}
    for id in pairs(Shard_GetConnectedShards()) do
        local world_type = Shard_GetConnectedWorldType(id)
        if world_type and world_type == inst.components.worldmigrator.linkedWorldType then -- 只能连接到一种世界类型
            table.insert(buttons, {text = str[world_type], cb = id})
        end
    end

    if #buttons == 0 then
        text = str.NODESTINATIONS
        cancel = str.OK
    end

    table.insert(buttons, {text = cancel, cb = nil, control = CONTROL_CANCEL})

    doer.skyworthy = inst -- 在服务器端运行，客户端无法读取
    doer:ShowPopUp(POPUPS.SKYWORTHY, true, title, text, ZipAndEncodeString(buttons))
end


local function GetStatus(inst)
	return TheWorld:HasTag("porkland") and "INPORKLAND" or nil
end

local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("portal_ham.tex")

	MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("skyworthy")
    inst.AnimState:SetBuild("skyworthy")
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off")

    inst.scrapbook_anim = "idle_off"

    inst.GetActivateVerb = function() return "WORTHY" end

    inst:AddTag("hamlet_portal")

	inst.no_wet_prefix = true

    inst.entity:SetPristine()

    inst.skyworthy = {}

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")
	inst.components.inspectable.GetStatus = GetStatus
	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true
    inst.components.activatable.standingaction = true
	inst.components.activatable.forcenopickupaction = true


	inst:AddComponent("worldmigrator")
    inst.components.worldmigrator.auto = false
	inst.components.worldmigrator.id = 997
	inst.components.worldmigrator.receivedPortal = 997
	inst.components.worldmigrator:SetEnabled(false)
    inst.components.worldmigrator.linkedWorldType = LinkedWorldType()

    inst.OnTravelDestinationConfirmed = OnTravelDestinationConfirmed

	inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

local function ondeploy(inst, pt)
    local structure = SpawnPrefab("skyworthy")
    if structure ~= nil then
        structure.Transform:SetPosition(pt:Get())
		structure:PushEvent("onbuilt")
        inst:Remove()
    end
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:AddTag("deploykititem")
	inst:AddTag("irreplaceable")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("skyworthy")
    inst.AnimState:SetBuild("skyworthy")
    inst.AnimState:PlayAnimation("kit")

    inst.MiniMapEntity:SetIcon("skyworthy_kit.tex")


    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "skyworthy"
    inst.components.inspectable.GetStatus = GetStatus

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("skyworthy", fn, assets),
	Prefab("skyworthy_kit", item_fn, assets),
	MakePlacer("skyworthy_kit_placer", "skyworthy", "skyworthy", "idle_off")