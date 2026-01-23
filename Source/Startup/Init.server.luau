--[[
    @Title: Server Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes server-side services.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ConchServer = require(ServerScriptService.Services.Conch.ConchServer)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local BadgeServiceServer = require(ServerScriptService.Services.BadgeService.BadgeServiceServer)
local MarketplaceServiceServer = require(ServerScriptService.Services.MarketplaceService.MarketplaceServiceServer)
local PhysicsServiceServer = require(ServerScriptService.Services.PhysicsService.PhysicsServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)
local SkipServiceServer = require(ServerScriptService.Services.SkipService.SkipServiceServer)

DataServiceServer:init()
BadgeServiceServer:init()
MarketplaceServiceServer:init()
PhysicsServiceServer:init()
VehicleServiceServer:init()
SkipServiceServer:init()
ConchServer:init()
