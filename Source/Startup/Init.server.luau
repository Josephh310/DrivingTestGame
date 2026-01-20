--[[
    @Title: Server Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes server-side services.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local PhysicsServiceServer = require(ServerScriptService.Services.PhysicsService.PhysicsServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)
local SkipServiceServer = require(ServerScriptService.Services.SkipService.SkipServiceServer)

DataServiceServer:init()
PhysicsServiceServer:init()
VehicleServiceServer:init()
SkipServiceServer:init()
