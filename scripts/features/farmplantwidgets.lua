--FarmPlantPage
local Widget = require "widgets/widget"
local PlantPageWidget = require "widgets/redux/plantpagewidget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/redux/templates"
local Image = require "widgets/image"
local Puppet = require "widgets/skinspuppet"

local season_sort_hamlet = {
    temperate = 3,
    humid = 2,
    lush = 1,
}

local season_sort_DST = {
    autumn = 4,
    winter = 3,
    spring = 2,
    summer = 1,
}

local LEARN_PERCENTS = {
    SEASON = 1/4,
    WATER = 2/4,
    NUTRIENTS = 3/4,
    DESCRIPTION = 4/4,
}

local DIGIT_COLORS =
{
	"_black",
	"_black",
	"_black",
	"_white",
	"_white",
}
local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS

local function GetSkinModeTable(player_prefab, mode)
    for i, skinmode in ipairs(GetSkinModes(player_prefab)) do
        if skinmode.type == mode then
            return skinmode
        end
    end
end

local function MakeDetailsLine(root, x, y, scale, image_override)
	local value_title_line = root:AddChild(Image("images/plantregistry.xml", image_override or "details_line.tex"))
	value_title_line:SetScale(scale, scale)
    value_title_line:SetPosition(x, y)
    return value_title_line
end

local item_icon_remap = {}
item_icon_remap.onion = "quagmire_onion"
item_icon_remap.tomato = "quagmire_tomato"
local item_name_remap = {}

local function MakeItemWidget(root, cursor, x, y, ingredient_size, item_name, name_prefix)
    name_prefix = name_prefix or ""

    local img_name = (item_icon_remap[item_name] or item_name)..".tex"
    local img_atlas = GetInventoryItemAtlas(img_name, true)
    local backing = root:AddChild(Image(img_atlas or "images/plantregistry.xml", img_atlas ~= nil and img_name or "missing.tex"))
    backing:ScaleToSize(ingredient_size, ingredient_size)
    backing:SetPosition(x, y)
    backing:SetHoverText(STRINGS.NAMES[string.upper(name_prefix..(item_name_remap[item_name] or item_name))] or STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, {offset_y = 80})

    local _OnGainFocus = backing.OnGainFocus
    function backing.OnGainFocus()
        _OnGainFocus(backing)
        cursor:GetParent():RemoveChild(cursor)
        backing:AddChild(cursor)
        cursor:ScaleToSizeIgnoreParent(ingredient_size, ingredient_size)
        cursor:Show()
    end
    local _OnLoseFocus = backing.OnLoseFocus
    function backing.OnLoseFocus()
        _OnLoseFocus(backing)
        if cursor:GetParent() == backing then
            backing:RemoveChild(cursor)
            root:AddChild(cursor)
            cursor:Hide()
        end
    end

    return backing
end

local FarmPlantPage = require("widgets/redux/farmplantpage")

