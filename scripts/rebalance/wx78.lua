local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
local AddPrototyperDef = AddPrototyperDef
local AddRecipePostInit = AddRecipePostInit

local AddPrefabPostInit = AddPrefabPostInit
local AddPlayerPostInit = AddPlayerPostInit
local AddClassPostConstruct = AddClassPostConstruct

GLOBAL.setfenv(1, GLOBAL)

--WX
local FogOver = require("widgets/fogover")

local _UpdateAlpha = FogOver.UpdateAlpha

function FogOver:UpdateAlpha(dt, ...)
    _UpdateAlpha(self, dt, ...)

    if self._wx_fog_modifier == nil then
        self._wx_fog_modifier = 1
    end

	local fogover_alpha = self.owner.fogover_alpha and math.floor(self.owner.fogover_alpha:value() * 10 + 0.5) / 10 or 1
    local target_modifier = math.min(self.alphagoal, fogover_alpha)

    local speed = self.alphagoal == 0 and 0.5 or 0.2
    if self._wx_fog_modifier < target_modifier then
        self._wx_fog_modifier = math.min(self._wx_fog_modifier + speed * dt, target_modifier)
    elseif self._wx_fog_modifier > target_modifier then
        self._wx_fog_modifier = math.max(self._wx_fog_modifier - speed * dt, target_modifier)
    end

    self.alpha = self._wx_fog_modifier
	-- print("FogOver UpdateAlpha: alpha="..tostring(self.alpha)..", target_modifier="..tostring(target_modifier)..", current_modifier="..tostring(self._wx_fog_modifier))
end
