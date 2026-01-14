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
-- Dependancies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local ServiceSettings = require(ReplicatedStorage.Shared.Services.DataService.DataServiceSettings)
local ServiceUtils = require(ReplicatedStorage.Shared.Services.DataService.DataServiceUtils)

-- Types
export type DataServiceServer = typeof(DataServiceServer)
export type Path = { string }
end

return DataServiceServer
