--[[

	Operation guide
	inst.rooms => inst.newrooms
	call CreateInterior
	Once done, inst.newrooms replace inst.rooms
	
	Line 296 - Replace with a check for 2 valid prefabs
]]--

local GenerateProps = require("prefabs/interior_prop_defs")

local assets =
{
    Asset("ANIM", "anim/ant_hill_entrance.zip"),
    Asset("ANIM", "anim/ant_queen_entrance.zip"),
}

local prefabs =
{
    "antman",
    "antman_warrior",
    "int_ceiling_dust_fx",
    "antchest",
    "giantgrub",
    "ant_cave_lantern",
    "antqueen",
}

local QUEEN_CHAMBER_COUNT_MAX = 6
local QUEEN_CHAMBER_COUNT_MIN = 3

local ANT_CAVE_DEPTH = 18
local ANT_CAVE_WIDTH = 26
local ANT_CAVE_HEIGHT = 7
local ANT_CAVE_FLOOR_TEXTURE = "levels/textures/interiors/antcave_floor.tex"
local ANT_CAVE_WALL_TEXTURE = "levels/textures/interiors/antcave_wall_rock.tex"
local ANT_CAVE_MINIMAP_TEXTURE = "levels/textures/map_interior/mini_antcave_floor.tex"
local ANT_CAVE_COLOUR_CUBE = "images/colour_cubes/pigshop_interior_cc.tex"

local ANTHILL_DUNGEON_NAME = "ANTHILL1"

-- Each value here indicates how many of the 25 rooms are created with each room setup.
local ANTHILL_EMPTY_COUNT = 7
local ANTHILL_ANT_HOME_COUNT = 5
local ANTHILL_WANDERING_ANT_COUNT = 10
local ANTHILL_TREASURE_COUNT = 3
local ROOM_CARDINALITY = {ANTHILL_EMPTY_COUNT, ANTHILL_ANT_HOME_COUNT, ANTHILL_WANDERING_ANT_COUNT, ANTHILL_TREASURE_COUNT}

local dir_names = { "east", "west", "north", "south" }
local dirNamesOpposite = { "west", "east", "south", "north" }

local EAST_DOOR_IDX  = 1
local WEST_DOOR_IDX  = 2
local NORTH_DOOR_IDX = 3
local SOUTH_DOOR_IDX = 4
local NUM_ENTRANCES = 3
local NUM_CHAMBER_ENTRANCES = 1
local NUM_ROWS = 5
local NUM_COLS = 5

local function ChooseEntrances(inst)
    local num_entrances_chosen = 0

    repeat
        local row_index = math.random(1, NUM_ROWS)
        local col_index = math.random(1, NUM_COLS)

        if not inst.newrooms[row_index][col_index].is_entrance then
            inst.newrooms[row_index][col_index].is_entrance = true
            num_entrances_chosen = num_entrances_chosen + 1
        end
    until (num_entrances_chosen == NUM_ENTRANCES)
end

local function ChooseChamberEntrances(inst)
   local num_entrances_chosen = 0

    repeat
        local row_index = math.random(1, NUM_ROWS)
        local col_index = math.random(1, NUM_COLS)

        if not inst.newrooms[row_index][col_index].is_entrance and not inst.newrooms[row_index][col_index].isChamberEntrance then
            inst.newrooms[row_index][col_index].isChamberEntrance = true
            num_entrances_chosen = num_entrances_chosen + 1
        end
    until (num_entrances_chosen == NUM_CHAMBER_ENTRANCES)
end

local function ConnectRooms(dirIndex, room_from, room_to)
    local interior_spawner = TheWorld.components.interiorspawner
    local dirs = interior_spawner:GetDir()
    local dirs_opposite = interior_spawner:GetDirOpposite()

    room_from.exits[dirs[dirIndex]] = {
        target_room = room_to.id,
        bank  = "ant_cave_door",
        build = "ant_cave_door",
        room  = room_from.id,
        sg_name = "SGanthilldoor_" .. dir_names[dirIndex],
        startstate = "idle",
    }

    room_to.exits[dirs_opposite[dirIndex]] = {
        target_room = room_from.id,
        bank  = "ant_cave_door",
        build = "ant_cave_door",
        room  = room_to.id,
        sg_name = "SGanthilldoor_" .. dirNamesOpposite[dirIndex],
        startstate = "idle",
    }
end

