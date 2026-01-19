local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function CanNotDeployInInterior(inst)
    if not TheWorld.ismastersim then
        return
    end

    local interiorspawner = TheWorld.components.interiorspawner

    if inst.components.deployable then
        local _CanDeploy = inst.components.deployable.CanDeploy
        inst.components.deployable.CanDeploy = function(src, pt, mouseover, deployer, rot)
            if interiorspawner and interiorspawner:IsInInteriorRegion(pt.x, pt.z) then
                return false
            end
            if _CanDeploy then
                return _CanDeploy(src, pt, mouseover, deployer, rot)
            end
        end
    end
end

AddPrefabPostInit("spidereggsack", CanNotDeployInInterior)


--墓碑不能被移植到室内
local function postinit_graveurn(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.gravedigger then
        local _onused = inst.components.gravedigger.onused
        inst.components.gravedigger.onused = function(self, user, target)
            if _onused then
                _onused(self, user, target)
            end
            CanNotDeployInInterior(inst)
        end
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(src, data)
        if _OnLoad then
            _OnLoad(src, data)
        end
        if src._grave_record then
            CanNotDeployInInterior(src)
        end
    end
end

AddPrefabPostInit("graveurn", postinit_graveurn)

local function CanNotDeployInWorld(boat, world)
    AddPrefabPostInit(boat, function(inst)
        if not TheWorld.ismastersim then
            return
        end

        if inst.components.deployable then
            local _CanDeploy = inst.components.deployable.CanDeploy
            inst.components.deployable.CanDeploy = function(src, pt, mouseover, deployer, rot)
                if TheWorld:HasTag(world) then
                    return false
                end
                if _CanDeploy then
                    return _CanDeploy(src, pt, mouseover, deployer, rot)
                end
            end
        end
    end)
end

CanNotDeployInWorld("boat_item", "porkland")
CanNotDeployInWorld("boat_ancient_item", "porkland")
CanNotDeployInWorld("boat_grass_item", "porkland")
CanNotDeployInWorld("boat_cork_item", "forest")

local valid_tiles = {
    [WORLD_TILES.PAINTED] = true,
}

local function MustDeployAtTile(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.components.deployable then
        local _CanDeploy = inst.components.deployable.CanDeploy
        inst.components.deployable.CanDeploy = function(src, pt, mouseover, deployer, rot)
            local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
            if not valid_tiles[tile] then
                return false
            end
            if _CanDeploy then
                return _CanDeploy(src, pt, mouseover, deployer, rot)
            end
        end
    end
end

AddPrefabPostInit("tuber_tree_sapling_item", MustDeployAtTile)