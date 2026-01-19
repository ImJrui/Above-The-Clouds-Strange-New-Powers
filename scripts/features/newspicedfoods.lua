require("tuning")

local spicedfoods = {}

local function oneaten_garlic(inst, eater)
    eater:AddDebuff("buff_playerabsorption", "buff_playerabsorption")
end

local function oneaten_sugar(inst, eater)
    eater:AddDebuff("buff_workeffectiveness", "buff_workeffectiveness")
end

local function oneaten_chili(inst, eater)
    eater:AddDebuff("buff_attack", "buff_attack")
end

local function oneaten_bitter(inst, eater)
    eater:AddDebuff("buff_antivenom", "buff_antivenom")
end


local SPICES = {}

local function shallowcopy(orig, dest)
    local copy
    if type(orig) == 'table' then
        copy = dest or {}
        for k, v in pairs(orig) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function ArrayUnion(...)
	local ret = {}
	for i,array in ipairs({...}) do
		for j,val in ipairs(array) do
			if not table.contains(ret, val) then
				table.insert(ret, val)
			end
		end
	end
	return ret
end

function GenerateSpicedFoods(foods,foodstype)
    --如果是Hamlet的食物，则与所有的调味料生成新的调味食物
    if foodstype == "hamletfoods" then
        SPICES =
        {
            SPICE_GARLIC = { oneatenfn = oneaten_garlic, prefabs = { "buff_playerabsorption" } },
            SPICE_SUGAR  = { oneatenfn = oneaten_sugar, prefabs = { "buff_workeffectiveness" } },
            SPICE_CHILI  = { oneatenfn = oneaten_chili, prefabs = { "buff_attack" } },
            SPICE_SALT   = {},
            SPICE_LOTUS   = { oneatenfn = oneaten_bitter, prefabs = { "buff_antivenom" } },
        }
    --如果是原版的食物，则只与新的调味料生成调味食物   
    elseif foodstype == "originalfoods" then
        SPICES =
        {
            SPICE_LOTUS   = { oneatenfn = oneaten_bitter, prefabs = { "buff_antivenom" } },
        }
    end
   
    for foodname, fooddata in pairs(foods) do
        for spicenameupper, spicedata in pairs(SPICES) do
            local newdata = shallowcopy(fooddata)
            local spicename = string.lower(spicenameupper)
            if foodname == "wetgoop" then
                newdata.test = function(cooker, names, tags) return names[spicename] end
                newdata.priority = -10
            else
                newdata.test = function(cooker, names, tags) return names[foodname] and names[spicename] end
                newdata.priority = 100
            end
            newdata.cooktime = .12
            newdata.stacksize = nil
            newdata.spice = spicenameupper
            newdata.basename = foodname
            newdata.name = foodname.."_"..spicename
            newdata.floater = {"med", nil, {0.85, 0.7, 0.85}}
			newdata.official = true
			newdata.cookbook_category = fooddata.cookbook_category ~= nil and ("spiced_"..fooddata.cookbook_category) or nil
            spicedfoods[newdata.name] = newdata

            if spicename == "spice_chili" then
                if newdata.temperature == nil then
                    --Add permanent "heat" to regular food
                    newdata.temperature = TUNING.HOT_FOOD_BONUS_TEMP
                    newdata.temperatureduration = TUNING.FOOD_TEMP_LONG
                    newdata.nochill = true
                elseif newdata.temperature > 0 then
                    --Upgarde "hot" food to permanent heat
                    newdata.temperatureduration = math.max(newdata.temperatureduration, TUNING.FOOD_TEMP_LONG)
                    newdata.nochill = true
                end
            end

            if spicename == "spice_lotus" then
                if newdata.antihistamine == nil then
                    newdata.antihistamine = 720
                    newdata.oneat_desc = "Clear the airway"
                elseif newdata.antihistamine > 0 then
                    newdata.antihistamine = math.max(newdata.antihistamine, 720)
                    newdata.oneat_desc = "Clear the airway"
                end
            end

            if spicedata.prefabs ~= nil then
                --make a copy (via ArrayUnion) if there are dependencies from the original food
                newdata.prefabs = newdata.prefabs ~= nil and ArrayUnion(newdata.prefabs, spicedata.prefabs) or spicedata.prefabs
            end

            if spicedata.oneatenfn ~= nil then
                if newdata.oneatenfn ~= nil then
                    local oneatenfn_old = newdata.oneatenfn
                    newdata.oneatenfn = function(inst, eater)
                        spicedata.oneatenfn(inst, eater)
                        oneatenfn_old(inst, eater)
                    end
                else
                    newdata.oneatenfn = spicedata.oneatenfn
                end
            end
        end
    end
end

GenerateSpicedFoods(require("main/preparedfoods"),"hamletfoods")
GenerateSpicedFoods(require("features/newpreparedfoods_warly"),"hamletfoods")
GenerateSpicedFoods(require("preparedfoods"),"originalfoods")
GenerateSpicedFoods(require("preparedfoods_warly"),"originalfoods")

return spicedfoods
