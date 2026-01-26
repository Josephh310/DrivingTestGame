--[[
    @Title: DataService Server
    @Author: Joseph (BreakLoop)
    @Description: Server-side interface for player data management.
]]

local DataServiceServer = {
	_profiles = {},
}

-- Dependancies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local ServiceShared = require(ReplicatedStorage.Shared.Services.DataService.DataServiceShared)
local ServiceUtils = require(ReplicatedStorage.Shared.Services.DataService.DataServiceUtils)

-- Types
export type DataServiceServer = typeof(DataServiceServer)

-- Internal functions
function DataServiceServer._critical_status_changed(self: DataServiceServer, is_critical: boolean)
	-- This function will be called if the roblox DataStoreService becomes unstable.
	if is_critical then
		print("DataService has entered a critical state")
	else
		print("DataStore is stable")
	end
end

function DataServiceServer._create_leaderstats(self: DataServiceServer, player: Player)
	-- No need to create new leaderstats if the player already has them
	if player:FindFirstChild("leaderstats") then
		return
	end

	-- Get current player data, so we can fill values into the leaderboard
	local data = self:get_data(player)

	-- New leaderstats folder, required to show stats on server leaderboard
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Fill values
	for leaderstat_name, display_name in ServiceShared.leaderstats do
		-- Get current value and type of ValueBase to store it in
		local leaderstat_value = data[leaderstat_name]
		local value_type = (typeof(leaderstat_value) == "string" and "StringValue") or "NumberValue"

		-- Create new ValueBase
		local new_leaderstat = Instance.new(value_type)
		new_leaderstat.Name = display_name -- Could be capitalised differently
		new_leaderstat.Value = leaderstat_value or new_leaderstat.Value
		new_leaderstat.Parent = leaderstats
	end
end

function DataServiceServer._get_profile_key(self: DataServiceServer, player: Player)
	-- Player profile key must be a string.
	return tostring(player.UserId)
end

function DataServiceServer._player_removed(self: DataServiceServer, player: Player)
	-- Player is leaving, end their session
	local profile = self._profiles[player]
	if profile then
		profile:EndSession()
		self._profiles[player] = nil
	end
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
	self.networker:fire(player, "set_initial_data", new_profile.Data)

	-- Create leaderstats
	self:_create_leaderstats(player)
end

-- Public functions
function DataServiceServer.get_profile(self: DataServiceServer, player: Player)
	-- Return full profile, including ProfileStore values
	local profile = nil

	-- Repeat until the player's profile is added or the player leaves the game
	repeat
		profile = self._profiles[player]
		task.wait()
	until profile ~= nil or player.Parent ~= Players

	-- Return the profile, or nil if the profile was never able to be created.
	return profile
end

function DataServiceServer.get_data(self: DataServiceServer, player: Player)
	-- Return only the player's game-specific data
	return self:get_profile(player).Data
end

function DataServiceServer.get_value(self: DataServiceServer, player: Player, path: Path)
	-- Return a specific value from the player's game-specific data
	local data = self:get_data(player)
	local value = ServiceUtils.get_nested_value(data, path)
	return value
end

function DataServiceServer.set_value(self: DataServiceServer, player: Player, path: Path, value: any?)
	-- Get player's game-specific data and attempt to set a value
	local data = self:get_data(player)
	local set_successfully = ServiceUtils.set_nested_value(data, path, value)
	if not set_successfully then
		error("Unable to set " .. table.concat(path, "/") .. " to " .. value)
		return
	end

	-- Replicate this change to the client
	self.networker:fire(player, "set_value", path, value)

	-- If the stat is a base (level 1) value, check if it's a registered leaderstat
	if #path == 1 then
		-- Get the stat display name
		-- If this exists, it's a leaderstat.
		local stat_name = path[1]
		local display_name = ServiceShared.leaderstats[stat_name]
		if not display_name then
			return
		end

		-- Check if the player has a corresponding leaderstat object
		-- If so, set the value to the new updated value so that the server lb updates.
		local leaderstat_value = player:WaitForChild("leaderstats"):FindFirstChild(display_name)
		if leaderstat_value then
			leaderstat_value.Value = value
		end
	end
end

function DataServiceServer.apply_change(self: DataServiceServer, player: Player, path: Path, callback, ...)
	-- Get current value of the value at path
	local data = self:get_data(player)
	local value = ServiceUtils.get_nested_value(data, path)

	-- Give the callback the current value
	-- Logic in the callback will modify it then return a new value
	local new_value = callback(value, ...)

	-- Save the new value
	DataServiceServer:set_value(player, path, new_value)
end

function DataServiceServer.init(self: DataServiceServer)
	-- Initialize
	self.profile_store = ProfileStore.New(ServiceShared.flags.PROFILE_STORE_NAME, ServiceShared.template)
	self.networker = Networker.server.new("DataService", self, {})

	-- ProfileStore mode
	if ServiceShared.flags.MOCK_STORE_IN_STUDIO and RunService:IsStudio() then
		self.profile_store = self.profile_store.Mock
	end

	-- Player connections
	for index, player in Players:GetPlayers() do
		task.defer(function()
			self:_player_added(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		self:_player_added(player)
		print(player.Name .. " joined the game")
	end)

	Players.PlayerRemoving:Connect(function(player: Player, exit_reason: Enum.PlayerExitReason)
		self:_player_removed(player)
		print(player.Name .. " left the game (" .. tostring(exit_reason) .. ")")
	end)

	-- Critical state listener
	ProfileStore.OnCriticalToggle:Connect(function(is_critical: boolean)
		self:_critical_status_changed(is_critical)
	end)
end

return DataServiceServer
