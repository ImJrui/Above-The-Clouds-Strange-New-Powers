local AddComponentPostInit = AddComponentPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit

local ruinsfuncs = require("features/ruinsfuncs")
local anthillfuncs = require("features/anthillfuncs")

GLOBAL.setfenv(1, GLOBAL)

plrebutil_RuinsRegenerator = {}

function plrebutil_RuinsRegenerator:RegenerateRuins_Thread(inst, other, exterior_pos)
	inst:AddTag("plrebalance_cannotreset") --prevent resetting
	inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/shadow_pulse")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/destabilize_LP", "plrebalance_loop")
	if other then
		other:AddTag("plrebalance_cannotreset")
		other.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/shadow_pulse")
		other.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/destabilize_LP", "plrebalance_loop")
	end
	
	local InteriorSpawner = TheWorld.components.interiorspawner
    local room = InteriorSpawner:GetInteriorCenter(inst.interiorID)
    local allrooms = plrebutil_RuinsRegenerator.GetAllConnectedRooms(InteriorSpawner, room, {}) --get all rooms to quake and later destroy
	--self:QuakeAllRooms(allrooms)
	
	inst.plRebalance_oldinteriorID = inst.interiorID
	local exterior_door_def = ruinsfuncs.OnLoad(inst) -- Generate ruins
	
	Yield()
	
	--[[local duration = math.random(1 * 60 * 15, 2 * 60 * 15) -- super quaker, tick rate 15
	while duration > 0 do
		duration = duration - 1
		--c_announce(duration)
		Yield()
	end]]--
	
	--c_announce("Ruins generated!")
	-- Switch from old ruins to new ruins. Consumes 1 frame.
    InteriorSpawner:AddDoor(inst, exterior_door_def) --we put AddDoor here so we switch after the ruins are done
	inst.interiorID = inst.plRebalance_newinteriorID
	if other then
		ruinsfuncs.OnLoadPostPass(other)
		other:RemoveTag("plrebalance_cannotreset")
		other.SoundEmitter:KillSound("plrebalance_loop")
	end
	
	inst:RemoveTag("plrebalance_cannotreset")
	
    inst.SoundEmitter:KillSound("plrebalance_loop")
	
	Yield()
	--c_announce("Ruins linked!")
	-- Remove memory leak
	self.OnRemoveExterior(allrooms, exterior_pos)
	Yield()
end

function plrebutil_RuinsRegenerator:RegenerateRuins(inst)
	local exterior_pos = inst:GetPosition() --set pos to the one we use the seed on
	
	local is_entrance = inst.is_entrance
	local entrance = is_entrance and inst or nil
	local other = not is_entrance and inst or nil
	local dungeon_name = inst.dungeon_name
	if not entrance then
		for _, ent in pairs(Ents) do
            if ent.dungeon_name == dungeon_name and ent.is_entrance then
				entrance = ent
                break
            end
        end
	end
	if not other then
		for _, ent in pairs(Ents) do
            if ent.dungeon_name == dungeon_name and not ent.is_entrance then
				other = ent
                break
            end
        end
	end
	
	if entrance:HasTag("plrebalance_cannotreset") then return end
	
	StartThread(function() self:RegenerateRuins_Thread(entrance, other, exterior_pos) end)
end

function plrebutil_RuinsRegenerator:RegenerateAnthill_Thread(inst, exterior_pos)
	inst:AddTag("plrebalance_cannotreset")
	--find these 2 first
	local antqueen = nil
	local chamber = nil
	local exit1 = nil
	local exit2 = nil
	for _, ent in pairs(Ents) do
		if ent.prefab == "antqueen" and not ent:HasTag("plrebalance_destroyed") then
			antqueen = ent
			ent:AddTag("plrebalance_destroyed")
		elseif ent.prefab == "antqueen_chamber_entrance" and not ent:HasTag("plrebalance_destroyed") then
			chamber = ent
			ent:AddTag("plrebalance_destroyed")
		elseif ent.prefab == "anthill_exit" then
			if exit1 then exit2 = ent else exit1 = ent end
		end
		if antqueen and chamber and exit2 then break end
	end
	exit1:AddTag("plrebalance_cannotreset")
	exit2:AddTag("plrebalance_cannotreset")
	
	Yield()
	anthillfuncs:CreateInterior(inst)
	local oldrooms = inst.rooms
	inst.rooms = inst.newrooms
	
	Yield()
	
	inst:RemoveTag("plrebalance_cannotreset")
	exit1:RemoveTag("plrebalance_cannotreset")
	exit2:RemoveTag("plrebalance_cannotreset")
	
	Yield()
	
    local interior_spawner = TheWorld.components.interiorspawner
	local roomsToRemove = {}
	for i = 1, #oldrooms do
		for j = 1, #oldrooms[i] do
			roomsToRemove[interior_spawner:GetInteriorCenter(oldrooms[i][j].id)] = true
		end
	end
	Yield()
	--remove antqueen because she has epic tag
	if antqueen then
		antqueen:Remove()
	end
	chamber:Remove() --remove chamber first so that items go outside the mant hill
	Yield()
	
	self.OnRemoveExterior(roomsToRemove, exterior_pos)
