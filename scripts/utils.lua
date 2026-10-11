GOLDENEYE_ENABLED_LOCATIONS = {}
GOLDENEYE_ENABLED_MISSIONS = {}
GOLDENEYE_GOAL_GROUPS = {}

function goldeneyeLocationEnabled(location_id)
    if Tracker:ProviderCountForCode("ap_session") == 0 then return true end
    return GOLDENEYE_ENABLED_LOCATIONS[tonumber(location_id)] == true
end

function goldeneyeMissionEnabled(mission_name)
    if Tracker:ProviderCountForCode("ap_session") == 0 then return true end
    return GOLDENEYE_ENABLED_MISSIONS[mission_name] == true
end

function goldeneyeGoalComplete()
    if Tracker:ProviderCountForCode("victory") > 0 then return true end
    Tracker:ProviderCountForCode("ap_session")
    if #GOLDENEYE_GOAL_GROUPS == 0 then return false end
    for _, group in ipairs(GOLDENEYE_GOAL_GROUPS) do
        local complete = false
        for _, path in ipairs(group) do
            if Tracker:FindObjectForCode(path).AvailableChestCount == 0 then
                complete = true
            end
        end
        if not complete then return false end
    end
    return true
end

function has(item, amount)
	local count = Tracker:ProviderCountForCode(item)
	amount = tonumber(amount)
	if not amount then
		return count > 0
	else
		return count >= amount
	end
end

function checkRequirements(reference, check_count)
  local reqCount = Tracker:ProviderCountForCode(reference)
  local count = Tracker:ProviderCountForCode(check_count)

  if count >= reqCount then
      return true
  else
      return false
  end
end

function toggle_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code.."_hosted"
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_item: could not find object for code %s", code))
    end
  end
end

function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function dump_table(o, depth)
	if depth == nil then
		depth = 0
	end
	if type(o) == 'table' then
		local tabs = ('\t'):rep(depth)
		local tabs2 = ('\t'):rep(depth + 1)
		local s = '{\n'
		for k, v in pairs(o) do
			if type(k) ~= 'number' then
				k = '"' .. k .. '"'
			end
			s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
		end
		return s .. tabs .. '}'
	else
		return tostring(o)
	end
end

function toggle_hosted_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code:gsub("_hosted", "")
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_hosted_item: could not find object for code %s", code))
    end
  end
end
