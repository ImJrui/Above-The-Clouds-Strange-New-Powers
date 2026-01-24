local AddSimPostInit = AddSimPostInit
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------
local farm_plant_defs = require("prefabs/farm_plant_defs")

local PORKLAND_SEASONS = {
    temperate = true,
    humid     = true,
    lush      = true,
}

local FOREST_SEASONS = {
    autumn = true,
    winter = true,
    spring = true,
    summer = true,
}

local function NormalizeGoodSeasonsForWorld(plant_def, world_seasons)
    if plant_def.normalized then
        return
    end

    local old_seasons = plant_def.good_seasons
    if type(old_seasons) ~= "table" then
        return
    end

    local new_seasons = {}

    for season in pairs(old_seasons) do
        if world_seasons[season] then
            new_seasons[season] = true
        end
    end

    plant_def.good_seasons = new_seasons
    plant_def.normalized = true
end

AddSimPostInit(function()
    local is_porkland = TheWorld:HasTag("porkland")
    local world_seasons = is_porkland and PORKLAND_SEASONS or FOREST_SEASONS

    local new_defs = {}

    for name, def in pairs(farm_plant_defs.PLANT_DEFS) do
        local plant_def = shallowcopy(def)
        NormalizeGoodSeasonsForWorld(plant_def, world_seasons)
        new_defs[name] = plant_def
    end

    farm_plant_defs.PLANT_DEFS = new_defs
end)
------------------------------------------------------------
local Image = require "widgets/image"

local season_sort = {
    temperate = 3,
    humid = 2,
    lush = 1,
}

local LEARN_PERCENTS = {
    SEASON = 1/4,
    WATER = 2/4,
    NUTRIENTS = 3/4,
    DESCRIPTION = 4/4,
}

local FarmPlantPage = require("widgets/redux/farmplantpage")
local _FarmPlantPage_ctor = FarmPlantPage._ctor
function FarmPlantPage._ctor(self, plantspage, data)
    -- 临时清理season，只保留春夏秋冬的数据
    -- local good_seasons_porkland = {}
    -- for season in pairs(data.plant_def.good_seasons) do
    --     if PL_WORLD_SEASONS[season] then
    --         good_seasons_porkland[season] = true
    --         data.plant_def.good_seasons[season] = nil
    --     end
    -- end

    _FarmPlantPage_ctor(self, plantspage, data)

    if not TheWorld:HasTag("porkland") or self.seasons == nil then
        return
    end

    -- 转换season为哈姆雷特类型
    -- data.plant_def.good_seasons = good_seasons_porkland

    if self.unknown_seasons_text ~= nil then
        return
    end

    local title_font_size = 16
    local pos_start = self.seasons:GetPosition()
    local x_start = pos_start.x
    local y_start = pos_start.y

    local season_y = y_start - title_font_size/2 - 3
    local season_size = 32
    local season_gap = 6

    if self.known_percent >= LEARN_PERCENTS.SEASON then
        for _, season_icon in ipairs(self.season_icons or {}) do
            season_icon:Kill()
        end
        --display season icons.
        self.season_icons = {}
        for season in pairs(self.data.plant_def.good_seasons) do
            local season_icon = self.root:AddChild(Image("images/hud/plrebalance_inventoryimages.xml", "season_"..season..".tex"))
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
        -- season_y = season_y - 10 - unknown_font_size / 2
        -- self.unknown_seasons_text = self.root:AddChild(Text(HEADERFONT, unknown_font_size, STRINGS.UI.PLANTREGISTRY.NEEDSMORERESEARCH, PLANTREGISTRYUICOLOURS.LOCKEDBROWN))
        -- self.unknown_seasons_text:SetPosition(x_start, season_y)
        -- self.unknown_seasons_text:SetHAlign(ANCHOR_MIDDLE)
        -- self.seasons:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
    end
end
------------------------------------------------------------
local FarmPlantSummaryWidget = require("widgets/redux/farmplantsummarywidget")
local _FarmPlantSummaryWidget_ctor = FarmPlantSummaryWidget._ctor

function FarmPlantSummaryWidget._ctor(self, w, data)
    -- 临时清理season，只保留春夏秋冬的数据
    -- local good_seasons_porkland = {}
    -- for season in pairs(data.plant_def.good_seasons) do
    --     if PL_WORLD_SEASONS[season] then
    --         good_seasons_porkland[season] = true
    --         data.plant_def.good_seasons[season] = nil
    --     end
    -- end

    _FarmPlantSummaryWidget_ctor(self, w, data)

    -- 转换season为哈姆雷特类型
    if not TheWorld:HasTag("porkland") or self.season_seperator == nil then
        return
    end

    -- data.plant_def.good_seasons = good_seasons_porkland

    local pos_start = self.season_seperator:GetPosition()
    local x_start = pos_start.x
    local y_start = pos_start.y

    local spacing_gap = 8

    local details_line_size = 10 * 0.4

    y_start = y_start - details_line_size - (spacing_gap / 4)

    local season_size = 24
    local season_gap = 2

    y_start = y_start - (season_size / 2)

    for _, season_icon in ipairs(self.season_icons or {}) do
        season_icon:Kill()
    end

    self.season_icons = {}
    for season in pairs(self.data.plant_def.good_seasons) do
        local season_icon = self.root:AddChild(Image("images/hud/plrebalance_inventoryimages.xml", "season_"..season..".tex"))
        season_icon:ScaleToSize(season_size, season_size)
        season_icon.season = season
        season_icon:SetHoverText(STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(season)], {offset_y = 48})
        table.insert(self.season_icons, season_icon)
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
end