end

function plrebutil_RuinsRegenerator:RegenerateAnthill(inst)

	local exterior_pos = inst:GetPosition()
	local entrance = nil
	if inst.is_entrance then
		entrance = inst
	else
		for _, ent in pairs(Ents) do
            if ent.prefab == "anthill" then
				entrance = ent
                break
            end
        end
	end
	if entrance:HasTag("plrebalance_cannotreset") then return end
	--plrebutil_RuinsRegenerator:RegenerateAnthill_Thread(entrance)
	StartThread(function() plrebutil_RuinsRegenerator:RegenerateAnthill_Thread(entrance, exterior_pos) end)
end

-- Regenerate pig palace

function plrebutil_RuinsRegenerator:RegeneratePigPalace()
	local mafalfashelves = {}
	
	local InteriorSpawner = TheWorld.components.interiorspawner

	local locked_shelves = {
		["shelf_queen_display_1"] = true,
		["shelf_queen_display_2"] = true,
		["shelf_queen_display_3"] = true,
		["pig_palace"] = true,
		["pigman_queen"] = true,
		["pig_shop_cityhall"] = true,
		["pigman_mayor_shopkeep"] = true,
	}

	for _, ent in pairs(Ents) do
		if locked_shelves[ent.prefab] then
			locked_shelves[ent.prefab] = ent
		end
		if ent.prefab == "shelf_displaycase_wood" then
			mafalfashelves[#mafalfashelves + 1] = ent
		end
	end
	
	if locked_shelves["pigman_queen"] == true then
		InteriorSpawner:SpawnObject(locked_shelves["pig_palace"].interiorID, "pigman_queen", {x = -3, y = 0, z = 0})
	end
	if locked_shelves["pigman_mayor_shopkeep"] == true then
		InteriorSpawner:SpawnObject(locked_shelves["pig_shop_cityhall"].interiorID, "pigman_mayor_shopkeep", {x = -3, y = 0, z = 0})
	end
	
	local pos = mafalfashelves[1]:GetPosition()
	local ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.ROOM_FINDENTITIES_RADIUS)
	local woodshelf = {}
    if #ents > 0 then
		for _, v in ipairs(ents) do
			if v.prefab == "shelf_wood" then
				woodshelf[#woodshelf + 1] = v
				if #woodshelf == 2 then
					break
				end
			end
		end
	end
	
	local marbleshelf = nil
	pos = locked_shelves["shelf_queen_display_1"]:GetPosition()
	ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.ROOM_FINDENTITIES_RADIUS)
    if #ents > 0 then
		for _, v in ipairs(ents) do
			if v.prefab == "shelf_marble" then
				marbleshelf = v
				break
			end
		end
	end
	
	local shelf = locked_shelves["shelf_queen_display_1"]
	if shelf.components.container.slots[1] == nil then
		shelf.components.container:GiveItem(SpawnPrefab("key_to_city"), 1)
		shelf.components.lock:SetLocked(true)
		shelf.components.lock.locktype = LOCKTYPE.ROYAL
	end
	
	shelf = locked_shelves["shelf_queen_display_2"]
	
	if shelf.components.container.slots[1] == nil then
		shelf.components.container:GiveItem(SpawnPrefab("trinket_giftshop_4"), 1)
		shelf.components.lock:SetLocked(true)
		shelf.components.lock.locktype = LOCKTYPE.ROYAL
	end
	
	shelf = locked_shelves["shelf_queen_display_3"]
	if shelf.components.container.slots[1] == nil then
		shelf.components.container:GiveItem(SpawnPrefab("city_hammer"), 1)
		shelf.components.lock:SetLocked(true)
		shelf.components.lock.locktype = LOCKTYPE.ROYAL
	end
	
	for i=1, #mafalfashelves do
		shelf = mafalfashelves[i]
		for j=1, 3 do
			if shelf.components.container.slots[j] == nil and math.random(1, 3) < 3 then
				shelf.components.container:GiveItem(SpawnPrefab("trinket_giftshop_1"), j)
			end
		end
	end
	
	local marbleshelf_container = marbleshelf.components.container
	if marbleshelf_container.slots[5] == nil then
		marbleshelf_container:GiveItem(SpawnPrefab("trinket_20"), 5)
	end
	if marbleshelf_container.slots[6] == nil then
		marbleshelf_container:GiveItem(SpawnPrefab("trinket_14"), 6)
	end
	if marbleshelf_container.slots[3] == nil then
		marbleshelf_container:GiveItem(SpawnPrefab("trinket_4"), 3)
	end
	if marbleshelf_container.slots[4] == nil then
		marbleshelf_container:GiveItem(SpawnPrefab("trinket_2"), 4)
	end
	
	local woodshelf_container = woodshelf[1].components.container
	for i=1, 6 do
		if woodshelf_container.slots[i] == nil and math.random(1, 4) < 4 then
			woodshelf_container:GiveItem(SpawnPrefab("trinket_giftshop_3"), i)
		end
	end
	woodshelf_container = woodshelf[2].components.container
	for i=1, 6 do
		if woodshelf_container.slots[i] == nil and math.random(1, 4) < 4 then
			woodshelf_container:GiveItem(SpawnPrefab("trinket_giftshop_3"), i)
		end
	end