local function ConnectDoors(inst)
    for i = 1, NUM_ROWS do
        for j = 1, NUM_COLS do
            local current_room = inst.newrooms[i][j]

            -- EAST
            if (current_room.x + 1) <= NUM_COLS then
                local room_east = inst.newrooms[current_room.y][current_room.x + 1]
                ConnectRooms(EAST_DOOR_IDX, current_room, room_east)
            end

            -- WEST
            if (current_room.x - 1) >= 1 then
                local room_west = inst.newrooms[current_room.y][current_room.x - 1]
                ConnectRooms(WEST_DOOR_IDX, current_room, room_west)
            end

            -- NORTH
            if ((current_room.y - 1) >= 1) and not current_room.is_entrance then
                local room_north = inst.newrooms[current_room.y - 1][current_room.x]
                -- The entrance is always from the north, so when attempting to link to a northern room, give up if the current room is an entrance.
                ConnectRooms(NORTH_DOOR_IDX, current_room, room_north)
            end

            -- SOUTH
            if (current_room.y + 1) <= NUM_ROWS then
                local room_south = inst.newrooms[current_room.y + 1][current_room.x]
                -- The entrance is always from the north, so when attempting to link to a southern room, give up if it's an entrance.
                if not room_south.is_entrance then
                    ConnectRooms(SOUTH_DOOR_IDX, current_room, room_south)
                end
            end
        end
    end
end

local function BuildGrid(inst)
    local interior_spawner = TheWorld.components.interiorspawner
    --修改标记 inst.rooms >> inst.newrooms
    inst.newrooms = {}

    for i = 1, NUM_ROWS do
        local roomRow = {}

        for j = 1, NUM_COLS do
            local room = {
                x = j,
                y = i,
                id = interior_spawner:GetNewID(),
                exits = {},
                is_entrance = false,
                isChamberEntrance = false,
                parent_room = nil,
                doors_enabled = {false, false, false, false},
                dirs_explored = {false, false, false, false},
            }

            table.insert(roomRow, room)
        end

        table.insert(inst.newrooms, roomRow)
    end

    ChooseEntrances(inst)
    ChooseChamberEntrances(inst)

    -- All possible doors are built, and then the doors_enabled flag
    -- is what indicates if they should actually be in use or not.
    ConnectDoors(inst)
end

local function RebuildGrid(inst)
    for i = 1, NUM_ROWS do
        for j = 1, NUM_COLS do
            inst.newrooms[i][j].parent_room = nil
            inst.newrooms[i][j].doors_enabled = {false, false, false, false}
            inst.newrooms[i][j].dirs_explored = {false, false, false, false}
        end
    end
end

