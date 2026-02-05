local AddCookerRecipe = AddCookerRecipe
local AddIngredientValues = AddIngredientValues
local AddSimPostInit= AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)

local newfoods_warly = require("features/newpreparedfoods_warly")
for _, recipe in pairs(newfoods_warly) do
    AddCookerRecipe("portablecookpot", recipe)
end

local newspicedfoods = require("features/newspicedfoods")
for k, recipe in pairs(newspicedfoods) do
    AddCookerRecipe("portablespicer", recipe)
end

local smelter_recipes =
{
    messagebottleempty =
    {
        name = "messagebottleempty",
        weight = 1,
        priority = 10,
        cooktime = 0.3,
        test = function(cooker, names, tags)
            return cooker == "smelter" and names.moonglass and names.moonglass == 4
        end,
        no_cookbook = true
    },

    ash =
    {
        name = "ash",
        weight = 10,
        priority = 10,
        cooktime = 0.1,
        test = function(cooker, names, tags)
            local moonglass = names.moonglass or 0
            local iron = names.iron or 0
            return cooker == "smelter" and moonglass > 0 and moonglass < 4 -- 包含但不全是玻璃
        end,
        no_cookbook = true
    },
}


for _, recipe in pairs(smelter_recipes) do
    AddCookerRecipe("smelter", recipe)

    AddCookerRecipe("cookpot", recipe) -- 与初版智能锅mod SmartCrockpot进行兼容(workshop-365119238)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
end
