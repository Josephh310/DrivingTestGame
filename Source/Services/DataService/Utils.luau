--[[
    @Title: DataService Utilities
    @Author: Joseph (BreakLoop)
    @Description: Utility functions for player data management.
]]

local PlayerDataShared = {}

--Functions
function PlayerDataShared.GetNestedValue(tbl, path: { string })
	if not tbl or not path then
		return nil
	end

	local current = tbl
	for _, key in ipairs(path) do
		if type(current) ~= "table" then
			return nil
		end
		current = current[key]
		if current == nil then
			return nil
		end
	end

	return current
end

function PlayerDataShared.SetNestedValue(tbl, path: { string }, value)
	if not tbl or not path or #path == 0 then
		return false
	end

	local current = tbl
	for i = 1, #path - 1 do
		local key = path[i]

		if type(current[key]) ~= "table" then
			current[key] = {}
		end

		current = current[key]
	end

	current[path[#path]] = value
	return true
end

return PlayerDataShared
