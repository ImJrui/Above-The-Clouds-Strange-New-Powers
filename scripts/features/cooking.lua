local AddCookerRecipe = AddCookerRecipe
local AddIngredientValues = AddIngredientValues
GLOBAL.setfenv(1, GLOBAL)

local newfoods_warly = require("features/newpreparedfoods_warly")
for _, recipe in pairs(newfoods_warly) do
    AddCookerRecipe("portablecookpot", recipe)
end

local newspicedfoods = require("features/newspicedfoods")
for k, recipe in pairs(newspicedfoods) do
    AddCookerRecipe("portablespicer", recipe)
end

--[[
local cooking = require("cooking")

if cooking.recipes and cooking.recipes.frogfishbowl then
    local _test = cooking.recipes.frogfishbowl.test

    cooking.recipes.frogfishbowl.test = function(cooker, names, tags)
        if ((names.drumstick and names.drumstick >= 2)
            or (names.drumstick_cooked and names.drumstick_cooked >= 2 )
            or (names.drumstick and names.drumstick_cooked))
            and tags.fish and tags.fish >= 1 and not tags.inedible
        then
            return true
        end

        return _test(cooker, names, tags)
    end
end
]]