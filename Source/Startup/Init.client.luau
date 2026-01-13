--[[
    @Title: Client Initialization
    @Author: Joseph (BreakLoop)
    @Description: Initializes client-side services.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceClient = require(ReplicatedStorage.Shared.Services.DataService.DataServiceClient)
DataServiceClient:init()
