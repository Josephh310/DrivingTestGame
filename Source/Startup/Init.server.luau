--[[
    @Title: Server Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes server-side services.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
DataServiceServer:init()