end

-- Modified from InteriorSpawner to use coroutines --

function plrebutil_RuinsRegenerator:GetAllConnectedRooms(center, allrooms, usemap)
    -- WARNING: this method is quite expensive and server only
    if allrooms[center] then
        return
    end
    allrooms[center] = true
    local x, _, z = center.Transform:GetWorldPosition()
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, TUNING.ROOM_FINDENTITIES_RADIUS, {"interior_door"})) do
        local target_interior = v.components.door and v.components.door.target_interior
        if target_interior and target_interior ~= "EXTERIOR" then
            local room = self.interiors[target_interior] or self:GetInteriorCenter(target_interior)
            assert(room, "Room not exists: "..target_interior)
			Yield()
            plrebutil_RuinsRegenerator.GetAllConnectedRooms(self, room, allrooms)
        end
    end
    return allrooms
end

local remove_ruins_items = {
	["antchest"] = true,
	["antcombhome"] = true,
	["antman"] = true,
	["antman_warrior"] = true,
	["giantgrub"] = true,
	["smashingpot"] = true,
	["pl_bat"] = true,
	["snake_amphibious"] = true,
	["scorpion"] = true,
	["pig_ruins_spear_trap"] = true,
	["pigghost"] = true,
}

function plrebutil_RuinsRegenerator:OnRemoveItems(pos, exterior_pos)
	local ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.ROOM_FINDENTITIES_RADIUS, nil, {"_inventoryitem"})
	if #ents > 0 then
		for _, v in ipairs(ents) do
			if remove_ruins_items[v.prefab] and v:IsValid() then
				v:Remove()
			end
		end
	end
end

function plrebutil_RuinsRegenerator.OnRemoveExterior(allrooms, exterior_pos)
	local InteriorSpawner = TheWorld.components.interiorspawner
	for center in pairs(allrooms) do
		local pos = center:GetPosition()
		plrebutil_RuinsRegenerator:OnRemoveItems(pos, exterior_pos) --remove the mosters and construct

		local group_id = center:GetGroupId()
		InteriorSpawner.interior_groups[group_id] = InteriorSpawner.interior_groups[group_id] or {}
		InteriorSpawner:ClearInteriorContents(pos, exterior_pos)
		
		local ents = TheSim:FindEntities(exterior_pos.x, 0, exterior_pos.z, 1, {"_inventoryitem"}) --launch!
		for _, v in ipairs(ents) do
			local angle = math.random() * 2 * math.pi
			local speed = math.random() * 0.5 + 1.5
			local cosa = math.cos(angle)
			local sina = math.sin(angle)
			local startradius = 0.5
			local startheight = 2
			v.Physics:Teleport(exterior_pos.x + startradius * cosa, startheight, exterior_pos.z + startradius * sina)
			v.Physics:SetVel(speed * cosa, math.random() * 2 + 2, speed * sina)
		end

		TheWorld:PushEvent("room_removed", {id = center.interiorID})
		Yield()
	end