local _FarmPlantPage = function(self, plantspage, data)
    PlantPageWidget._ctor(self, "FarmPlantPage", plantspage, data)

    self.known_percent = ThePlantRegistry:GetPlantPercent(data.plant, data.info)

    local name_font_size = 24
    local unknown_font_size = 16
    local title_font_size = 16

    local ingredient_size = 48

    local plant_name_str = ThePlantRegistry:KnowsPlantName(self.data.plant, self.data.info) and
        STRINGS.NAMES[string.upper(self.data.plant_def.prefab)] or
        STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT

    self.cursor = self.root:AddChild(Image("images/plantregistry.xml", "cursor.tex"))
    self.cursor:SetClickable(false)
    self.cursor:Hide()

    self.plant_name = self.root:AddChild(Text(HEADERFONT, name_font_size, plant_name_str, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.plant_name:SetPosition(0, 275 - 15 - 17.5)
    self.plant_name:SetHAlign(ANCHOR_MIDDLE)

    if plant_name_str == STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT then
        self.plant_name:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    else
        self.plant_name:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
    end

    local line_width = 170
    local line_gap = 10
    local large_line_width = line_width * 2 + line_gap

    local START_X
    if ThePlantRegistry:HasOversizedPicture(data.plant) then
        START_X = -450 + 30 + (line_width / 2)
    else
        START_X = 0 - (line_width + line_gap)
    end

    local x_start = START_X + ((line_width + line_gap) / 2)
    local y_start = -20

    local knows_seed = ThePlantRegistry:KnowsSeed(self.data.plant, self.data.info)
    local knows_plant = ThePlantRegistry:KnowsPlantName(self.data.plant, self.data.info)

    --seed--
    local seed_y = y_start - title_font_size/2 - 3
    self.seed = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.SEED, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.seed:SetPosition(x_start, y_start)
    self.seed:SetHAlign(ANCHOR_MIDDLE)
    if not knows_seed then
        self.seed:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end

    self.seed_line = MakeDetailsLine(self.root, x_start, seed_y, 0.5)
    seed_y = seed_y - 2 - ingredient_size / 2

    local seed_name = knows_seed and self.data.plant_def.seed or ""
    local seed_name_prefix = knows_plant and "known_" or ""
    self.seed_icon = MakeItemWidget(self.root, self.cursor, x_start, seed_y, ingredient_size, seed_name, seed_name_prefix)
    --seed--

    x_start = x_start + line_width + line_gap

    --product--
    local product_y = y_start - title_font_size/2 - 3
    self.product = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.PRODUCT, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.product:SetPosition(x_start, y_start)
    self.product:SetHAlign(ANCHOR_MIDDLE)
    if not knows_plant then
        self.product:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end

    self.product_line = MakeDetailsLine(self.root, x_start, product_y, 0.5)
    product_y = product_y - 2 - ingredient_size / 2

    local product_name = knows_plant and self.data.plant_def.product or ""
    self.product_icon = MakeItemWidget(self.root, self.cursor, x_start, product_y, ingredient_size, product_name)
    --product--

    x_start = START_X
    y_start = y_start - 75

    --seasons--
    local season_y = y_start - title_font_size/2 - 3
    local season_size = 32
    local season_gap = 6

    self.seasons = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.SEASONS, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.seasons:SetPosition(x_start, y_start)
    self.seasons:SetHAlign(ANCHOR_MIDDLE)
    self.seasons_line = MakeDetailsLine(self.root, x_start, season_y, 0.5)

    if self.known_percent >= LEARN_PERCENTS.SEASON then
        --display season icons.
        self.season_icons = {}
        local season_sort = TheWorld:HasTag("porkland") and season_sort_hamlet or season_sort_DST

        for season in pairs(self.data.plant_def.good_seasons) do
            if season_sort[season] then
                local season_icon = self.root:AddChild(Image("images/hud/plrebalance_inventoryimages.xml", "season_"..season..".tex"))
                --local season_icon = self.root:AddChild(Image("images/plantregistry.xml", "season_summer.tex"))
                season_icon:ScaleToSize(season_size, season_size)
                season_icon.season = season
                season_icon:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(season)], {offset_y = 56})
                local _OnGainFocus = season_icon.OnGainFocus
                function season_icon.OnGainFocus()
                    _OnGainFocus(season_icon)
                    self.cursor:GetParent():RemoveChild(self.cursor)
                    season_icon:AddChild(self.cursor)
                    self.cursor:ScaleToSizeIgnoreParent(season_size, season_size)
                    self.cursor:Show()
                end
                local _OnLoseFocus = season_icon.OnLoseFocus
                function season_icon.OnLoseFocus()
                    _OnLoseFocus(season_icon)
                    if self.cursor:GetParent() == season_icon then
                        season_icon:RemoveChild(self.cursor)
                        self.root:AddChild(self.cursor)
                        self.cursor:Hide()
                    end
                end
                table.insert(self.season_icons, season_icon)
            end
        end

        local season_count = #self.season_icons
        local season_x = x_start - ((season_count * season_size) + ((season_count - 1) * season_gap)) / 2
        season_y = season_y - season_size / 2 - season_gap

        table.sort(self.season_icons, function(a, b)
            return season_sort[a.season] > season_sort [b.season]
        end)

        for i, season_icon in ipairs(self.season_icons) do
            season_x = season_x + season_size / 2
            season_icon:SetPosition(season_x, season_y)
            season_x = season_x + season_size / 2 + season_gap
        end
    else
        season_y = season_y - 10 - unknown_font_size / 2
        self.unknown_seasons_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_seasons_text:SetPosition(x_start, season_y)
        self.unknown_seasons_text:SetHAlign(ANCHOR_MIDDLE)
        self.seasons:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --seasons--

    x_start = x_start + line_width + line_gap

    --water--
    local water_y = y_start - title_font_size/2 - 3
    local water_size = 32
    local water_gap = 6

    self.water = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.WATER, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.water:SetPosition(x_start, y_start)
    self.water:SetHAlign(ANCHOR_MIDDLE)
    self.water_line = MakeDetailsLine(self.root, x_start, water_y, 0.5)
    --display water consumption

    if self.known_percent >= LEARN_PERCENTS.WATER then
        local water_icon_count =
        {
            [TUNING.FARM_PLANT_DRINK_LOW] = 1,
            [TUNING.FARM_PLANT_DRINK_MED] = 2,
            [TUNING.FARM_PLANT_DRINK_HIGH] = 3,
        }

        self.water_icons = {}
        for i = 1, water_icon_count[self.data.plant_def.moisture.drink_rate] do
            local water_icon = self.root:AddChild(Image("images/plantregistry.xml", "water.tex"))
            water_icon:ScaleToSize(water_size, water_size)
            table.insert(self.water_icons, water_icon)
        end

        local water_count = #self.water_icons
        local water_x = x_start - ((water_count * water_size) + ((water_count - 1) * water_gap)) / 2
        water_y = water_y - water_size / 2 - water_gap

        for i, season_icon in ipairs(self.water_icons) do
            water_x = water_x + water_size / 2
            season_icon:SetPosition(water_x, water_y)
            water_x = water_x + water_size / 2 + water_gap
        end
    else
        water_y = water_y - 10 - unknown_font_size / 2
        self.unknown_water_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_water_text:SetPosition(x_start, water_y)
        self.unknown_water_text:SetHAlign(ANCHOR_MIDDLE)
        self.water:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --water--

    x_start = x_start + line_width + line_gap

    --nutrients--
    local nutrients_y = y_start - title_font_size/2 - 3
    local nutrients_size = 24
    local nutrients_gap = 6

    self.nutrients = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.NUTRIENTS, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.nutrients:SetPosition(x_start, y_start)
    self.nutrients:SetHAlign(ANCHOR_MIDDLE)
    self.nutrients_line = MakeDetailsLine(self.root, x_start, nutrients_y, 0.5)
    --display nutrients consumption

    if self.known_percent >= LEARN_PERCENTS.NUTRIENTS then
        --display nutrients icons.
        self.nutrients_icons = {}

        local restore_nutrients = self.data.plant_def.nutrient_restoration ~= nil

        local total_nutrients = 0
        for i, v in ipairs(self.data.plant_def.nutrient_consumption) do
            total_nutrients = total_nutrients + v
        end
        local nutrients_restore = not restore_nutrients and 0 or total_nutrients / GetTableSize(self.data.plant_def.nutrient_restoration)

        local total_width = 0
        for nutrient_type = 1, 3 do
            local consume_count = -self.data.plant_def.nutrient_consumption[nutrient_type]
            if restore_nutrients and self.data.plant_def.nutrient_restoration[nutrient_type] then
                consume_count = consume_count + nutrients_restore
            end
            local nutrients_icon = self.root:AddChild(Image("images/plantregistry.xml", "nutrient_"..nutrient_type..".tex"))
            nutrients_icon:ScaleToSize(nutrients_size,nutrients_size)

            nutrients_icon.nutrient_type = nutrient_type
            local neutral = consume_count == 0
            local positive = consume_count > 0

            local imagename
            local prefix
            if neutral then
                imagename = "nutrient_neutral.tex"
                prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.NEUTRAL
            else
                local abs_consume_count = math.abs(consume_count)
                local nutrients_modifier_num = (abs_consume_count <= TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW and 1) or (abs_consume_count >= TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH and 4) or 2
                if positive then
                    imagename = "nutrient_up_"..nutrients_modifier_num..".tex"
                    prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.RESTORE
                else
                    imagename = "nutrient_down_"..nutrients_modifier_num..".tex"
                    prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.CONSUME
                end
            end

            nutrients_icon:SetHoverText(prefix..STRINGS.UI.PLANTREGISTRY.NUTRIENTS[string.upper("nutrient_"..nutrient_type)], {offset_y = 48})

            nutrients_icon.modifier = self.root:AddChild(Image("images/plantregistry.xml", imagename))
            nutrients_icon.modifier:ScaleToSize(nutrients_size,nutrients_size)

            local _OnGainFocus = nutrients_icon.OnGainFocus
            function nutrients_icon.OnGainFocus()
                _OnGainFocus(nutrients_icon)
                self.cursor:GetParent():RemoveChild(self.cursor)
                nutrients_icon:AddChild(self.cursor)
                self.cursor:ScaleToSizeIgnoreParent(nutrients_size, nutrients_size)
                self.cursor:Show()
            end
            local _OnLoseFocus = nutrients_icon.OnLoseFocus
            function nutrients_icon.OnLoseFocus()
                _OnLoseFocus(nutrients_icon)
                if self.cursor:GetParent() == nutrients_icon then
                    nutrients_icon:RemoveChild(self.cursor)
                    self.root:AddChild(self.cursor)
                    self.cursor:Hide()
                end
            end

            total_width = total_width + (nutrients_size * 2) + 2

            table.insert(self.nutrients_icons, nutrients_icon)
        end

        local nutrients_count = #self.nutrients_icons
        local nutrients_x = x_start - (total_width + (nutrients_count - 1) * nutrients_gap) / 2
        nutrients_y = nutrients_y - 10 - nutrients_size / 2

        for i, nutrients_icon in ipairs(self.nutrients_icons) do
            nutrients_x = nutrients_x + nutrients_size / 2
            nutrients_icon:SetPosition(nutrients_x, nutrients_y)
            nutrients_x = nutrients_x + nutrients_size + 2
            nutrients_icon.modifier:SetPosition(nutrients_x, nutrients_y)
            nutrients_x = nutrients_x + nutrients_size / 2 + nutrients_gap
        end

    else
        nutrients_y = nutrients_y - 10 - unknown_font_size / 2
        self.unknown_nutrients_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_nutrients_text:SetPosition(x_start, nutrients_y)
        self.unknown_nutrients_text:SetHAlign(ANCHOR_MIDDLE)
        self.nutrients:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --nutrients--

    x_start = START_X
    if self.back_button and ThePlantRegistry:HasOversizedPicture(data.plant) then
        x_start = x_start + (line_width + line_gap) * 1.5
    else
        x_start = x_start + line_width + line_gap
    end
    y_start = y_start - 75

    --description--
    local description_y = y_start - title_font_size/2 - 3

    self.description = self.root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.PLANTREGISTRY.FARMPLANTS.DESCRIPTION, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
    self.description:SetPosition(x_start, y_start)
    self.description:SetHAlign(ANCHOR_MIDDLE)
    self.description_line = MakeDetailsLine(self.root, x_start, description_y, 0.5, "details_line_wide.tex")
    --display description

    if self.known_percent >= LEARN_PERCENTS.DESCRIPTION then
        self.description_text = self.root:AddChild(Text(HEADERFONT, title_font_size, nil, PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN))
        self.description_text:SetMultilineTruncatedString(
            STRINGS.UI.PLANTREGISTRY.DESCRIPTIONS[string.upper(self.data.plant)] or
            STRINGS.UI.PLANTREGISTRY.DESCRIPTIONS.MISSING, 3, large_line_width - 10, nil, nil, true)

        local w, h = self.description_text:GetRegionSize()
        description_y = description_y - 10 - h / 2

        self.description_text:SetPosition(x_start, description_y)
        self.description_text:SetHAlign(ANCHOR_MIDDLE)
    else
        description_y = description_y - 10 - unknown_font_size / 2
        self.unknown_description_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        self.unknown_description_text:SetPosition(x_start, description_y)
        self.unknown_description_text:SetHAlign(ANCHOR_MIDDLE)
        self.description:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
    --description--

    --oversized plant picture--
    local picture = ThePlantRegistry:GetOversizedPictureData(data.plant)
    if picture and table.contains(DST_CHARACTERLIST, picture.player) then
        local anim_scale = 0.30

        local x_pos = 210
        local y_pos = -215

        self.picturebg = self.root:AddChild(Image("images/plantregistry.xml", "oversizedpictureframe.tex"))
        self.picturebg:SetPosition(x_pos + 60, y_pos + 85)

        --scale--
        self.scale = self.root:AddChild(UIAnim())
        self.scale:GetAnimState():SetBuild("trophyscale_oversizedveggies")
        self.scale:GetAnimState():SetBank("trophyscale_oversizedveggies")
		for i=1, 5 do
			self.scale:GetAnimState():OverrideSymbol("column"..i, "trophyscale_oversizedveggies", "number"..string.sub(picture.weight, i, i)..(DIGIT_COLORS[i] or "_black"))
        end
        local build = PLANT_DEFS[data.plant].build or ("farm_plant_"..data.plant)
        if build ~= nil then
            self.scale:GetAnimState():OverrideSymbol("swap_body", build, "swap_body")
        end
        self.scale:GetAnimState():PlayAnimation("veg_idle", true)
        self.scale:SetScale(anim_scale, anim_scale)
        --scale--

        --player--
        local skinmode = GetSkinModeTable(picture.player, picture.mode)
        self.player = self.root:AddChild(Puppet())
        self.player:SetClickable(false)
        self.player:SetSkins(picture.player, picture.base, picture.clothing, true, skinmode)
        if picture.beardlength then
            self.player.beard = picture.beardskin
            self.player:SetBeardLength(picture.beardlength)
        end
        self.player:AddShadow()

        local skinmode_scale = skinmode and skinmode.scale or 1
        self.player.anim:SetScale(anim_scale * skinmode_scale, anim_scale * skinmode_scale)
        self.player.animstate:PlayAnimation(data.plant_def.pictureframeanim.anim)
        self.player.animstate:SetTime(data.plant_def.pictureframeanim.time)
        self.player.animstate:Pause()
        --player--

        self.picturefilter = self.root:AddChild(Image("images/plantregistry.xml", "oversizedpicturefilter.tex"))
        self.picturefilter:SetPosition(x_pos + 60, y_pos + 85)

        self.scale:SetPosition(x_pos + 100, y_pos - 5)
        self.player:SetPosition(x_pos, y_pos - 10)

    end
    --oversized plant picture--

    self:BuildPlantGrid()

    self.focus_forward = self.plant_grid[1]

    self:_DoFocusHookups()
