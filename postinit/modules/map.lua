GLOBAL.setfenv(1, GLOBAL)

local worldtiledefs = require("worldtiledefs")

local function IsNearOther(other, pt, min_spacing_sq, min_spacing)
    --FindEntities range check is <=, but we want <
	if min_spacing_sq <= 0 and other:HasTag("structure") then
		--special case (e.g. minisigns use DEPLOYSPACING.NONE)
		if other.deploy_extra_spacing then
			min_spacing_sq = other.deploy_extra_spacing * other.deploy_extra_spacing
		end
	elseif other.deploy_smart_radius then
		min_spacing = other.deploy_smart_radius + (min_spacing or math.sqrt(min_spacing_sq)) / 2
		min_spacing_sq = min_spacing * min_spacing
	elseif other.deploy_extra_spacing then
		min_spacing_sq = math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq)
	elseif other.replica.inventoryitem then
		min_spacing = other:GetPhysicsRadius(0.5) + (min_spacing or math.sqrt(min_spacing_sq)) / 2
		min_spacing_sq = math.min(min_spacing * min_spacing, min_spacing_sq)
	end
	return other:GetDistanceSqToPoint(pt) < min_spacing_sq
end

local function IsNearOtherWallOrPlayer(other, pt, min_spacing_sq, min_spacing)
    if other:HasTag("wall") or other:HasTag("player") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
	return IsNearOther(other, pt, min_spacing_sq, min_spacing)
end

function Map:IsVisualInteriorAtPoint(x, y, z)
    if TheWorld.components.interiorspawner and TheWorld.components.interiorspawner:IsInInteriorRegion(x, z) then
        return TheWorld.components.interiorspawner:IsInInteriorRoom(x, z)
    end
    return false
end

local _ReverseIsVisualGroundAtPoint = Map.ReverseIsVisualGroundAtPoint
function Map:ReverseIsVisualGroundAtPoint(x, y, z) -- 视觉陆地定义为 室内 + 陆地
    if TheWorld:HasTag("porkland") then
        return _ReverseIsVisualGroundAtPoint(self, x, y, z)
    end
    return self:IsVisualInteriorAtPoint(x, y, z) or self:_IsVisualGroundAtPoint(x, y, z)
end

local _ReverseIsVisualWaterAtPoint = Map.ReverseIsVisualWaterAtPoint
function Map:ReverseIsVisualWaterAtPoint(x, y, z) -- 非猪镇的水域 = 水域 - 陆地
    if TheWorld:HasTag("porkland") then
        return _ReverseIsVisualWaterAtPoint(self, x, y, z)
    end
    return self:IsOceanTileAtPoint(x, y, z) and not self:ReverseIsVisualGroundAtPoint(x, y, z)
end

local _IsPassableAtPoint = Map.IsPassableAtPoint
function Map:IsPassableAtPoint(x, y, z, allow_water, exclude_boats)
    if TheWorld:HasTag("porkland") then
        return _IsPassableAtPoint(self, x, y, z, allow_water, exclude_boats)
    end
    return self:IsVisualInteriorAtPoint(x, y, z) or self:IsPassableAtPointWithPlatformRadiusBias(x, y, z, allow_water, exclude_boats, 0)
end

-- local _IsImpassableAtPoint = Map.IsImpassableAtPoint
-- function Map:IsImpassableAtPoint(x, y, z, ...)
--     if TheWorld.components.interiorspawner and TheWorld.components.interiorspawner:IsInInteriorRegion(x, z) then
--         return not TheWorld.components.interiorspawner:IsInInteriorRoom(x, z)
--     end
--     return not self:_IsVisualGroundAtPoint(x, y, z, ...) and not self:ReverseIsVisualWaterAtPoint(x, y, z)
-- end

