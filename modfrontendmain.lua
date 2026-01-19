local _modname = modname
GLOBAL.setfenv(1, GLOBAL)

local function SetLevelLocations(servercreationscreen, location, i)
    local server_level_locations = {}
    server_level_locations[i] = location
    server_level_locations[3 - i] = SERVER_LEVEL_LOCATIONS[3 - i]
    servercreationscreen:SetLevelLocations(server_level_locations)
    local text = servercreationscreen.world_tabs[i]:GetLocationTabName()
    servercreationscreen.world_config_tabs.menu.items[i + 1]:SetText(text)
end

local function OnDisableWorldLocations()
    if type(rawget(_G, "PL_EnableWorldLocations")) == "function" then
        PL_ENABLE_WORLD_LOCATION = false
        PL_EnableWorldLocations(PL_ENABLE_WORLD_LOCATION)
    else
        print("function PL_EnableWorldLocations is not exist!")
    end

    local servercreationscreen = TheFrontEnd:GetOpenScreenOfType("ServerCreationScreen")

    if not (servercreationscreen and servercreationscreen.world_tabs)  then
        return
    end

    SetLevelLocations(servercreationscreen, "porkland", 1)
end

local _FrontendUnloadMod = ModManager.FrontendUnloadMod
function ModManager:FrontendUnloadMod(modname, ...)
    if not modname or modname == _modname then  -- modname is nil unload all level
        OnDisableWorldLocations()
        ModManager.FrontendUnloadMod = _FrontendUnloadMod
    end

    return _FrontendUnloadMod(self, modname, ...)
end
