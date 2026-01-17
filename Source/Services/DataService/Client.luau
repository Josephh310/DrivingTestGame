--[[
    @Title: DataService Client
    @Author: 010DevX101
    @Description: Client-side interface for player data management.
]]

local DataServiceClient = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)

local ServiceUtils = require(script.Parent.DataServiceUtils)
local ServiceSettings = require(script.Parent.DataServiceSettings)

local player = Players.LocalPlayer
local changed_signals = {}
local data: PlayerData = ServiceSettings.template

--Types
export type DataServiceClient = typeof(DataServiceClient)

type PlayerData = ServiceSettings.PlayerData
type Path = ServiceUtils.Path

--Functions
function DataServiceClient.set_initial_data(self: DataServiceClient, initial_data: PlayerData)
	if not initial_data then
		player:Kick("Your data has not been correctly loaded! Rejoin to try again")
		return
	end
	data = initial_data
end

function DataServiceClient.init(self: DataServiceClient)
	self.networker = Networker.client.new("DataService", self, {})
end

function DataServiceClient.refresh_path(self: DataServiceClient, path: Path)
	if not path then
		return
	end
	for i = 1, #path do
		local current_path = {}
		for v = 1, i do
			current_path[v] = path[v]
		end
		local path_key = table.concat(current_path, "/")
		local changed_signal = changed_signals[path_key]
		if not changed_signal then
			continue
		end
		local current_value = ServiceUtils.get_nested_value(data, current_path)
		changed_signal:Fire(current_value)
	end
end

function DataServiceClient.set_value(self: DataServiceClient, path: Path, value: any?): boolean
	local success = ServiceUtils.set_nested_value(data, path, value)
	if not success then
		warn("Unable to set " .. table.concat(path, "/") .. " to value " .. value)
		return false
	end
	self:refresh_path(path) -- Send an update to all listeners in the path
	return true
end

function DataServiceClient.get_data()
	return data
end

function DataServiceClient.connect_to_value_changed(path: Path, callback: (...any) -> ...any): Signal.Connection
	if not path then
		warn("No path provided")
	end
	if not callback then
		warn("No callback provided")
	end
	local path_key = table.concat(path, "/")
	if not changed_signals[path_key] then
		changed_signals[path_key] = Signal.new()
	end
	local current = ServiceUtils.get_nested_value(data, path)
	do -- Update immediately with initial value
		callback(current)
	end
	return changed_signals[path_key]:Connect(callback)
end

return DataServiceClient
