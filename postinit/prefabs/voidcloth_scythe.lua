local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
    if not TheWorld.ismastersim then
        return inst
    end
        
    local _DoScythe = inst.DoScythe

    inst.DoScythe = function(inst, target, doer)
        _DoScythe(inst, target, doer)

        local doer_pos = doer:GetPosition()
        local x, y, z = doer_pos:Get()
        local doer_rotation = doer.Transform:GetRotation()

        local ents = TheSim:FindEntities(x, y, z, TUNING.VOIDCLOTH_SCYTHE_HARVEST_RADIUS, {"SHEAR_workable"}, {"INLIMBO", "FX"})
        for _, ent in ipairs(ents) do
            if ent:IsValid() and ent.components.shearable ~= nil then
                if inst:IsEntityInFront(ent, doer_rotation, doer_pos) then
                    if ent.components.shearable:CanShear() then
                        ent.components.shearable:Shear(inst, 1) -- 用镰刀作为动作执行者，使得物资掉在地上而不是直接转移到玩家身上
                    end
                end
            end
        end
    end
end

AddPrefabPostInit("voidcloth_scythe", postinit_fn)