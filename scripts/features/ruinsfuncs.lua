--[[

	NOTES: When copying this, make note of several changes:
	1 - AddDoor moved to end of thread. Return twice.
	2 - Always replace the ID. Never reuse.
	3 - Ensure exits line up with duplicates.
	4 - Do not change interiorID until generation is done.
	
	

]]--

local GenerateProps = require("prefabs/interior_prop_defs")

local PIG_RUINS_WIDTH = 24
local PIG_RUINS_DEPTH = 16
local PIG_RUINS_ROOM_COUNT = {
    RUINS_1 = 24,
    RUINS_2 = 15,
    RUINS_3 = 15,
    RUINS_4 = 20,
    RUINS_5 = 30,
    RUINS_SMALL = function() return math.random(6, 8) end,
}
local PIG_RUINS_FLOOR_TEXTURE = "levels/textures/interiors/ground_ruins_slab.tex"
local PIG_RUINS_WALL_TEXTURE = "levels/textures/interiors/pig_ruins_panel.tex"
local PIG_RUINS_MINIMAP_TEXTURE = "levels/textures/map_interior/mini_ruins_slab.tex"
local PIG_RUINS_FLOOR_TEXTURE_BLUE = "levels/textures/interiors/ground_ruins_slab_blue.tex"
local PIG_RUINS_WALL_TEXTURE_BLUE = "levels/textures/interiors/pig_ruins_panel_blue.tex"
local PIG_RUINS_COLOUR_CUBE = "images/colour_cubes/pigshop_interior_cc.tex"
local PIG_RUINS_CAVE_REVERB = "ruins"
local PIG_RUINS_CAVE_AMBIENT = "RUINS"
local PIG_RUINS_CAVE_GROUND_SOUND = WORLD_TILES.DIRT

--[[
local assets =
{
    Asset("ANIM", "anim/pig_ruins_entrance.zip"),
    Asset("ANIM", "anim/pig_door_test.zip"),
    Asset("ANIM", "anim/pig_ruins_entrance_build.zip"),
    Asset("ANIM", "anim/pig_ruins_entrance_top_build.zip"),
}

local prefabs =
{
    "deco_roomglow",
    "light_dust_fx",
    "deco_ruins_wallcrumble_1",
    "deco_ruins_wallcrumble_side_1",
    "deco_ruins_cornerbeam",
    "deco_ruins_beam",
    "deco_ruins_wallstrut",
    "deco_ruins_beam_broken",
    "deco_ruins_cornerbeam_heavy",
    "deco_ruins_beam_room",
    "deco_ruins_fountain",
    "pig_ruins_torch_sidewall",
    "deco_ruins_pigman_relief_side",
    "deco_ruins_writing1",

    "pig_ruins_dart",

    "pig_ruins_pressure_plate",

    "pig_ruins_torch_wall",

    "deco_ruins_crack_roots1",
    "deco_ruins_crack_roots2",
    "deco_ruins_crack_roots3",
    "deco_ruins_crack_roots4",

    "deco_ruins_pigqueen_relief",
    "deco_ruins_pigking_relief",

    "deco_ruins_pigman_relief1",
    "deco_ruins_pigman_relief2",
    "deco_ruins_pigman_relief3",

    "pig_ruins_creeping_vines",
    "pig_ruins_wall_vines_north",
    "pig_ruins_wall_vines_east",
    "pig_ruins_wall_vines_west",

    "smashingpot",
    "aporkalypse_clock",
    "wallcrack_ruins"
}]]--

local function GetNumExitsInRoom(room)
    local exits = room.exits
    local total = 0
    for i,exit in pairs(exits) do
        total = total + 1
    end
    if room.entrance1 or room.entrance2 then
        total = total + 1
    end
    return total
end