end

-- effects

local function ruinsentrance_task(inst)
	if inst:HasTag("plrebalance_cannotreset") then
		local effect = SpawnPrefab("plrebalance_ruinsresetfx")
		local x, y, z = inst.Transform:GetWorldPosition()
		effect.Transform:SetPosition(x, y, z)
		effect = SpawnPrefab("plrebalance_ruinsresetfx")
		effect.Transform:SetPosition(x, y, z)
	end
end

local function bigruins_onregenerateruins(target)
	plrebutil_RuinsRegenerator:RegenerateRuins(target)
	plrebutil_RuinsRegenerator:RegeneratePigPalace()
	return "BIGRUINS"
end

local function smallruins_onregenerateruins(target) 
	plrebutil_RuinsRegenerator:RegenerateRuins(target)
	return "SMALLRUINS"
end

local function anthill_onregenerateruins(target)
	plrebutil_RuinsRegenerator:RegenerateAnthill(target)
	plrebutil_RuinsRegenerator:RegeneratePigPalace()
	return "ANTHILL"
end

local function ruinsentrance_postinit(inst)
    if TheNet:GetIsClient() or not TheNet:IsDedicated() then
		inst:DoPeriodicTask(0.2, ruinsentrance_task)
    end
	inst:AddComponent("plrebalance_ruinsregeneratingtarget")
	
    if inst.prefab == "pig_ruins_entrance_small" then
		inst.components.plrebalance_ruinsregeneratingtarget.OnRegenerateRuins = smallruins_onregenerateruins
	elseif (inst.prefab == "anthill" or inst.prefab == "anthill_exit") then
		inst.components.plrebalance_ruinsregeneratingtarget.OnRegenerateRuins = anthill_onregenerateruins
    else
		inst.components.plrebalance_ruinsregeneratingtarget.OnRegenerateRuins = bigruins_onregenerateruins
	end
end

