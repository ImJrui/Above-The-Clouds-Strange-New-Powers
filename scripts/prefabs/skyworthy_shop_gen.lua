--pigshop stuff
local PIG_SHOP_TEXTURE = {
    DEFAULT = {
        FLOOR   = "levels/textures/interiors/shop_floor_hexagon.tex",
        WALL    = "levels/textures/interiors/shop_wall_circles.tex",
        MINIMAP = "levels/textures/map_interior/mini_floor_shag_carpet.tex",
    },
    SKYWORTHY_SHOP = {
        FLOOR   = "levels/textures/interiors/floor_shag_carpet.tex",
        WALL    = "levels/textures/interiors/shop_wall_moroc.tex",
        MINIMAP = "levels/textures/map_interior/mini_floor_shag_carpet.tex",
    },
}
local PIG_SHOP_COLOUR_CUBE = "images/colour_cubes/pigshop_interior_cc.tex"

local PIG_SHOP_REVERB = "inside"
local PIG_SHOP_AMBIENT_SOUND = "STORE"
local PIG_SHOP_FOOTSTEP = WORLD_TILES.WOODFLOOR

local GetPropDef = require("prefabs/plrebalance_interior_prop_defs")

local ROOM_DEFS = {
	{
		doors = {
			{
				my = "_exit",
				target = "_door",
			},
			{
				my = "_1",
				target = "_2",
				targetinterior = 2
			},
			{
				my = "_2",
				target = "_3",
				targetinterior = 3
			},
		},
		depth = 18,
		width = 26,
		height = 13,
		interior_coordinate_x = 0,
		interior_coordinate_y = 0,

		tex = "SKYWORTHY_SHOP",
		key = "skyworthy_shop",
	},
	{
		doors = {
			{
				my = "_2",
				target = "_1",
				targetinterior = 1
			},
		},
		depth = 18,
		width = 26,
		height = 13,
		interior_coordinate_x = -1,
		interior_coordinate_y = 0,

		tex = "SKYWORTHY_SHOP",
		key = "skyworthy_shop_2",
	},
	{
		doors = {
			{
				my = "_3",
				target = "_2",
				targetinterior = 1
			},
		},
		depth = 18,
		width = 26,
		height = 13,
		interior_coordinate_x = 1,
		interior_coordinate_y = 0,

		tex = "SKYWORTHY_SHOP",
		key = "skyworthy_shop_3",
	},
}

local function InitShopped(room_id, shop_type)
    local room_position = TheWorld.components.interiorspawner:IndexToPosition(room_id)
    if shop_type then
        local pedestals = TheSim:FindEntities(room_position.x, room_position.y, room_position.z, 10, {"shop_pedestal"})
        for _, pedestal in ipairs(pedestals) do
            pedestal:InitShop(shop_type)
        end
    end
    local shelves = TheSim:FindEntities(room_position.x, room_position.y, room_position.z, 10, {"shelf"})
    for _, shelf in ipairs(shelves) do
        shelf:AddComponent("shopped")
        shelf.components.shopped:SetCost("oinc", 1)
    end
end

local function GenerateInteriorRoom(inst, name, interiorIDs, index)
    local interior_spawner = TheWorld.components.interiorspawner
	local myRoomDef = ROOM_DEFS[index]
	local id = interiorIDs[index]
	local door_defs = {}
	for _, v in ipairs(myRoomDef.doors) do
		door_defs[#door_defs + 1] = {
			my_door_id = name .. v.my,
			target_door_id = name .. v.target,
			target_interior = v.targetinterior and interiorIDs[v.targetinterior] or nil,
		}
	end
	
	local interior_coordinate_x = myRoomDef.interior_coordinate_x
	local interior_coordinate_y = myRoomDef.interior_coordinate_y
	
	local depth = myRoomDef.depth
    local width = myRoomDef.width
    local height = myRoomDef.height

    local textures = PIG_SHOP_TEXTURE[myRoomDef.tex]
    local floor_texture = textures and textures.FLOOR or PIG_SHOP_TEXTURE.DEFAULT.FLOOR
    local wall_texture = textures and textures.WALL or PIG_SHOP_TEXTURE.DEFAULT.WALL
    local minimap_texture = textures and textures.MINIMAP or PIG_SHOP_TEXTURE.DEFAULT.MINIMAP
	
	local addprops = GetPropDef(myRoomDef.key, depth, width, unpack(door_defs))

    local cityID = inst.components.citypossession and inst.components.citypossession.cityID

	interior_spawner:CreateRoom({
        width = width,
        height = height,
        depth = depth,
        dungeon_name = name,
        roomindex = id,
        addprops = addprops,
        exits = {},
        walltexture = wall_texture,
        floortexture = floor_texture,
        minimaptexture = minimap_texture,
        cityID = cityID,
        colour_cube = PIG_SHOP_COLOUR_CUBE,
        reverb = PIG_SHOP_REVERB,
        ambient_sound = PIG_SHOP_AMBIENT_SOUND,
        footstep_tile = PIG_SHOP_FOOTSTEP,
        cameraoffset = nil,
        zoom = nil,
        group_id = inst.interiorID,
        interior_coordinate_x = interior_coordinate_x,
        interior_coordinate_y = interior_coordinate_y,
    })

    local center_ent = interior_spawner:GetInteriorCenter(id)
    center_ent:AddInteriorTags("pig_shop") -- need this for dynamic music
    
    if not center_ent:HasTag("skyworthy_shop") then
        center_ent:AddTag("skyworthy_shop") -- need this for dynamic music
    end

    InitShopped(id, myRoomDef.key)
end

local function CreateInterior(inst)
    local id = inst.interiorID
    local can_reuse_interior = id ~= nil

    local interior_spawner = TheWorld.components.interiorspawner
	local interiorIDs = {}
    if not can_reuse_interior then
	
		for i=1, #ROOM_DEFS do
			interiorIDs[#interiorIDs + 1] = interior_spawner:GetNewID()
			print("CreateInterior id:", interiorIDs[#interiorIDs])
		end
        id = interiorIDs[1]
        inst.interiorID = id
        --print("CreateInterior id:", id)
    end

    local name = inst.prefab .. id

    local exterior_door_def = {
        my_door_id = name .. "_door",
        target_door_id = name .. "_exit",
        target_interior = id,
    }
    interior_spawner:AddDoor(inst, exterior_door_def)
    interior_spawner:AddExterior(inst)

    if can_reuse_interior then
        -- Reuse old interior, but we still need to re-register the door
        return
    end
	for i=1, #ROOM_DEFS do
		GenerateInteriorRoom(inst, name, interiorIDs, i)
	end
end

return CreateInterior