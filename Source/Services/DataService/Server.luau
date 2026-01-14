--[[
    @Title: DataService Server
    @Author: Joseph (BreakLoop)
    @Description: Server-side interface for player data management.
]]

local DataServiceServer = {}
local DataServiceServer = {
	_profiles = {},
}

function DataServiceServer.Init()
	print("DataServiceServer initialized.")
end

return DataServiceServer