local _IsSurroundedByWater = Map.IsSurroundedByWater
function Map:IsSurroundedByWater(x, y, z, radius)
    if TheWorld:HasTag("porkland") then
        return _IsSurroundedByWater(self, x, y, z, radius)
    end
    radius = radius + 1 --add 1 to radius for map overhang, way cheaper than doing an IsVisualGround test
    local num_edge_points = math.ceil((radius*2) / 4) - 1

    --test the corners first
    if not self:IsOceanTileAtPoint(x + radius, y, z + radius) then return false end
    if not self:IsOceanTileAtPoint(x - radius, y, z + radius) then return false end
    if not self:IsOceanTileAtPoint(x + radius, y, z - radius) then return false end
    if not self:IsOceanTileAtPoint(x - radius, y, z - radius) then return false end

    --if the radius is less than 1(2 after the +1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return true end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if not self:IsOceanTileAtPoint(x - radius + idist, y, z + radius) then return false end
        if not self:IsOceanTileAtPoint(x - radius + idist, y, z - radius) then return false end
        if not self:IsOceanTileAtPoint(x - radius, y, z - radius + idist) then return false end
        if not self:IsOceanTileAtPoint(x + radius, y, z - radius + idist) then return false end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if not self:IsOceanTileAtPoint(x - radius + idist, y, z - radius + jdist) then return false end
        end
    end
    return true
end

local _IsSurroundedByLand = Map.IsSurroundedByLand
function Map:IsSurroundedByLand(x, y, z, radius) -- 还没增加室内的范围
    if TheWorld:HasTag("porkland") then
        return _IsSurroundedByLand(self, x, y, z, radius)
    end
    radius = radius + 1 --add 1 to radius for map overhang, way cheaper than doing an IsVisualGround test
    local num_edge_points = math.ceil((radius*2) / 4) - 1

    --test the corners first
    if not self:IsLandTileAtPoint(x + radius, y, z + radius) then return false end
    if not self:IsLandTileAtPoint(x - radius, y, z + radius) then return false end
    if not self:IsLandTileAtPoint(x + radius, y, z - radius) then return false end
    if not self:IsLandTileAtPoint(x - radius, y, z - radius) then return false end

    --if the radius is less than 1(2 after the +1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return true end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if not self:IsLandTileAtPoint(x - radius + idist, y, z + radius) then return false end
        if not self:IsLandTileAtPoint(x - radius + idist, y, z - radius) then return false end
        if not self:IsLandTileAtPoint(x - radius, y, z - radius + idist) then return false end
        if not self:IsLandTileAtPoint(x + radius, y, z - radius + idist) then return false end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if not self:IsLandTileAtPoint(x - radius + idist, y, z - radius + jdist) then return false end
        end
    end
    return true
end

local _IsAboveGroundAtPoint = Map.IsAboveGroundAtPoint
function Map:IsAboveGroundAtPoint(x, y, z, allow_water)
    if TheWorld:HasTag("porkland") then
        return _IsAboveGroundAtPoint(self, x, y, z, allow_water)
    end
    local tile = self:GetTileAtPoint(x, y, z)
    local valid_water_tile = (allow_water == true) and TileGroupManager:IsOceanTile(tile)
    return valid_water_tile or TileGroupManager:IsLandTile(tile) or self:IsVisualInteriorAtPoint(x, y, z)
end

local _CanDeployRecipeAtPoint = Map.CanDeployRecipeAtPoint
function Map:CanDeployRecipeAtPoint(pt, recipe, rot)
    if TheWorld:HasTag("porkland") then return _CanDeployRecipeAtPoint(self, pt, recipe, rot) end
    --室内的方案：家具可以部署，非房间区域不能部署，非陆地区域不能部署，然后进行原版判断
    if recipe and pt and TheWorld.components.interiorspawner:IsInInteriorRegion(pt.x, pt.z) then
        if recipe.build_mode == BUILDMODE.HOME_DECOR then
            return true
        elseif not TheWorld.components.interiorspawner:IsInInteriorRoom(pt.x, pt.z, -1) then
            return false
        end
        local x, y, z = pt:Get()
        if not self:ReverseIsVisualGroundAtPoint(x, y, z) then
            return false
        end
    end

    -- 以下是原版内容
    local is_valid_ground = false;
    if BUILDMODE.WATER == recipe.build_mode then
        local pt_x, pt_y, pt_z = pt:Get()
        is_valid_ground = not self:IsPassableAtPoint(pt_x, pt_y, pt_z)
        if is_valid_ground then
            is_valid_ground = self:IsSurroundedByWater(pt_x, pt_y, pt_z, 5)
        end
    else
        local pt_x, pt_y, pt_z = pt:Get()
        is_valid_ground = self:IsPassableAtPointWithPlatformRadiusBias(pt_x, pt_y, pt_z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
    end

    return is_valid_ground
        and (recipe.testfn == nil or recipe.testfn(pt, rot))
        and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
end

local _CanPlantAtPoint = Map.CanPlantAtPoint
function Map:CanPlantAtPoint(x, y, z) -- 关注一下室内的植物种植功能
    if TheWorld:HasTag("porkland") then return _CanPlantAtPoint(self, x, y, z) end
    local tile = self:GetTileAtPoint(x, y, z)

    if not TileGroupManager:IsLandTile(tile) then
        return false
    end

    return not GROUND_HARD[tile]
end

local _CanDeployWallAtPoint = Map.CanDeployWallAtPoint
function Map:CanDeployWallAtPoint(pt, inst)
    if TheWorld:HasTag("porkland") then return _CanDeployWallAtPoint(self, pt, inst) end
    -- We assume that walls use placer.snap_to_meters, so let's emulate the snap here.
    pt = Vector3(math.floor(pt.x) + 0.5, pt.y, math.floor(pt.z) + 0.5)

    local x,y,z = pt:Get()
    local ispassable, is_overhang = self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, false)
    return ispassable and self:IsDeployPointClear(pt, inst, 1, nil, IsNearOtherWallOrPlayer, is_overhang)
end

local _CanDeployAtPoint = Map.CanDeployAtPoint
function Map:CanDeployAtPoint(pt, inst, mouseover)
    if TheWorld:HasTag("porkland") then return _CanDeployAtPoint(self, pt, inst, mouseover) end
    local x,y,z = pt:Get()
    return (mouseover == nil or mouseover:HasTag("player") or mouseover:HasTag("walkableplatform") or mouseover:HasTag("walkableperipheral"))
        and self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, false, false, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, true)
        and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
end