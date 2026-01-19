local AddPrefabPostInit = AddPrefabPostInit
local AddComponentPostInit = AddComponentPostInit

GLOBAL.setfenv(1, GLOBAL)

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function ontradefn(inst, item, giver)
    local x, y, z = inst.Transform:GetWorldPosition()
    y = 4.5

    local angle
    if giver ~= nil and giver:IsValid() then
        angle = 180 - giver:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) / DEGREES
        giver = nil
    end

    local loots = TheWorld.components.skyworthymanager:GetLootFromPigking()
    for k = 1, #loots do
        local loot = SpawnPrefab(loots[k])
        loot.Transform:SetPosition(x, y, z)
        launchitem(loot, angle)
    end
end

local postinit_fn = function(inst)
    if not TheWorld.ismastersim then
        return
    end
    local _test = inst.components.trader.test
    local _onaccept = inst.components.trader.onaccept

    local skyworthymanager = TheWorld.components.skyworthymanager

    inst.components.trader.test = function(inst, item, giver)
        if item.prefab == skyworthymanager.trinket_pigking then
            return true
        end
        if item:HasTag("irreplaceable") then
            return false
        end
        if _test then
            return _test(inst, item, giver)
        end
    end

    inst.components.trader.onaccept = function(inst, giver, item)
        if item.prefab == skyworthymanager.trinket_pigking then
            inst.sg:GoToState("cointoss")
            inst:DoTaskInTime(2 / 3, ontradefn, item, giver)
            if giver.prefab == "wurt" then return end
        end
        if _onaccept then
            return _onaccept(inst, giver, item)
        end
    end
end

AddPrefabPostInit("pigking", postinit_fn)