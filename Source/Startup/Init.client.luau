--[[
    @Title: Client Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes client-side services.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
local Interface = require(ReplicatedStorage.Interface)
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)
local SkipServiceClient = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceClient)

DataServiceClient:init()
VehicleServiceClient:init()
SkipServiceClient:init()
Interface:init()