AddPrefabPostInit("pig_ruins_entrance", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_entrance2", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_entrance3", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_entrance4", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_entrance5", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_exit", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_exit2", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_exit4", ruinsentrance_postinit)
AddPrefabPostInit("pig_ruins_entrance_small", ruinsentrance_postinit)
AddPrefabPostInit("anthill", ruinsentrance_postinit)
AddPrefabPostInit("anthill_exit", ruinsentrance_postinit)

-- remove crash when regenerating antqueen chamber

AddSimPostInit(function()
	local _antqueenchamber_createinterior = ToolUtil.GetUpvalue(Prefabs.antqueen_chamber_entrance.fn, "CreateInterior")

	local function AntQueenChamber_CreateInterior(...)
		-- we reset the queen chamber ID collection every time this function is run to prevent crashes. if I don't do this it will attempt to reuse old IDs populated by old ant queen chambers.
		-- ToolUtil.SetUpvalue(_antqueenchamber_createinterior, {}, "queen_chamber_ids")
		ToolUtil.SetUpvalue(_antqueenchamber_createinterior, "queen_chamber_ids", {})
		_antqueenchamber_createinterior(...)
	end
	-- ToolUtil.SetUpvalue(Prefabs.antqueen_chamber_entrance.fn, AntQueenChamber_CreateInterior, "CreateInterior")
	ToolUtil.SetUpvalue(Prefabs.antqueen_chamber_entrance.fn, "CreateInterior", AntQueenChamber_CreateInterior)
end)

-- remove irreplaceable for 2+ keys

local Loading_Chest = false

local container = require("components/container")
container._PLREBALANCE_onload = container.OnLoad --blueprint bug is caused by lack of skyworthy_shop_recipe localization data
function container:OnLoad(...)
	Loading_Chest = true
	pcall(container._PLREBALANCE_onload, self, ...)
	Loading_Chest = false 
end

--[[AddSimPostInit(function()
	if not TheWorld.plrebalance then return end
	for key, list in pairs(TheWorld.plrebalance.irreplaceable_tracker) do 
		for ent, v in pairs(list) do
			if ent:HasTag("PLREBALANCE_canirreplaceable") then
				ent:AddTag("irreplaceable")
				ent:RemoveTag("PLREBALANCE_canirreplaceable")
			end
		end
	end
end)]]--

local function Irreplaceable_OnRemove(inst)
	local tracker = TheWorld.plrebalance.irreplaceable_tracker
	local list = tracker[inst.prefab]
	list[inst] = nil
end

local function Irreplaceable_OnDropped(inst)
	--inst:RemoveTag("PLREBALANCE_canirreplaceable")
	inst:AddTag("irreplaceable")
end

local function Irreplaceable_OnPutInInventory(inst, owner)
	if not owner.isplayer and owner.prefab ~= "shadow_container" then Irreplaceable_OnDropped(inst) return end --maxwell fix
	--inst:RemoveTag("PLREBALANCE_canirreplaceable")
	
	local tracker = TheWorld.plrebalance.irreplaceable_tracker
	local list = tracker[inst.prefab]
	for ent, v in pairs(list) do
		if ent ~= inst and ent:HasTag("irreplaceable") then
			inst:RemoveTag("irreplaceable")
			break
		end
	end
end

--Theoretically, players should load in after the world and all its prefabs. Hence, we do not need to account for the situation where the only copy of the object is in a player's inventory.

local function remove_irreplaceable(inst)
	if Loading_Chest then inst:RemoveTag("irreplaceable") end --in case something is stored in maxwell's hat
	--inst:RemoveTag("irreplaceable")
	--inst:AddTag("PLREBALANCE_canirreplaceable")

	if not TheWorld.plrebalance or not TheWorld.plrebalance.irreplaceable_tracker then
		TheWorld.plrebalance = TheWorld.plrebalance or {}
		TheWorld.plrebalance.irreplaceable_tracker = {}
	end
	
	local tracker = TheWorld.plrebalance.irreplaceable_tracker
	tracker[inst.prefab] = tracker[inst.prefab] or {}
	local list = tracker[inst.prefab]
	list[inst] = true
	
	inst:ListenForEvent("onremove", Irreplaceable_OnRemove)
	inst:ListenForEvent("onputininventory", Irreplaceable_OnPutInInventory)
	inst:ListenForEvent("ondropped", Irreplaceable_OnDropped)
	--inst:ListenForEvent("entitywake", Irreplaceable_OnWake)
end

AddPrefabPostInit("key_to_city", remove_irreplaceable)
AddPrefabPostInit("city_hammer", remove_irreplaceable)
AddPrefabPostInit("pigcrownhat", remove_irreplaceable)

---------------------------------------------------------------------------------
--fix disgusting bug in interiorvisitor_replica

local interiorvisitor_replica = require("components/interiorvisitor_replica")

function interiorvisitor_replica:RemoveInteriorMapData(data)
    for _, id in ipairs(data) do
        self.interior_map[id] = nil
    end
    self.inst:PushEvent("refresh_interior_minimap")
end


local InteriorSpawner = require("components/interiorspawner")
local _ClearInteriorContents = InteriorSpawner.ClearInteriorContents

local function teleport(entity, position)
    if entity.Physics then
        entity.Physics:Teleport(position:Get())
    else
        entity.Transform:SetPosition(position:Get())
    end
end

function InteriorSpawner:ClearInteriorContents(pos, exterior_pos)
	local ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.ROOM_FINDENTITIES_RADIUS, nil, {"_inventoryitem"})
    if #ents > 0 then
        for _, v in ipairs(ents) do
			v:PushEvent("pl_clearfrominterior", {exterior_pos = exterior_pos})
			if v:HasTag("woby") or v:HasTag("wormwood_pet") or v:HasTag("critter") then
				teleport(v, exterior_pos)
			end
			-- 新增：商店老板离开桌子处理
            if v:IsValid() and not v:IsInLimbo() and (v:HasTag("shopkeep") or v.prefab == "pigman_shopkeeper_desk") then
                v:Remove()
            end
		end
	end
	_ClearInteriorContents(self, pos, exterior_pos)
end
