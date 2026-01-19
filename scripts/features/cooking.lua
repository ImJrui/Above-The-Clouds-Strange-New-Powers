local AddCookerRecipe = AddCookerRecipe
local AddIngredientValues = AddIngredientValues
GLOBAL.setfenv(1, GLOBAL)



local newfoods_warly = require("features/newpreparedfoods_warly")
for _, recipe in pairs(newfoods_warly) do
    AddCookerRecipe("portablecookpot", recipe)
end
--[[
AddIngredientValues({"froglegs_poison"}, {})
AddIngredientValues({"froglegs_poison_cooked"}, {})
]]

local newspicedfoods = require("features/newspicedfoods")
for k, recipe in pairs(newspicedfoods) do
    AddCookerRecipe("portablespicer", recipe)
end
