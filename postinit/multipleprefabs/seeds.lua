local AddPrefabPostInit = AddPrefabPostInit
local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS

--The seeds back to DST farm type
local function OnDeploy(inst, pt, deployer) --, rot)
    local plant = SpawnPrefab(inst.components.farmplantable.plant)
    plant.Transform:SetPosition(pt.x, 0, pt.z)
    plant:PushEvent("on_planted", {in_soil = false, doer = deployer, seed = inst})
    TheWorld.Map:CollapseSoilAtPoint(pt.x, 0, pt.z)
    --plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds")
    inst:Remove()
end

local function Seed_GetDisplayName(inst)
    local registry_key = inst.plant_def.product

    local plantregistryinfo = inst.plant_def.plantregistryinfo
    return (ThePlantRegistry:KnowsSeed(registry_key, plantregistryinfo) and ThePlantRegistry:KnowsPlantName(registry_key, plantregistryinfo)) and STRINGS.NAMES["KNOWN_"..string.upper(inst.prefab)]
            or nil
end

local function seeds_postinit(veggie)
    local function veggie_seeds_postinit(inst)
        if not inst.plant_def then
            inst.plant_def = PLANT_DEFS[veggie]
        end
        inst.displaynamefn = Seed_GetDisplayName
    
        if not TheWorld.ismastersim then
            return
        end
    
        if not inst.components.farmplantable then
            inst:AddComponent("farmplantable")
        end
        inst.components.farmplantable.plant = "farm_plant_"..veggie

        if not inst.components.deployable then
            inst:AddComponent("deployable")
        end
        inst.components.deployable.ondeploy = OnDeploy
    end

    AddPrefabPostInit(veggie .. "_seeds", veggie_seeds_postinit)
end

local all_veggies = {
    "radish",
    "aloe",
    "tomato",
    "potato",
    "onion",
    "garlic",
    "pepper",
    "asparagus",
    "carrot",
    "corn",
    "dragonfruit",
    "durian",
    "eggplant",
    "pomegranate",
    "pumpkin",
    "watermelon",
}

for _, veggie in pairs(all_veggies) do
    seeds_postinit(veggie)
end

----------------------------------------------------------------------
--Allow random seeds to grow all types of plants
local function pickproduct()
    local total_w = 0
    for k,v in pairs(VEGGIES) do
        total_w = total_w + (v.seed_weight or 1)
    end

    local rnd = math.random()*total_w
    for k,v in pairs(VEGGIES) do
        rnd = rnd - (v.seed_weight or 1)
        if rnd <= 0 then
            return k
        end
    end

    return "carrot"
end

local function random_seeds_postinit(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.farmplantable then
        inst:AddComponent("farmplantable")
    end
    inst.components.farmplantable.plant = "farm_plant_randomseed"

    if not inst.components.deployable then
        inst:AddComponent("deployable")
    end
    inst.components.deployable.ondeploy = OnDeploy

    if not inst.components.plantable then
        inst:AddComponent("plantable")
    end
    inst.components.plantable.product = pickproduct
end

AddPrefabPostInit("seeds", random_seeds_postinit)

