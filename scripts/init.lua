-- GoldenEye 007 Tracker

print("=============== GOLDENEYE 007 MOVE TRACKER INITIALIZATION =================")

ENABLE_DEBUG_LOG = true -- Disable before any releases

local variant = Tracker.ActiveVariantUID
IS_STANDARD = variant:find("standard")
IS_ITEMS_ONLY = variant:find("itemsonly")
IS_MAPS_ONLY = variant:find("mapsonly")

if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

ScriptHost:LoadScript("scripts/utils.lua")

if IS_STANDARD then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tabs.jsonc")
    ScriptHost:LoadScript("scripts/locations.lua")
    ScriptHost:LoadScript("scripts/layouts.lua")
    ScriptHost:LoadScript("scripts/items.lua")
end

if IS_ITEMS_ONLY then
    ScriptHost:LoadScript("scripts/locations.lua")
    ScriptHost:LoadScript("scripts/layouts.lua")
    ScriptHost:LoadScript("scripts/items.lua")
end

if IS_MAPS_ONLY then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLayouts("layouts/tabs.jsonc")
    ScriptHost:LoadScript("scripts/locations.lua")
        Tracker:AddLayouts("var_z_maps_only/layouts/tracker.jsonc")
    ScriptHost:LoadScript("scripts/items.lua")
end

Tracker:AddMaps("layouts/broadcast/maps.json")
Tracker:AddLayouts("layouts/broadcast/tabs.jsonc")
Tracker:AddLayouts("layouts/broadcast/tracker.jsonc")

if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end

print("GoldenEye tracker initialization complete")