local function BuildMaze(inst, dungeondef, exterior_door_def)
    local interior_spawner = TheWorld.components.interiorspawner

    local exit_room

    local rooms_to_make = dungeondef.rooms

    local rooms = {
        {
            x = 0,
            y = 0,
            id = exterior_door_def.target_interior,
            exits = {},
            blocked_exits = {interior_spawner:GetNorth()},
            entrance1 = true,
        }
    }

    local clock_placed = false

    while #rooms < rooms_to_make do
        local dir = interior_spawner:GetDir()
        local dir_opposite = interior_spawner:GetDirOpposite()
        local dir_choice = math.random(#dir)
        local room_connecting_to = rooms[math.random(#rooms)]

        local fail = false

        -- fail if this direction from the chosen room is blocked
        for _, exit in pairs(room_connecting_to.blocked_exits) do
            if interior_spawner:GetDir()[dir_choice] == exit then
                fail = true
            end
			Yield()
        end

        -- fail if this room of the maze is already set up.
        if not fail then
            for _, room_to_check in pairs(rooms) do
                if room_to_check.x == room_connecting_to.x + dir[dir_choice].x and room_to_check.y == room_connecting_to.y + dir[dir_choice].y then
                    fail = true
                    break
                end
            end
        end

        if not fail then
            local new_room = {
                x = room_connecting_to.x + dir[dir_choice].x,
                y = room_connecting_to.y + dir[dir_choice].y,
                id = interior_spawner:GetNewID(),
                exits = {},
                blocked_exits = {},
            }

            room_connecting_to.exits[dir[dir_choice]] = {
                target_room = new_room.id,
                bank =  "doorway_ruins",
                build = "pig_ruins_door",
                room = room_connecting_to.id,
            }

            new_room.exits[dir_opposite[dir_choice]] = {
                target_room = room_connecting_to.id,
                bank =  "doorway_ruins",
                build = "pig_ruins_door",
                room = new_room.id,
            }

            -- if TheWorld:IsWorldGenOptionNever("door_vines") then
            --     dungeondef.doorvines = nil
            -- end

            if dungeondef.doorvines and math.random() < dungeondef.doorvines then
                room_connecting_to.exits[dir[dir_choice]].vined = true
                new_room.exits[dir_opposite[dir_choice]].vined = true
            end

            rooms[#rooms + 1] = new_room
        end
		Yield()
    end

    local function CreateSecretRoom()
        local grid = {}

        local function CheckFreeGridPos(x, y)
            for _, room in pairs(rooms) do
                if room.x == x and room.y == y then
                    return false
                end
            end

            return true
        end

        local function CheckAdjacent(room, dir)
            local x = room.x + dir.x
            local y = room.y + dir.y

            if CheckFreeGridPos(x, y) then

                if not grid[x] then
                    grid[x] = {}
                end

                if not grid[x][y] then
                    grid[x][y] = { rooms = {room}, dirs = {dir}}
                else
                    table.insert(grid[x][y].rooms, room)
                    table.insert(grid[x][y].dirs, dir)
                end
            end
        end

        local function FindCandidates()
            for _, room in pairs(rooms) do
                local north = interior_spawner:GetNorth()
                local west = interior_spawner:GetWest()
                local east = interior_spawner:GetEast()

                -- NORTH IS OPEN
                if not room.exits[north] and not room.entrance2 and not room.entrance1 then
                    CheckAdjacent(room, north)
                end

                -- WEST IS OPEN
                if not room.exits[west]  then
                    CheckAdjacent(room, west)
                end

                -- EAST IS OPEN
                if not room.exits[east] then
                    CheckAdjacent(room, east)
                end
				Yield()
            end
        end

        local function GetMax()
            local max_x = 0
            local max_y = 0
            local max = 0

            for k, v in pairs(grid) do
                for k2, v2 in pairs(v) do
                    if #v2.rooms > max then
                        max = #v2.rooms
                        max_x = k
                        max_y = k2
                    end
                end
            end

            if max > 0 then
                return max_x, max_y
            end
        end

        local function PopulateSecretRoom(x, y)
            local secret_room = {
                x = x,
                y = y,
                id = interior_spawner:GetNewID(),
                exits = {},
                blocked_exits ={},
                secretroom = true
            }

            local grid_rooms = grid[x][y].rooms
            local grid_dirs = grid[x][y].dirs

            local bank =  "interior_wall_decals_ruins"
            local build = "interior_wall_decals_ruins_cracks"

            if dungeondef.name == "RUINS_5" and not clock_placed then
                -- reduce the grid_room to 1
                clock_placed = true
                secret_room.aporkalypseclock = true
                while #grid_rooms > 1 do

                    local num = math.random(1, #grid_rooms)
                    table.remove(grid_rooms, num)
                    table.remove(grid_dirs, num)
                    bank =  "doorway_ruins"
                    build = "pig_ruins_door"
                end
            end

            for i, grid_room in ipairs(grid_rooms) do
                local op_dir = interior_spawner:GetOppositeFromDirection(grid_dirs[i])
                local secret = true
                if secret_room.aporkalypseclock == true then
                    secret = false
                end

                secret_room.exits[op_dir] = {
                    target_room = grid_room.id,
                    bank =  bank,
                    build = build,
                    room = secret_room.id,
                    secret = secret,
                }

                grid_room.exits[grid_dirs[i]] = {
                    target_room = secret_room.id,
                    bank =  "interior_wall_decals_ruins",
                    build = "interior_wall_decals_ruins_cracks",
                    room = grid_room.id,
                    secret = true
                }
				Yield()
            end

            grid[x][y] = nil
            return secret_room
        end

        FindCandidates()

        local secret_room_count = dungeondef.secretrooms

        for i=1, secret_room_count do
            local x, y = GetMax()
            if x == nil or y == nil then
                print ("COULDN'T FIND SUITABLE CANDIDATES FOR THE SECRET ROOM.")
            else
                local newroom = PopulateSecretRoom(x, y)
                if newroom then
                    table.insert(rooms, newroom)
                end
            end
			Yield()
        end
    end

    local choices = {}
    local dist = 0
    for _, room in pairs(rooms) do
        local north_exit_open = not room.exits[interior_spawner:GetNorth()]

        if math.abs(room.x) + math.abs(room.y) > dist and north_exit_open then
            choices = {}
        end

        if math.abs(room.x) + math.abs(room.y) >= dist and north_exit_open then
            choices[#choices + 1] = room
            dist = math.abs(room.x) + math.abs(room.y)
        end
		Yield()
    end

    if not dungeondef.no_second_exit then
        if next(choices) then
            exit_room = GetRandomItem(choices)
            exit_room.entrance2 = true
        end
    end

    choices = {}
    for _, room in pairs(rooms) do
        if GetNumExitsInRoom(room) == 1 then
            choices[#choices + 1] = room
        end
    end

    if dungeondef.name == "RUINS_3" then
        GetRandomItem(choices).pheromonestone = true
    elseif dungeondef.name == "RUINS_1" then
        GetRandomItem(choices).relictruffle = true
    elseif dungeondef.name == "RUINS_2" then
        GetRandomItem(choices).relicsow = true
    elseif dungeondef.name == "RUINS_5" then
        dungeondef.advancedtraps = true
        GetRandomItem(choices).endswell = true
    else
        GetRandomItem(choices).treasure = true
    end

    CreateSecretRoom()

    for _, room in pairs(rooms) do
        local roomtypes = {"grown_over", "store_room", "small_treasure", "snake", nil}

        --if GetWorldSetting("spear_traps", true) then
            table.insert(roomtypes, "spear_trap")
        --end

        -- if not TheWorld:IsWorldGenOptionNever("dart_traps") then
            table.insert(roomtypes, "dart_trap")
        -- end

        -- if more than one exit, add the doortrap to the potential list
        if GetNumExitsInRoom(rooms[1]) > 1 and not room.secretroom then
            table.insert(roomtypes, "door_trap")
            table.insert(roomtypes, "door_trap")
        end

        local room_type = GetRandomItem(roomtypes)

        if room.treasure then
            room_type =  "treasure"
        end
        if room.relictruffle or room.relicsow then
            room_type =  "treasure_rarerelic"
        end
        if room.secretroom  then
            room_type = "treasure_secret"
        end
        if room.aporkalypseclock then
            room_type = "treasure_aporkalypse"
        end
        if room.endswell then
            room_type = "treasure_endswell" -- this prevents other features from conflicting with the endswell well.
        end

        local wall_texture = PIG_RUINS_WALL_TEXTURE
        local floor_texture = PIG_RUINS_FLOOR_TEXTURE
        if dungeondef.deepruins and math.random() < 0.3 then
            room.color = "_blue"
        else
            room.color = ""
        end
        if room.color == "_blue" then
            for ii, exit in pairs(room.exits) do
                if exit.build == "pig_ruins_door" then
                    exit.build = "pig_ruins_door_blue"
                end
            end

            wall_texture = PIG_RUINS_WALL_TEXTURE_BLUE
            floor_texture = PIG_RUINS_FLOOR_TEXTURE_BLUE
        end

        local exits_open = {
            west = not room.exits[interior_spawner:GetWest()],
            south = not room.exits[interior_spawner:GetSouth()],
            east = not room.exits[interior_spawner:GetEast()]
        }
        local exits_vined = {
            west = not exits_open.west and room.exits[interior_spawner:GetWest()].vined or false,
            south = not exits_open.south and room.exits[interior_spawner:GetSouth()].vined or false,
            east = not exits_open.east and room.exits[interior_spawner:GetEast()].vined or false,
        }
        local addprops = GenerateProps("pig_ruins_" .. room_type, PIG_RUINS_DEPTH, PIG_RUINS_WIDTH,
            exits_open, exits_vined, room, room_type, dungeondef, exterior_door_def)

        interior_spawner:CreateRoom({
            width = PIG_RUINS_WIDTH,
            height = 5,
            depth = PIG_RUINS_DEPTH,
            dungeon_name = dungeondef.name,
            roomindex = room.id,
            addprops = addprops,
            exits = room.exits,
            walltexture = wall_texture,
            floortexture = floor_texture,
            minimaptexture = PIG_RUINS_MINIMAP_TEXTURE,
            colour_cube = PIG_RUINS_COLOUR_CUBE,
            reverb = PIG_RUINS_CAVE_REVERB,
            ambient_sound = PIG_RUINS_CAVE_AMBIENT,
            footstep_tile = PIG_RUINS_CAVE_GROUND_SOUND,
            cameraoffset = nil,
            zoom = nil,
            group_id = inst.interiorID,
            interior_coordinate_x = room.x,
            interior_coordinate_y = room.y,
        })
		Yield()

        local center_ent = interior_spawner:GetInteriorCenter(room.id)
        center_ent:AddInteriorTags("pig_ruins") -- need this for dynamic music
        
        if not center_ent:HasTag("pig_ruins") then
            center_ent:AddTag("pig_ruins") -- need this for dynamic music
        end
		Yield()
    end

    return exit_room
end

local function InitMaze(inst, dungeonname)
    local dungeondef = {
        name = dungeonname,
        rooms = FunctionOrValue(PIG_RUINS_ROOM_COUNT[dungeonname]),
        lock = true,
        doorvines = 0.3,
        deepruins = true,
        secretrooms = 2,
    }

    if dungeonname == "RUINS_2" then
        dungeondef.doorvines = 0.6
    elseif dungeonname == "RUINS_3" then
        dungeondef.no_second_exit = true
    elseif dungeonname == "RUINS_4" then
        dungeondef.doorvines = 0.4
    elseif dungeonname == "RUINS_5" then
        dungeondef.doorvines = 0.6
        dungeondef.no_second_exit = true
    elseif dungeonname == "RUINS_SMALL" then
        dungeondef.no_second_exit = true
        dungeondef.lock = nil
        dungeondef.doorvines = nil
        dungeondef.deepruins = nil
        dungeondef.secretrooms = 1
        dungeondef.smallsecret = true
    end

    local interior_spawner = TheWorld.components.interiorspawner
    local id = interior_spawner:GetNewID()
	
	local oldInteriorID = inst.interiorID
	inst.interiorID = id
	inst.plRebalance_newinteriorID = id
	
    local exterior_door_def = { --put after so new ruins are generated before the door is linked
        my_door_id = dungeondef.name .. "_ENTRANCE1",
        target_door_id = dungeondef.name .. "_EXIT1",
        target_interior = id,
    }
	
    interior_spawner:AddExterior(inst)
	
	inst.interiorID = oldInteriorID
	Yield()
    BuildMaze(inst, dungeondef, exterior_door_def)
	
	return exterior_door_def --we call AddDoor after the ruins are finished
end

local ruinsfuncs = {}

function ruinsfuncs.OnLoad(inst)

    return InitMaze(inst, inst.dungeon_name) --pass it back to the thread
    --RefreshBuild(inst)
end

function ruinsfuncs.OnLoadPostPass(inst) -- 出口的连接写在 OnLoadPostPass 中，这样才能确定所有储存的实体已经添加进世界
    if inst.is_entrance then
        -- For exit only
        return
    end
    -- Prevent ruins exit from detecting the same door
	local prev_door = inst.interiorID
	-- Set our interior id to the interior id of the door that points to us
	local exit_room_id
	for _, ent in pairs(Ents) do
		if ent.components.door and ent.components.door.target_door_id == inst.dungeon_name .. "_ENTRANCE2" then
			local test_door = ent.components.door.interior_name --prevent the same door from being detected
			if test_door ~= prev_door then
				exit_room_id = test_door
				break
			end
		end
	end
	local exterior_door_def2 = {
		my_door_id = inst.dungeon_name .. "_ENTRANCE2",
		target_door_id = inst.dungeon_name .. "_EXIT2",
		target_interior = exit_room_id,
	}
	inst.interiorID = exit_room_id
	TheWorld.components.interiorspawner:AddDoor(inst, exterior_door_def2)
	TheWorld.components.interiorspawner:AddExterior(inst)
end

return ruinsfuncs