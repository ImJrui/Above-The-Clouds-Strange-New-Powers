GLOBAL.setfenv(1, GLOBAL)

-- 用依赖独有方法的来源识别云霄国度这一层，避免误取其他模组的同名 upvalue。
local map_source
if type(Map.GetVisualTileAtPoint) == "function" then
    local GetMaxRenderOrderTile, scope_fn = ToolUtil.GetUpvalue(Map.GetVisualTileAtPoint, "GetMaxRenderOrderTile")
    if type(GetMaxRenderOrderTile) == "function" and type(scope_fn) == "function" then
        map_source = debug.getinfo(scope_fn, "S").source
    end
end

local function FindMapMethod(fn, name, visited, depth)
    if type(fn) ~= "function" or depth == 0 or (visited[fn] or 0) >= depth then
        return
    end
    visited[fn] = depth

    if debug.getinfo(fn, "S").source == map_source then
        local original, scope_fn = ToolUtil.GetUpvalue(fn, "_" .. name)
        if type(original) == "function" and scope_fn == fn then
            return original, fn
        end
    end

    local i = 1
    while true do
        local key, value = debug.getupvalue(fn, i)
        if key == nil then
            return
        end
        local original, current, scope_fn, index = FindMapMethod(value, name, visited, depth - 1)
        if original then
            return original, current, scope_fn or fn, index or i
        end
        i = i + 1
    end
end

-- 非猪镇复用云霄国度保存的原方法，猪镇仍走完整逻辑；已有的外层 hook 保持调用。
local function HookNonPorklandMethod(name, hook)
    local original, current, scope_fn, index = FindMapMethod(Map[name], name, {}, 3)
    if type(original) ~= "function" then
        print("[Above The Clouds - Strange New Powers] Missing Map." .. name .. " original upvalue; keeping current method.")
        return
    end

    local function wrapped(self, ...)
        if TheWorld:HasTag("porkland") then
            return current(self, ...)
        end
        if hook then
            return hook(original, self, ...)
        end
        return original(self, ...)
    end

    if scope_fn then
        debug.setupvalue(scope_fn, index, wrapped)
    else
        Map[name] = wrapped
    end
end

function Map:IsVisualInteriorAtPoint(x, y, z)
    local interiorspawner = TheWorld.components.interiorspawner
    if interiorspawner and interiorspawner:IsInInteriorRegion(x, z) then
        return interiorspawner:IsInInteriorRoom(x, z)
    end
    return false
end

local _ReverseIsVisualGroundAtPoint = Map.ReverseIsVisualGroundAtPoint
function Map:ReverseIsVisualGroundAtPoint(x, y, z, ...) -- 视觉陆地定义为室内 + 陆地
    if TheWorld:HasTag("porkland") then
        return _ReverseIsVisualGroundAtPoint(self, x, y, z, ...)
    end
    -- 依赖的实现会反查水域；这里必须直接使用原视觉陆地判定，避免与下面的水域 hook 递归。
    return self:IsVisualInteriorAtPoint(x, y, z) or self:_IsVisualGroundAtPoint(x, y, z, ...)
end

local _ReverseIsVisualWaterAtPoint = Map.ReverseIsVisualWaterAtPoint
function Map:ReverseIsVisualWaterAtPoint(x, y, z, ...) -- 非猪镇的水域 = 海洋地皮 - 视觉陆地
    if TheWorld:HasTag("porkland") then
        return _ReverseIsVisualWaterAtPoint(self, x, y, z, ...)
    end
    -- 这两个 Reverse 方法没有保存原函数的 upvalue，非猪镇只适配水陆定义。
    return self:IsOceanTileAtPoint(x, y, z) and not self:ReverseIsVisualGroundAtPoint(x, y, z, ...)
end

HookNonPorklandMethod("IsPassableAtPoint", function(original, self, x, y, z, ...)
    if self:IsVisualInteriorAtPoint(x, y, z) then
        return true
    end
    return original(self, x, y, z, ...)
end)

HookNonPorklandMethod("IsSurroundedByWater")
HookNonPorklandMethod("IsSurroundedByLand")

HookNonPorklandMethod("IsAboveGroundAtPoint", function(original, self, x, y, z, ...)
    if self:IsVisualInteriorAtPoint(x, y, z) then
        return true
    end
    return original(self, x, y, z, ...)
end)

HookNonPorklandMethod("CanDeployRecipeAtPoint", function(original, self, pt, recipe, ...)
    -- 家具沿用室内放置规则，其余配方通过房间边界检查后交回原方法。
    local interiorspawner = TheWorld.components.interiorspawner
    if recipe and pt and interiorspawner and interiorspawner:IsInInteriorRegion(pt.x, pt.z) then
        if recipe.build_mode == BUILDMODE.HOME_DECOR then
            return true
        elseif not interiorspawner:IsInInteriorRoom(pt.x, pt.z, -1) then
            return false
        end
        local x, y, z = pt:Get()
        if not self:ReverseIsVisualGroundAtPoint(x, y, z) then
            return false
        end
    end

    return original(self, pt, recipe, ...)
end)

HookNonPorklandMethod("CanPlantAtPoint")
HookNonPorklandMethod("CanDeployWallAtPoint")
HookNonPorklandMethod("CanDeployAtPoint")

local _CanPointHaveAcidRain = Map.CanPointHaveAcidRain
function Map:CanPointHaveAcidRain(x, y, z, ...)
    if self:IsVisualInteriorAtPoint(x, y, z) then
        return false
    end
    return _CanPointHaveAcidRain(self, x, y, z, ...)
end
