local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("multiplayer_portal", function(inst)
    if not TheWorld:HasTag("porkland") then
        inst.AnimState:SetBank("portal_dst")
        inst.AnimState:SetBuild("portal_stone")
        inst.sounds = {
            idle_loop = nil,
            idle = "dontstarve/common/together/spawn_vines/spawnportal_idle",
            scratch = nil,
            jacob = "dontstarve/common/together/spawn_vines/spawnportal_jacob",
            blink = nil,
            vines = "dontstarve/common/together/spawn_vines/vines",
            spawning_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
            armswing = nil,
            shake = "dontstarve/common/together/spawn_vines/spawnportal_shake",
            open = "dontstarve/common/together/spawn_vines/spawnportal_open",
            glow_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
            shatter = "dontstarve/common/together/spawn_vines/spawnportal_open",
            place = "dontstarve/common/together/spawn_portal_celestial/reveal",
            transmute_pre = "dontstarve/common/together/spawn_portal_celestial/cracking",
            transmute = "dontstarve/common/together/spawn_portal_celestial/shatter",
        }
    end

    if not TheWorld.ismastersim then
        return
    end
    if not TheWorld:HasTag("porkland") then
        inst:AddComponent("named")
        inst.components.named:SetName(STRINGS.NAMES.PORTAL)
    end
end)

AddPrefabPostInit("multiplayer_portal_moonrock", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if not inst.components.moontrader then
        inst:AddComponent("moontrader")
    end
    local _canaccept = inst.components.moontrader.canaccept
    inst.components.moontrader.canaccept = function(inst, item, giver)
        if not TheWorld.ismastershard then
            return false
        end
        if _canaccept then
            return _canaccept(inst, item, giver)
        end
    end

end)