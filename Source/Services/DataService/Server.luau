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
function DataServiceServer._get_profile_key(self: DataServiceServer, player: Player)
	-- Player profile key must be a string.
	return tostring(player.UserId)
end
function DataServiceServer._player_added(self: DataServiceServer, player: Player)
	-- Construct new session
	local key = self:_get_profile_key(player)
	local new_profile = self.profile_store:StartSessionAsync(key, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Verfy session has been created
	if new_profile == nil then
		player:Kick("Unable to load your profile, please rejoin")
		return
	end

	-- Initialize new session
	new_profile:Reconcile()
	new_profile:AddUserId(player.UserId)
	new_profile.OnSessionEnd:Connect(function()
		self._profiles[player] = nil
		player:Kick("Your session has been ended unexpectedly, please rejoin")
	end)

	-- Verify player has loaded
	if player.Parent ~= Players then
		new_profile:EndSession()
		return
	end

	-- Success, store player profile
	self._profiles[player] = new_profile
end
end

return DataServiceServer