end

function FarmPlantPage._ctor(self, plantspage, data)
    _FarmPlantPage(self, plantspage, data)
end

---------------------------------------------------
---FarmPlantSummaryWidget
item_icon_remap.onion = "quagmire_onion"
item_icon_remap.tomato = "quagmire_tomato"

local function MakeItemWidget2(root, x, y, item_size, item_name)
    local img_name = (item_icon_remap[item_name] or item_name)..".tex"
    local img_atlas = GetInventoryItemAtlas(img_name, true)
    local backing = root:AddChild(Image(img_atlas or "images/plantregistry.xml", img_atlas ~= nil and img_name or "missing.tex"))
    backing:ScaleToSize(item_size, item_size)
    backing:SetPosition(x, y)
    backing:SetHoverText(STRINGS.NAMES[string.upper(item_name_remap[item_name] or item_name)], {offset_y = 64})

    return backing
end

local FarmPlantSummaryWidget = require("widgets/redux/farmplantsummarywidget")

local _FarmPlantSummaryWidget = function(self, w, data)
    Widget._ctor(self, "FarmPlantSummaryWidget")

    self.w = w
    self.data = data

    self.root = self:AddChild(Widget("root"))

    local x_start = 0
    local y_start = 60

    local spacing_gap = 8

    local details_line_size = 10 * 0.4

    local item_offset = 25
    local item_size = 32

    self.seed_icon = MakeItemWidget2(self.root, x_start - item_offset, y_start, item_size, self.data.plant_def.seed)
    self.product_icon = MakeItemWidget2(self.root, x_start + item_offset, y_start, item_size, self.data.plant_def.product)

    y_start = y_start - (item_size / 2) - spacing_gap * 1.5

    self.season_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local season_size = 24
    local season_gap = 2

    y_start = y_start - (season_size / 2)

    self.season_icons = {}
    local season_sort = TheWorld:HasTag("porkland") and season_sort_hamlet or season_sort_DST

    for season in pairs(self.data.plant_def.good_seasons) do
        if season_sort[season] then
            local season_icon = self.root:AddChild(Image("images/hud/plrebalance_inventoryimages.xml", "season_"..season..".tex"))
            --local season_icon = self.root:AddChild(Image("images/plantregistry.xml", "season_summer.tex"))
            season_icon:ScaleToSize(season_size, season_size)
            season_icon.season = season
            season_icon:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(season)], {offset_y = 48})
            table.insert(self.season_icons, season_icon)
        end
    end

    local season_count = #self.season_icons
    local season_x = x_start - ((season_count * season_size) + ((season_count - 1) * season_gap)) / 2

    table.sort(self.season_icons, function(a, b)
        return season_sort[a.season] > season_sort [b.season]
    end)

    for i, season_icon in ipairs(self.season_icons) do
        season_x = season_x + season_size / 2
        season_icon:SetPosition(season_x, y_start)
        season_x = season_x + season_size / 2 + season_gap
    end

    y_start = y_start - (season_size / 2) - spacing_gap * 1.5

    self.water_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local water_size = 24
    local water_gap = 2

    y_start = y_start - (water_size / 2)

    local water_icon_count =
    {
        [TUNING.FARM_PLANT_DRINK_LOW] = 1,
        [TUNING.FARM_PLANT_DRINK_MED] = 2,
        [TUNING.FARM_PLANT_DRINK_HIGH] = 3,
    }

    self.water_icons = {}
    for i = 1, water_icon_count[self.data.plant_def.moisture.drink_rate] do
        local water_icon = self.root:AddChild(Image("images/plantregistry.xml", "water.tex"))
        water_icon:ScaleToSize(water_size, water_size)
        table.insert(self.water_icons, water_icon)
    end

    local water_count = #self.water_icons
    local water_x = x_start - ((water_count * water_size) + ((water_count - 1) * water_gap)) / 2

    for i, season_icon in ipairs(self.water_icons) do
        water_x = water_x + water_size / 2
        season_icon:SetPosition(water_x, y_start)
        water_x = water_x + water_size / 2 + water_gap
    end

    y_start = y_start - (water_size / 2) - spacing_gap * 1.5

    self.nutrients_seperator = MakeDetailsLine(self.root, x_start, y_start, 0.4)

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local nutrients_size = 18
    local nutrients_gap = 4

    y_start = y_start - (nutrients_size / 2)

    self.nutrients_icons = {}

    local restore_nutrients = self.data.plant_def.nutrient_restoration ~= nil

    local total_nutrients = 0
    for i, v in ipairs(self.data.plant_def.nutrient_consumption) do
        total_nutrients = total_nutrients + v
    end
    local nutrients_restore = not restore_nutrients and 0 or total_nutrients / GetTableSize(self.data.plant_def.nutrient_restoration)

    local total_width = 0
    for nutrient_type = 1, 3 do
        local consume_count = -self.data.plant_def.nutrient_consumption[nutrient_type]
        if restore_nutrients and self.data.plant_def.nutrient_restoration[nutrient_type] then
            consume_count = consume_count + nutrients_restore
        end
        local nutrients_icon = self.root:AddChild(Image("images/plantregistry.xml", "nutrient_"..nutrient_type..".tex"))
        nutrients_icon:ScaleToSize(nutrients_size, nutrients_size)

        nutrients_icon.nutrient_type = nutrient_type
        local neutral = consume_count == 0
        local positive = consume_count > 0

        local imagename
        local prefix
        if neutral then
            imagename = "nutrient_neutral.tex"
            prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.NEUTRAL
        else
            local abs_consume_count = math.abs(consume_count)
            local nutrients_modifier_num = (abs_consume_count <= TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW and 1) or (abs_consume_count >= TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH and 4) or 2
            if positive then
                imagename = "nutrient_up_"..nutrients_modifier_num..".tex"
                prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.RESTORE
            else
                imagename = "nutrient_down_"..nutrients_modifier_num..".tex"
                prefix = STRINGS.UI.PLANTREGISTRY.NUTRIENTS.CONSUME
            end
        end

        nutrients_icon:SetHoverText(prefix..STRINGS.UI.PLANTREGISTRY.NUTRIENTS[string.upper("nutrient_"..nutrient_type)], {offset_y = 48})

        nutrients_icon.modifier = self.root:AddChild(Image("images/plantregistry.xml", imagename))
        nutrients_icon.modifier:ScaleToSize(nutrients_size,nutrients_size)

        total_width = total_width + (nutrients_size * 2) + 2

        table.insert(self.nutrients_icons, nutrients_icon)
    end

    local nutrients_count = #self.nutrients_icons
    local nutrients_x = x_start - (total_width + (nutrients_count - 1) * nutrients_gap) / 2

    for i, nutrients_icon in ipairs(self.nutrients_icons) do
        nutrients_x = nutrients_x + nutrients_size / 2
        nutrients_icon:SetPosition(nutrients_x, y_start)
        nutrients_x = nutrients_x + nutrients_size + 2
        nutrients_icon.modifier:SetPosition(nutrients_x, y_start)
        nutrients_x = nutrients_x + nutrients_size / 2 + nutrients_gap
    end
end

function FarmPlantSummaryWidget._ctor(self, w, data)
    _FarmPlantSummaryWidget(self, w, data)
end

