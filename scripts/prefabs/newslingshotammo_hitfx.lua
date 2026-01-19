
local fx = require('fx') 

local SHOT_TYPES =
{
    "infused",
    "alloy",
}

local SPECIFIC_HITFX_ANIM =
{
    stinger = "used_stinger",
    moonglass = "used_moonglass",
    gunpowder = "used_gunpowder",
}

for _, shot_type in ipairs(SHOT_TYPES) do
    table.insert(fx, {
        name = "slingshotammo_hitfx_"..shot_type,
        bank = "newslingshotammo",
        build = "newslingshotammo",
        anim = SPECIFIC_HITFX_ANIM[shot_type] or "used",
        sound = shot_type == "alloy" and "dontstarve/characters/walter/slingshot/dreadstone" or "dontstarve/characters/walter/slingshot/rock",
        --sound = "dontstarve/characters/walter/slingshot/"..shot_type,
        fn = function(inst)
			if shot_type ~= "rock" then
		        inst.AnimState:OverrideSymbol("rock", "newslingshotammo", shot_type)

				if shot_type == "horrorfuel" then
					inst.AnimState:SetLightOverride(1)
                elseif shot_type == "purebrilliance" then
                    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
                    inst.AnimState:SetLightOverride(.1)
                elseif shot_type == "gunpowder" then
                    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
                    inst.AnimState:SetLightOverride(.1)
				end
			end
		    inst.AnimState:SetFinalOffset(3)
		end,
    })
end


