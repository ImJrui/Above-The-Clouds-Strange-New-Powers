GLOBAL.setfenv(1, GLOBAL)

local candidates = {
	"pig_ruins_entrance",
	"pig_ruins_entrance2",
	"pig_ruins_entrance3",
	"pig_ruins_entrance4",
	"pig_ruins_entrance5",
	"pig_ruins_entrance_small",
	"pig_ruins_exit",
	"pig_ruins_exit2",
	"pig_ruins_exit3",
	"pig_ruins_exit4",
	"pig_ruins_exit5",
}

local candidates_anthill = {
	"anthill",
	"anthill_exit",
}

function c_pl_RegenerateRuins()
	local inst = nil
	for _, v in ipairs(candidates) do
		inst = c_selectnear(v, 10)
		if inst then break end
	end
	plrebutil_RuinsRegenerator:RegenerateRuins(inst)
end

function c_pl_RegenerateAnthill()
	local inst = nil
	for _, v in ipairs(candidates_anthill) do
		inst = c_selectnear(v, 10)
		if inst then break end
	end
	plrebutil_RuinsRegenerator:RegenerateAnthill(inst)
end

local function GetDoorToExterior(inst, id) --custom func to get invalid doors
    local x, _, z = inst.Transform:GetWorldPosition()
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, TUNING.ROOM_FINDENTITIES_RADIUS, {"interior_door", "door_exit"})) do
		local door = v.components.door
        local id = door.target_exterior or door.interior_name
        local house = TheWorld.components.interiorspawner:GetExteriorById(id)
		if house and house.components.door.target_interior == id then
			return v
		end
    end
end

local function c_pl_markvalidrooms(self)
    local rooms_with_exit = {}
	local valid_rooms = {}
    for id, center in pairs(self.interiors) do
         if GetDoorToExterior(center, id) then
			rooms_with_exit[#rooms_with_exit + 1] = center
		 end
    end

    local function WalkConnectedRooms(center, group_id, coord_x, coor_y)
		if valid_rooms[center] then return end
        valid_rooms[center] = true		

        local x, _, z = center.Transform:GetWorldPosition()
        for _, door in ipairs(TheSim:FindEntities(x, 0, z, TUNING.ROOM_FINDENTITIES_RADIUS, {"interior_door"}, {"predoor"})) do
            local target_interior = door.components.door.target_interior
            if target_interior and target_interior ~= "EXTERIOR" then
                local door_direction
                for _, direction in ipairs(self:GetDir()) do
                    if door:HasTag("door_"..direction.label) then
                        door_direction = direction
                        break
                    end
                end
                if door_direction then
                    local room = self:GetInteriorCenter(target_interior)
                    WalkConnectedRooms(room, group_id, coord_x + door_direction.x, coor_y + door_direction.y)
                else
                    print("This door doesn't have a direction!", door)
                end
            end
        end
    end

    for _, center in ipairs(rooms_with_exit) do
        WalkConnectedRooms(center, center.interiorID, 0, 0)
    end
	
	local invalid_rooms = {}
	
    for id, center in pairs(self.interiors) do
		if not valid_rooms[center] then
         table.insert(invalid_rooms, center)
		end
    end
	return invalid_rooms
end

function c_pl_CountInteriorMemoryLeaks() --counts the number of interiors not attached to an exterior. in case you save/load right at the most unfortunate time and causes interiors to pile up. will return a positive value when regenerating ruins.
	local interiorspawner = TheWorld.components.interiorspawner
	
	local rv = c_pl_markvalidrooms(interiorspawner)
	print("[孙悟空] ", #rv, "NOT PROPERLY ATTACHED")
end

function c_pl_RemoveInteriorMemoryLeaks() --in case you save/load right at the most unfortunate time and causes interiors to pile up. use countmemoryleaks first. use only if absolutely necessary.
	local interiorspawner = TheWorld.components.interiorspawner
	
	local rv = c_pl_markvalidrooms(interiorspawner)
	for _, v in ipairs(rv) do
		interiorspawner:_ClearInteriorContents(v:GetPosition(), ThePlayer:GetPosition())
	end
	print("[孙悟空] ", #rv, "CLEARED")
end
