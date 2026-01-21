local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

local post_init_functions = {}

function AddPrefabRegisterPostInit(prefab, post_init)
    if Prefabs[prefab] then
        post_init(Prefabs[prefab])
        return
    end
    if not post_init_functions[prefab] then
        post_init_functions[prefab] = {}
    end
    table.insert(post_init_functions[prefab], post_init)
end

local register_prefabs_impl = RegisterPrefabsImpl
RegisterPrefabsImpl = function(prefab, ...)
    local ret = { register_prefabs_impl(prefab, ...) }
    local prefab_name = prefab.name
    if post_init_functions[prefab_name] then
        for _, post_init in ipairs(post_init_functions[prefab_name]) do
            post_init(prefab)
        end
    end
    return unpack(ret)
end

local component_posts = {
    "banditmanager",
    "door",
    "worldmigrator",
}

local component_posts_skyworthy = { -- it takes effect when the 3 shards mode is enabled
    "moistureoverride",
    "sinkholespawner",
    "acidinfusible",
    "acidlevel",
    "ambientsound",
    "birdspawner",
    "brightmarespawner",
    "frograin",
    "lunarhailbuildup",
    "lunarhailmanager",
    "weather",
    "wildfires",
    "moonstormmanager",
    "clock",
    "herdmember",
    "keeponpassable",
}

local prefab_posts = {
    "pigman_queen",
    "pigman_city",
    "portablespicer",
    "porkland",
    "relics",
    "resurrectionstone",
    "wishingwell",
    "mermking",
    "tubertrees",
    "terrarium",
    "trinkets",
    "nettle_plant",
    "birdcage",
    "grass_tall",
    "disguisehat",
}

local prefab_posts_skyworthy = { -- it takes effect when the 3 shards mode is enabled
    "junk_pile",
    "pigking",
    "world",
    "interiorworkblank",
    "multiplayer_portal",
    "voidcloth_scythe",
    "snowball",
    "porklandintro",
}

local multipleprefab_posts = {
    "deployable",
    "seeds",
    "watersource",
}

local multipleprefab_posts_skyworthy = { -- it takes effect when the 3 shards mode is enabled
}

local screens_posts = {
    "playerhud",
}

local module_posts = {
    ["components/aporkalypse"] = "aporkalypse", 
}

local module_posts_skyworthy = {
    ["components/map"] = "map",
}


if PL_CONFIG["ENABLE_SKYWORTHY"] then
    for i = 1,#component_posts_skyworthy do
        table.insert(component_posts, component_posts_skyworthy[i])
    end
    for i = 1,#prefab_posts_skyworthy do
        table.insert(prefab_posts, prefab_posts_skyworthy[i])
    end
    for i = 1,#multipleprefab_posts do
        table.insert(multipleprefab_posts, multipleprefab_posts_skyworthy[i])
    end
    for k, v in pairs(module_posts_skyworthy) do
        module_posts[k] = v
    end
end

local _require = require
---@param module_name string
function require(module_name, ...)
    local no_loaded = package.loaded[module_name] == nil
    local ret = { _require(module_name, ...) }
    if module_posts[module_name] and no_loaded then -- only load when first
        modimport("postinit/modules/" .. module_posts[module_name])
    end
    return unpack(ret)
end

modimport("postinit/shardindex")

for _, file_name in ipairs(module_posts) do
    modimport("postinit/modules/" .. file_name)
end

for _, file_name in ipairs(component_posts) do
    modimport("postinit/components/" .. file_name)
end

for _, file_name in ipairs(prefab_posts) do
    modimport("postinit/prefabs/" .. file_name)
end

for _, file_name in ipairs(multipleprefab_posts) do
    modimport("postinit/multipleprefabs/" .. file_name)
end

for _, file_name in ipairs(screens_posts) do
    modimport("postinit/screens/" .. file_name)
end

