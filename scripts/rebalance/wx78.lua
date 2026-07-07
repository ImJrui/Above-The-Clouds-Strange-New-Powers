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

    if self._alpha == nil then
        self._alpha = 1
    end

	local _fogoveralpha = self.owner._fogoveralpha and math.floor(self.owner._fogoveralpha:value() * 10 + 0.5) / 10 or 1
    local _alphagoal = math.min(self.alphagoal, _fogoveralpha)

    local speed = 0.5
    if self._alpha < _alphagoal then
        self._alpha = math.min(self._alpha + speed * dt, _alphagoal)
    elseif self._alpha > _alphagoal then
        self._alpha = math.max(self._alpha - speed * dt, _alphagoal)
    end

    self.alpha = self._alpha
	-- print("FogOver UpdateAlpha: alpha="..tostring(self.alpha)..", _alphagoal="..tostring(_alphagoal)..", current="..tostring(self._alpha))
end
