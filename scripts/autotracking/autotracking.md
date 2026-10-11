# GoldenEye AP tracking

The AP callbacks reset tracker state, receive items, and complete checked locations. ITEM_MAPPING and LOCATION_SECTION_MAP in archipelago.lua are the authoritative mappings.

The supplied goldeneye.apworld was audited: 123 persistent items are mapped, 12 temporary filler/trap effects are ignored, and all 844 numeric locations have tracker sections. Six extra manual sections are hidden during an AP session.

Progressive Weapon advances through the world's 30-weapon order and activates the corresponding weapon toggles. Repeated item indexes do not advance it twice. A clear resets replay state, restores checked locations, applies the starting mission, and rebuilds visibility from AP MissingLocations plus CheckedLocations. Goal access follows goal_clear_groups: any clear within each group, every group required.

Items only loads its own layout and disables location tracking. Standard and Maps only load locations and maps.

Run the offline checks from the pack root with Node.js and Lua 5.4:

```text
node tests/validate.mjs [path-to-lua] [path-to-luac]
```

The test uses a mocked PopTracker API. It checks all three loaders, receipt, progressive order, replay, resets, location completion, goal groups, and seed visibility. It does not prove live AP connectivity or actual PopTracker rendering. The AP world comparison was a separate audit of the supplied world version.

Automatic mission tab switching is unavailable: the inspected GoldenEye client reads the mission internally but does not publish it through AP DataStorage. A client publication key and value format must be implemented and verified before adding tracker subscriptions.

API reference: [PopTracker autotracking documentation](https://github.com/black-sliver/PopTracker/blob/master/doc/AUTOTRACKING.md).
