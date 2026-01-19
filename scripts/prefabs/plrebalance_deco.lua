local function RET_TRUE() return true, true end

local function MakeRescaledFurniture(prefabName, suffix, sX, sY, sZ)
	local fullprefabname = prefabName..suffix
	return Prefab(fullprefabname, -- rescales pre-existing window decos to fit new room sizes and changes of perspective
		function()
			local inst = Prefabs[prefabName].fn(TheSim)
			inst.Transform:SetScale(sX, sY, sZ)
			inst.AnimState:SetSortOrder(-2)
			inst.CanMouseThrough = RET_TRUE
				
			if not TheNet:IsDedicated() then
				inst:DoTaskInTime(0, function()
                    if not inst.components.rotatingbillboard then
                        inst:AddComponent("rotatingbillboard")
                    end
                    inst.components.rotatingbillboard:GetMask().CanMouseThrough = RET_TRUE
                end)
			end
			return inst
		end, {}, {prefabName})
end

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil and inst:GetCurrentPlatform() == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function MakeObstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function OnRemove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function MakeHamportalDoor()
	local inst = Prefabs["prop_door"].fn(TheSim)

    ------- Copied from prefabs/wall.lua -------
    inst._pfpos = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    MakeObstacle(inst)
    -- Delay this because makeobstacle sets pathfinding on by default
    -- but we don't to handle it until after our position is set
    inst:DoTaskInTime(0, InitializePathFinding)
    inst:DoTaskInTime(0.00000001, function() inst.Physics:SetActive(true) end)

    inst:ListenForEvent("onremove", OnRemove)
	
	inst.AnimState:SetSortOrder(0)
	return inst
end

local function MakeZ0Door()
	local inst = Prefabs["prop_door"].fn(TheSim)
	inst.AnimState:SetSortOrder(-1)
    inst:SetPrefabNameOverride("prop_door")
	return inst
end

return MakeRescaledFurniture("window_greenhouse", "_rescaledplrebalance", -1.1, 1, 1),
	Prefab("prop_door_hamportal", MakeHamportalDoor, {}, {"prop_door"}),
	Prefab("prop_door_z0", MakeZ0Door, {}, {"prop_door"})