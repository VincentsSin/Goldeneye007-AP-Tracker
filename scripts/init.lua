-- GoldenEye 007 Tracker

print("=============== GOLDENEYE 007 MOVE TRACKER INITIALIZATION =================")

-- Load items
print("Loading Bond move items...")
Tracker:AddItems("items/items.jsonc")

-- Load maps
print("Loading Bond maps...")
Tracker:AddMaps("maps/maps.json")

-- Load locations
print("Loading Bond locations...")
Tracker:AddLocations("locations/missions.jsonc")
Tracker:AddLocations("locations/dam.jsonc")
Tracker:AddLocations("locations/facility.jsonc")
Tracker:AddLocations("locations/runway.jsonc")
Tracker:AddLocations("locations/surface_one.jsonc")
Tracker:AddLocations("locations/bunker_one.jsonc")
Tracker:AddLocations("locations/silo.jsonc")
Tracker:AddLocations("locations/frigate.jsonc")
Tracker:AddLocations("locations/surface_two.jsonc")
Tracker:AddLocations("locations/bunker_two.jsonc")
Tracker:AddLocations("locations/statue.jsonc")
Tracker:AddLocations("locations/archives.jsonc")
Tracker:AddLocations("locations/streets.jsonc")
Tracker:AddLocations("locations/depot.jsonc")
Tracker:AddLocations("locations/train.jsonc")
Tracker:AddLocations("locations/jungle.jsonc")
Tracker:AddLocations("locations/control.jsonc")
Tracker:AddLocations("locations/caverns.jsonc")
Tracker:AddLocations("locations/cradle.jsonc")
Tracker:AddLocations("locations/aztec.jsonc")
Tracker:AddLocations("locations/egyptian.jsonc")

-- Load tracker layout
print("Loading tracker layout...")
Tracker:AddLayouts("layouts/tracker.jsonc")
if Tracker.ActiveVariantUID == "horizontal_broadcast" then
    print("Loading horizontal broadcast overlay...")
    Tracker:AddLayouts("horizontal_broadcast/layouts/tracker.json")
end

-- Load autotracking scripts
print("Loading autotracking...")
ScriptHost:LoadScript("scripts/archipelago.lua")

print("Goldeneye Move Tracker loaded successfully!")
print("================ INITIALIZATION COMPLETE ================")

ENABLE_DEBUG_LOG = true -- Disable before any releases

local variant = Tracker.ActiveVariantUID
IS_STANDARD = variant:find("standard")
IS_ITEMS_ONLY = variant:find("itemsonly")
IS_MAPS_ONLY = variant:find("mapsonly")

if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

ScriptHost:LoadScript("scripts/utils.lua")
ScriptHost:LoadScript("scripts/logic.lua")
ScriptHost:LoadScript("scripts/inverse_rules.lua")
ScriptHost:LoadScript("scripts/regions.lua")
Tracker:AddLayouts("layouts/broadcast.jsonc")
ScriptHost:LoadScript("scripts/items.lua")

if IS_STANDARD then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tabs.jsonc")
    ScriptHost:LoadScript("scripts/locations.lua")
    ScriptHost:LoadScript("scripts/layouts.lua")
end

if IS_ITEMS_ONLY then
    ScriptHost:LoadScript("scripts/layouts.lua")
end

if IS_MAPS_ONLY then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tabs.jsonc")
    ScriptHost:LoadScript("scripts/locations.lua")
    Tracker:AddLayouts("layouts/settings_popup.jsonc")
    Tracker:AddLayouts("layouts/settings.jsonc")
    Tracker:AddLayouts("var_z_maps_only/layouts/tracker.jsonc")
end

if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end