local function link(inst, room)
    local row = 0
    local col = 0

    local dirsOpposite = { WEST_DOOR_IDX, EAST_DOOR_IDX, SOUTH_DOOR_IDX, NORTH_DOOR_IDX }

    if room == nil then
        return nil
    end

    -- While there are still directions to explore.
    while not (room.dirs_explored[EAST_DOOR_IDX]
        and room.dirs_explored[WEST_DOOR_IDX]
        and room.dirs_explored[NORTH_DOOR_IDX]
        and room.dirs_explored[SOUTH_DOOR_IDX]) do
        local dirIndex = math.random(#room.dirs_explored)

        -- If already explored, then try again.
        if not room.dirs_explored[dirIndex] then
            room.dirs_explored[dirIndex] = true

            local dirPossible = false
            if dirIndex == EAST_DOOR_IDX then -- EAST
                if (room.x + 1 <= NUM_COLS) then
                    col = room.x + 1
                    row = room.y
                    dirPossible = true
                end
            elseif dirIndex == SOUTH_DOOR_IDX then -- SOUTH
                if (room.y + 1 <= NUM_ROWS) then
                    -- The entrance is always from the north, so when attempting
                    -- to link to a southern room, give up if it's an entrance.
                    local destRoom = inst.newrooms[room.y + 1][room.x]
                    if not destRoom.is_entrance then
                        col = room.x
                        row = room.y + 1
                        dirPossible = true
                    end
                end
            elseif dirIndex == WEST_DOOR_IDX then -- WEST
                if (room.x - 1 >= 1) then
                    col = room.x - 1
                    row = room.y
                    dirPossible = true
                end
            elseif dirIndex == NORTH_DOOR_IDX then -- NORTH
                -- The entrance is always from the north, so when attempting to link
                -- to a northern room, give up if the current room is an entrance.
                if ((room.y - 1 >= 1) and not room.is_entrance) then
                    col = room.x
                    row = room.y - 1
                    dirPossible = true
                end
            end

            if dirPossible then
                -- Get destination node into pointer (makes things a tiny bit faster)
                local destination_room = inst.newrooms[row][col]

                if (destination_room.parent_room == nil) then -- If destination is a linked node already - abort
                    destination_room.parent_room = room -- Otherwise, adopt node
                    room.doors_enabled[dirIndex] = true -- Remove wall between nodes (ie. Create door.)
                    destination_room.doors_enabled[dirsOpposite[dirIndex]] = true

                    -- Return address of the child node
                    return destination_room
                end
            end
        end
    end

    -- If nothing more can be done here - return parent's address
    return room.parent_room
end

local function BuildWalls(inst)
    local start_room = inst.newrooms[1][1]
    start_room.parent_room = start_room
    local last_room = start_room

    -- Connect nodes until start node is reached and can't be left
    repeat
        last_room = link(inst, last_room)
    until (last_room == start_room)
end

local room_types = {"anthill_empty", "anthill_ant_home", "anthill_wandering_ant", "anthill_treasure"}

local function CreateRegularRooms(inst)
    local interior_spawner = TheWorld.components.interiorspawner

    local room_id_list = {}
    for room_id, cardinality in pairs(ROOM_CARDINALITY) do
        for i = 1, cardinality do
            table.insert(room_id_list, room_id)
        end
		Yield()
    end
    room_id_list = shuffleArray(room_id_list)

    local doorway_count = 1
    local current_room_setup_index = 1
    local doorways = JoinArrays({inst}, TheWorld.components.globalentityregistry:Get("ant_hill_exit"))

    for i = 1, NUM_ROWS do
        for j = 1, NUM_COLS do
            local room = inst.newrooms[i][j]
            local room_type = room_types[room_id_list[current_room_setup_index]]
            current_room_setup_index = current_room_setup_index + 1

            local addprops = GenerateProps(room_type, ANT_CAVE_DEPTH, ANT_CAVE_WIDTH, room, doorway_count, doorways)

            if room.is_entrance then
                local exterior_door_def = {
                    my_door_id = "ANTHILL_" .. doorway_count .. "_ENTRANCE",
                    target_door_id = "ANTHILL_" .. doorway_count .. "_EXIT",
                    target_interior = room.id,
                }

                local doorway = doorways[doorway_count]
                doorway.interiorID = room.id
                doorway.doorway_index = doorway_count
                TheWorld.components.interiorspawner:AddDoor(doorway, exterior_door_def)
                TheWorld.components.interiorspawner:AddExterior(doorway)

                doorway_count = doorway_count + 1
            end
			Yield()
            interior_spawner:CreateRoom({
                width = ANT_CAVE_WIDTH,
                height = ANT_CAVE_HEIGHT,
                depth = ANT_CAVE_DEPTH,
                dungeon_name = ANTHILL_DUNGEON_NAME,
                roomindex = room.id,
                addprops = addprops,
                exits = room.exits,
                walltexture = ANT_CAVE_WALL_TEXTURE,
                floortexture = ANT_CAVE_FLOOR_TEXTURE,
                minimaptexture = ANT_CAVE_MINIMAP_TEXTURE,
                colour_cube = ANT_CAVE_COLOUR_CUBE,
                reverb = "anthill",
                ambient_sound = "ANT_HIVE",
                footstep_tile = WORLD_TILES.DIRT,
                cameraoffset = nil,
                zoom = nil,
                group_id = inst.newrooms[1][1].id,
                interior_coordinate_x = room.x,
                interior_coordinate_y = -room.y,
            })
			Yield()
            local center_ent = interior_spawner:GetInteriorCenter(room.id)
            
            if not center_ent:HasTag("anthill") then
                center_ent:AddTag("anthill") -- need this for dynamic music
            end
        end
    end
end

local function SetCurrentDoorHiddenStatus(door, show, direction)
    local isaleep = door:IsAsleep()
    if show and door.components.door.hidden then
        if isaleep then
            door.components.door:SetHidden(false)
            door.sg:GoToState("idle")
        else
            door.sg:GoToState("open")
        end
        door.animchangetime = GetTime()
        door.dooranimclosed = nil
    elseif not show and not door.components.door.hidden then
        if isaleep then
            door.components.door:SetHidden(true)
            door.sg:GoToState("idle")
        else
            door.sg:GoToState("shut")
        end
        door.animchangetime = GetTime()
        door.dooranimclosed = true
    end
end

local function RefreshCurrentDoor(room, door)
    if not door.components.door then
        return
    end
    if door.components.door.target_interior == "EXTERIOR" then
        return
    end

    if door:HasTag("door_north") then
        SetCurrentDoorHiddenStatus(door, room.doors_enabled[NORTH_DOOR_IDX], "north")
    elseif door:HasTag("door_south") then
        SetCurrentDoorHiddenStatus(door, room.doors_enabled[SOUTH_DOOR_IDX], "south")
    elseif door:HasTag("door_east") then
        SetCurrentDoorHiddenStatus(door, room.doors_enabled[EAST_DOOR_IDX], "east")
    elseif door:HasTag("door_west") then
        SetCurrentDoorHiddenStatus(door, room.doors_enabled[WEST_DOOR_IDX], "west")
    end
end

local function RefreshDoors(inst)
    local interior_spawner = TheWorld.components.interiorspawner
    for i = 1, NUM_ROWS do
        for j = 1, NUM_COLS do
            local room = inst.newrooms[i][j]

            local centre = interior_spawner:GetInteriorCenter(room.id)
            local x, y, z = centre.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, TUNING.ROOM_FINDENTITIES_RADIUS, {"interior_door"})
            for _, door in pairs(ents) do
                RefreshCurrentDoor(room, door)
            end
        end
    end
end

local anthill_funcs = {}
-- Hack this function
function anthill_funcs:CreateInterior(inst)
    BuildGrid(inst)
    CreateRegularRooms(inst) --I will not fix this lag here, too lazy
    BuildWalls(inst)
	Yield()
    RefreshDoors(inst)
    --TheWorld.components.interiorspawner:AddExterior(inst)
end

return anthill_funcs