local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function CalculateFollowerOffset(playerPos)
	local x, y, z = playerPos:Get()
	
	local rand = math.random() * math.pi * 2
	local offset = FindWalkableOffset(playerPos, rand, 2, 10, false, true, NoHoles)
	if offset ~= nil then
		x = x + offset.x
		z = z + offset.z
	end
    return Vector3(x, 0, z)
end

--[[ 功能更简单的方案，计算量低
local function CalculateFollowerOffset(playerPos, baseDirection, distance)
    -- 归一化基础方向向量，确保它是单位向量
    -- local baseDirNorm = baseDirNorm:GetNormalized() -- 在外部归一化
    -- 生成随机角度在[-90, 90]度之间
    local angleDeg = math.random(-90, 90)
    local angleRad = math.rad(angleDeg)  -- 转换为弧度，用于数学计算

    -- 旋转基础方向向量围绕y轴（垂直轴），模拟2D平面上的角度变化
    local x = baseDirNorm.x
    local z = baseDirNorm.z
    local cosA = math.cos(angleRad)
    local sinA = math.sin(angleRad)
    local newX = x * cosA - z * sinA  -- 新x分量
    local newZ = x * sinA + z * cosA  -- 新z分量
    local newDir = Vector3(newX, 0, newZ):GetNormalized()  -- 创建新方向向量并归一化

    -- 计算偏移向量
    local offsetVec = newDir * distance
    -- 返回随从的新位置：玩家位置加上偏移
    return playerPos + offsetVec
end
]]

local function DoTeleport(inst, pos)
    inst:StartThread(function()
        local x, y, z = pos:Get()

        if TheWorld.components.interiorspawner
            and (TheWorld.components.interiorspawner:IsInInteriorRegion(x, z)
            and not TheWorld.components.interiorspawner:IsInInteriorRoom(x, z)) then

        else
            if inst.Physics ~= nil then
                inst.Physics:Teleport(x, y, z)
            elseif inst.Transform ~= nil then
                inst.Transform:SetPosition(x, y, z)
            end
        end
    end)
end

local function GetLinkedFollows(doer)
    local linkedfollows = {}
    local function CheckFollowerItem(cont)
        for slot, item in pairs(cont) do
            if item and item.components.leader and item.components.leader.followers then
                table.insert(linkedfollows, item.components.leader.followers)
            end
        end
    end

    local inv = doer.components.inventory.itemslots
    CheckFollowerItem(inv)

    local activeitem = {}
    activeitem["activeitem"] = doer.components.inventory:GetActiveItem()
    CheckFollowerItem(activeitem)

    for k, equipped in pairs(doer.components.inventory.equipslots) do
        local cont = equipped and equipped.components.container and equipped.components.container.slots or {}
        CheckFollowerItem(cont)
    end

    return linkedfollows
end

local CANT_TAGS = {"shopkeep", "gnarwail", "hitched"}

local function ShouldTeleportFollower(follower)
    if follower.components.follower and follower.components.follower.noleashing then
        return false
    end

    if follower.components.inventoryitem and follower.components.inventoryitem:IsHeld() then
        return false
    end

    if follower.components.rideable and follower.components.rideable:IsBeingRidden() then
        return false
    end

    for _, tag in ipairs(CANT_TAGS) do
        if follower:HasTag(tag) then
            return false
        end
    end

    return true
end

local function TeleportFollowers(followers, playerPos)--[[, baseDirection, distance)]]
    for follower, v in pairs(followers) do
        if ShouldTeleportFollower(follower) then
            local pos = CalculateFollowerOffset(playerPos)
            -- local pos = CalculateFollowerOffset(playerPos, baseDirection, distance)
            DoTeleport(follower, pos)
            -- print("tutu:teleported "..follower.prefab.." to "..pos.x..","..pos.y..","..pos.z)
        end
    end
end

AddComponentPostInit("door", function(Door)
    local _Activate = Door.Activate

    function Door:Activate(doer, ...)
        local result = _Activate(self, doer, ...)

        if not result then
            return result
        end

        local followers = doer.components.leader.followers
        local linkedfollows = GetLinkedFollows(doer)
        local bigbernies = doer.bigbernies or {}

        if self.target_interior == "EXTERIOR" then
            local id = self.target_exterior or self.interior_name
            local house = TheWorld.components.interiorspawner:GetExteriorById(id)
            if house then
                local playerPos = house:GetPosition() + Vector3(house:GetPhysicsRadius(1), 0, 0)
                -- local baseDirection = (playerPos - house:GetPosition()):GetNormalized()
                -- local distance = doer.Physics:GetRadius() * math.random(1, 1.5)

                TeleportFollowers(followers, playerPos)
                TeleportFollowers(bigbernies, playerPos)
                for _, _followers in pairs(linkedfollows) do
                    TeleportFollowers(_followers, playerPos)
                end
            end
        else
            local room = TheWorld.components.interiorspawner:GetInteriorCenter(self.target_interior)
            local target_door = room and room:GetDoorById(self.target_door_id)
            if target_door then
                local door_pos = target_door:GetPosition()
                local offset = target_door.components.door:GetOffsetPos(doer)
                local playerPos = door_pos + offset
                -- local baseDirection = offset
                -- local distance = doer.Physics:GetRadius() * math.random(1, 1.5)

                TeleportFollowers(followers, playerPos)
                TeleportFollowers(bigbernies, playerPos)
                for _, _followers in pairs(linkedfollows) do
                    TeleportFollowers(_followers, playerPos)
                end
            end
        end

        return result
    end
end)