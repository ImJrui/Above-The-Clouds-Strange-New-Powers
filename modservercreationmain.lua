local modname = modname
local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

modimport("modfrontendmain")

if type(rawget(_G, "PL_EnableWorldLocations")) == "function" then
    PL_ENABLE_WORLD_LOCATION = true
    PL_EnableWorldLocations(PL_ENABLE_WORLD_LOCATION)
else
    print("function PL_EnableWorldLocations is not exist!")
end