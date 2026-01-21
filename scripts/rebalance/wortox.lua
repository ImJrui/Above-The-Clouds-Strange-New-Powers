local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("wortox", function(inst)
	inst._AddTag = inst.AddTag
	function inst:AddTag(tag, ...)
		if tag == "monster" or tag == "playermonster" then
            if inst:HasTag("indisguise") then
                return
            end
        end
		return inst:_AddTag(tag, ...)
	end
end)

--[[
local function SpellFn(inst, target, pos, caster)
    -- inst.components.rider ~= nil and inst.components.rider:IsRiding() kick off of mount before calling this state
    if not caster then
        print("Wortox Reviver: OnSpellCast called with no caster.")
        return
    end

    local owner = inst.components.linkeditem and inst.components.linkeditem:GetOwnerInst() or nil
    if inst.components.linkeditem then
        print("Wortox Reviver: SpellFn:", "linkeditem:",inst.components.linkeditem:GetOwnerInst())
    else
        print("Wortox Reviver: SpellFn:", "linkeditem:",false)
    end
    if not owner then
        print("Wortox Reviver: OnSpellCast called with no owner.")
        -- The owner left in between the time of starting the cast and the cast action perform.
        -- Do a wisecrack since the action was valid at the start.
        caster:PushEvent("wortox_reviver_failteleport")
        return
    end

    local caster_pos = caster:GetPosition()
    if owner == caster then
        print("Wortox Reviver: OnSpellCast called on self.")
        -- Free the Souls.
        if caster.components.inventory then
            caster.wortox_ignoresoulcounts = true
            local scaled_count = math.ceil((inst.components.perishable and inst.components.perishable:GetPercent() or 1) * CACHED_WORTOX_REVIVER_RECIPE_COST)
            for i = 1, scaled_count do
                local soul = SpawnPrefab("wortox_soul")
                caster.components.inventory:DropItem(soul, true, true, caster_pos)
            end
            caster.wortox_ignoresoulcounts = nil
        end
        if caster.SoundEmitter then
            caster.SoundEmitter:PlaySound("meta5/wortox/twintailed_heart_release")
        end
        caster.sg:GoToState("wortox_teleport_reviver_selfuse", { item = inst, })
    else
        -- Go to owner.
        print("Wortox Reviver: OnSpellCast called on other.")
        local owner_pos = owner:GetPosition()
        local offset
        for radius = 6, 1, -1 do
            offset = FindWalkableOffset(owner_pos, math.random() * TWOPI, radius, 8, true, true, NoHoles, false, true)
            if offset then
                owner_pos = owner_pos + offset
                break
            end
        end
        local platform = TheWorld.Map:GetPlatformAtPoint(owner_pos.x, owner_pos.z)
        local platformoffset
        if platform then
            platformoffset = platform:GetPosition() - owner_pos
        end
        local snapcamera = VecUtil_LengthSq(owner_pos.x - caster_pos.x, owner_pos.z - caster_pos.z) > PLAYER_CAMERA_SEE_DISTANCE_SQ
        caster.sg:GoToState("wortox_teleport_reviver", { dest = owner_pos, platform = platform, platformoffset = platformoffset, snapcamera = snapcamera, item = inst, })
    end
end

local function TryToAttachWortoxID(inst, owner)
    if owner == nil or owner.is_snapshot_user_session then
        print("wortox_reviver:TryToAttachWortoxID:false, no owner")
        return
    end
    local linkeditem = inst.components.linkeditem
    if linkeditem == nil or linkeditem:GetOwnerUserID() ~= nil then
        print("wortox_reviver:TryToAttachWortoxID:false, no linkeditem")
        if linkeditem == nil then
            print("linkeditem nil")
        else
            print("linkeditem:GetOwnerUserID()",linkeditem:GetOwnerUserID())
        end
        return
    end

    if owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("wortox_lifebringer_1") then
        linkeditem:LinkToOwnerUserID(owner.userid)
        print("wortox_reviver:TryToAttachWortoxID:true",owner.userid)
    end
end

local function OnPutInInventory(inst, owner)
    print("wortox_reviver:OnPutInInventory")
    inst:TryToAttachWortoxID(owner)
end

local function OnBuiltFn(inst, builder)
    print("wortox_reviver:OnBuiltFn")
    inst:TryToAttachWortoxID(builder)
end

local function OnInitFromLoad(inst)
    print("wortox_reviver:OnInitFromLoad")
    local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner() or nil
    inst:TryToAttachWortoxID(owner)
end

local function OnLoad(inst, data)
    inst:DoTaskInTime(0, OnInitFromLoad)
    print("wortox_reviver:OnLoad")
end

AddPrefabPostInit("wortox_reviver", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    -- inst:SetAllowConsumption(true)
    inst.TryToAttachWortoxID = TryToAttachWortoxID
    inst.OnBuiltFn = OnBuiltFn
    inst.OnLoad = OnLoad
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.spellcaster:SetSpellFn(SpellFn)
end)

local function ActionCanMapSoulhop(act)
    if act.invobject == nil and act.doer and act.doer.CanSoulhop then
        return act.doer:CanSoulhop(act.distancecount)
    end
    return false
end
]]
--[[local BLINK_MAP_MUST = { "CLASSIFIED", "globalmapicon", "fogrevealer" }
ACTIONS_MAP_REMAP[ACTIONS.BLINK.code] = function(act, targetpos)
    local doer = act.doer
    if doer == nil then
        return nil
    end
    local aimassisted = false
    local distoverride = nil
    
    local dist = distoverride or act.pos:GetPosition():Dist(targetpos)
    local act_remap = BufferedAction(doer, nil, ACTIONS.BLINK_MAP, act.invobject, targetpos)
    local dist_mod = ((doer._freesoulhop_counter or 0) * (TUNING.WORTOX_FREEHOP_HOPSPERSOUL - 1)) * act.distance
    local dist_perhop = (act.distance * TUNING.WORTOX_FREEHOP_HOPSPERSOUL * TUNING.WORTOX_MAPHOP_DISTANCE_SCALER)
    local dist_souls = (dist + dist_mod) / dist_perhop
    act_remap.maxsouls = TUNING.WORTOX_MAX_SOULS
    act_remap.distancemod = dist_mod
    act_remap.distanceperhop = dist_perhop
    act_remap.distancefloat = dist_souls
    act_remap.distancecount = math.clamp(math.ceil(dist_souls), 1, act_remap.maxsouls)
    act_remap.aimassisted = aimassisted
    if not ActionCanMapSoulhop(act_remap) then
        return nil
    end
    return act_remap
end]]--