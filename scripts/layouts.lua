if IS_COMPACT then
    Tracker:AddLayouts("layouts/compact/items.jsonc")
else
    Tracker:AddLayouts("layouts/items.jsonc")
end

Tracker:AddLayouts("layouts/weapons.jsonc")
if IS_ITEMS_ONLY then
    Tracker:AddLayouts("layouts/items_only.jsonc")
elseif IS_COMPACT then
    Tracker:AddLayouts("layouts/compact/tracker.jsonc")
else
    Tracker:AddLayouts("layouts/tracker.jsonc")
end
Tracker:AddLayouts("layouts/missions.jsonc")
Tracker:AddLayouts("layouts/cheats.jsonc")