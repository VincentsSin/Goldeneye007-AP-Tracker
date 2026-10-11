-- Offline PopTracker API simulation. No server connection.

local function check(value,message) assert(value,message) end
for _,variant in ipairs({'standard','itemsonly','mapsonly'}) do
 local objects, loaded, layouts, maps = {}, {}, {}, {}
 local function once(p) check(not loaded[p], 'Loaded twice: '..p); loaded[p]=true; return assert(DOCS[p],p) end
 Tracker={ActiveVariantUID=variant,BulkUpdate=false}
 function Tracker:AddItems(p)
  for _,item in ipairs(once(p)) do
   for code in string.gmatch(item.codes or '', '[^,]+') do
    check(not objects[code], 'Duplicate item '..code)
    objects[code]={Type=item.type,Active=false,CurrentStage=0,AcquiredCount=0}
   end
  end
 end
 local function addLocations(nodes,parent)
  for _,node in ipairs(nodes) do
   local name=node.name and (parent..'/'..node.name) or parent
   for _,section in ipairs(node.sections or {}) do
    if section.name then
    local code='@'..name:sub(2)..'/'..section.name
    check(not objects[code],'Duplicate section '..code)
    objects[code]={ChestCount=section.item_count or 1,AvailableChestCount=section.item_count or 1}
    end
   end
   addLocations(node.children or {},name)
  end
 end
 function Tracker:AddLocations(p) addLocations(once(p),'') end
 function Tracker:AddLayouts(p) for k,v in pairs(once(p)) do check(not layouts[k],'Duplicate layout '..k); layouts[k]=v end end
 function Tracker:AddMaps(p) for _,map in ipairs(once(p)) do maps[map.name]=true end end
 function Tracker:FindObjectForCode(code) return assert(objects[code],'Missing object '..code) end
 function Tracker:ProviderCountForCode(code)
  local o=self:FindObjectForCode(code)
  if o.Type=='consumable' then return o.AcquiredCount end
  if o.Type=='progressive' then return o.CurrentStage end
  return o.Active and 1 or 0
 end
 ScriptHost={}
 function ScriptHost:LoadScript(p) check(not loaded[p],'Script loaded twice '..p);loaded[p]=true;dofile(p) end
 Archipelago={MissingLocations={},CheckedLocations={}}
 function Archipelago:AddClearHandler(name,handler) check(not self.clear,'Duplicate clear');self.clear=handler end
 function Archipelago:AddItemHandler(name,handler) check(not self.item,'Duplicate item');self.item=handler end
 function Archipelago:AddLocationHandler(name,handler) check(not self.location,'Duplicate location');self.location=handler end
 PopVersion='0.32.0'
 dofile('scripts/init.lua')
 check(Archipelago.clear and Archipelago.item and Archipelago.location,'Missing callbacks')
 local function checkLayout(node)
  if type(node)~='table' then return end
  if node.type=='layout' then check(layouts[node.key],'Missing layout '..tostring(node.key)) end
  if node.type=='map' then check(maps[node.maps and node.maps[1] or node.name],'Missing map') end
  for _,value in pairs(node) do if type(value)=='table' then checkLayout(value) end end
 end
 for _,layout in pairs(layouts) do checkLayout(layout) end
 check(goldeneyeLocationEnabled('70110001'),'Offline visibility')
 local first,second,third=LOCATIONS[1],LOCATIONS[2],LOCATIONS[3]
 Archipelago.MissingLocations={first.id,second.id,third.id}
 Archipelago.CheckedLocations={}
 Archipelago.clear({options={starting_mission=1},goal_clear_groups={{first.id,second.id},{third.id}}})
 check(objects.dam.Active,'Starting mission')
 check(goldeneyeLocationEnabled(tostring(first.id)),'Enabled location')
 check(not goldeneyeLocationEnabled('0'),'Non-AP section hidden')
 for _,mapping in ipairs(ITEMS) do Archipelago.item(_-1,mapping.id,'',1) end
 for _,mapping in ipairs(ITEMS) do
  local item=objects[mapping.code]
  check(item.Active or item.CurrentStage>0 or item.AcquiredCount>0,'Item not received '..mapping.code)
 end
 Archipelago.clear({options={}})
 for _,mapping in ipairs(ITEMS) do
  local item=objects[mapping.code]
  check(not item.Active and item.CurrentStage==0 and item.AcquiredCount==0,'Item reset '..mapping.code)
 end
 for i,code in ipairs(WEAPONS) do
  Archipelago.item(i-1,17310000,'',1)
  check(objects.progressive_weapon.CurrentStage==i,'Progressive stage')
  check(objects[code].Active,'Progressive unlock '..code)
  Archipelago.item(i-1,17310000,'',1)
  check(objects.progressive_weapon.CurrentStage==i,'Duplicate increment')
 end
 Archipelago.item(30,17310000,'',1)
 check(objects.progressive_weapon.CurrentStage==30,'Progressive overflow')
 Archipelago.clear({options={}})
 for i=0,4 do Archipelago.item(i,17310000,'',1) end
 check(objects.progressive_weapon.CurrentStage==5,'Reconnect replay')
 if variant~='itemsonly' then
  for _,mapping in ipairs(LOCATIONS) do
   Archipelago.location(mapping.id,'');Archipelago.location(mapping.id,'')
   check(objects[mapping.code].AvailableChestCount==0,'Location not checked '..mapping.code)
  end
  Archipelago.clear({options={},goal_clear_groups={{first.id,second.id},{third.id}}})
  check(not goldeneyeGoalComplete(),'Goal premature')
  Archipelago.location(second.id,'');check(not goldeneyeGoalComplete(),'Goal missing group')
  Archipelago.location(third.id,'');check(goldeneyeGoalComplete(),'Goal all groups')
  Archipelago.CheckedLocations={first.id};Archipelago.MissingLocations={second.id}
  Archipelago.clear({options={}})
  check(objects[first.code].AvailableChestCount==0,'Checked snapshot')
  check(objects[second.code].AvailableChestCount==objects[second.code].ChestCount,'Reset unchecked')
  Archipelago.CheckedLocations={};Archipelago.MissingLocations={third.id}
  Archipelago.clear({options={}})
  check(not goldeneyeLocationEnabled(tostring(first.id)),'Old seed visibility')
  check(goldeneyeLocationEnabled(tostring(third.id)),'New seed visibility')
  check(objects[first.code].AvailableChestCount==objects[first.code].ChestCount,'Old seed completion')
 else
  for _,mapping in ipairs(LOCATIONS) do Archipelago.location(mapping.id,'') end
 end
 print('PASS '..variant..': loading, receipt, replay, resets, seed visibility')
end
