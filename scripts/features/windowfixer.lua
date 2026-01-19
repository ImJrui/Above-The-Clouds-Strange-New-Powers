local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local DecoCreator = require("prefabs/deco_util")

local function on_window_built(inst)
    if DecoCreator:IsBuiltOnBackWall(inst) then
		if inst.bank:sub(-5) ~= "_side" then return end --if it is fixed already
        local bank = inst.bank:sub(1, -6) -- Remove _side
        inst.AnimState:SetBank(bank)
        if inst.children_to_spawn then
            for i, children in ipairs(inst.children_to_spawn) do
                if children:sub(-8) ~= "backwall" then
                    inst.children_to_spawn[i] = children .. "_backwall"
                end
            end
        end
    end

    if inst.components.rotatingbillboard then
        local position = inst:GetPosition()
        local current_interior = TheWorld.components.interiorspawner:GetInteriorCenter(position)
        if current_interior then
            local originpt = current_interior:GetPosition()
            if position.z >= originpt.z then
                inst.Transform:SetScale(-1,1,1)
            end

            local animdata = shallowcopy(inst.components.rotatingbillboard.animdata)
            animdata.bank = inst.bank
            if DecoCreator:IsBuiltOnBackWall(inst) then
                animdata.bank = inst.bank:sub(1, -6) -- Remove _side
            end

            inst.animdata = animdata
            inst.components.rotatingbillboard:SetAnimation_Server(animdata)
        end
    end
end

local function OnLoad(inst, data)
	inst.OnLoad_plrebalanceold(inst, data)
	
	inst:DoTaskInTime(0, on_window_built, inst)
end

local function postinitfn(inst)
	
	inst.OnLoad_plrebalanceold = inst.OnLoad
	inst.OnLoad = OnLoad
end

AddPrefabPostInit("window_round", postinitfn)
AddPrefabPostInit("window_round_curtains_nails", postinitfn)
AddPrefabPostInit("window_round_burlap", postinitfn)
AddPrefabPostInit("window_small_peaked", postinitfn)
AddPrefabPostInit("window_large_square", postinitfn)
AddPrefabPostInit("window_tall", postinitfn)
AddPrefabPostInit("window_round_arcane", postinitfn)
AddPrefabPostInit("window_small_peaked_curtain", postinitfn)
AddPrefabPostInit("window_large_square_curtain", postinitfn)
AddPrefabPostInit("window_tall_curtain", postinitfn)
AddPrefabPostInit("window_square_weapons", postinitfn)
--AddPrefabPostInit("window_greenhouse", postinitfn)