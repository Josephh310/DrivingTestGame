local SkipServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local SkipServiceShared = require(ReplicatedStorage.Shared.Services.SkipService.SkipServiceShared)
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local VehicleServiceServer = require(ServerScriptService.Services.VehicleService.VehicleServiceServer)

-- Types
export type SkipServiceServer = typeof(SkipServiceServer)

-- Constants
local cleanup_functions = {}

-- Functions
function SkipServiceServer.get_player_timer(self: SkipServiceServer, player: Player)
	return player:GetAttribute(SkipServiceShared.timer_attribute_name)
end

function SkipServiceServer.set_player_timer(self: SkipServiceServer, player: Player, time: number)
	player:SetAttribute(SkipServiceShared.timer_attribute_name, time)
end

function SkipServiceServer._player_removing(self: SkipServiceServer, player: Player)
	cleanup_functions[player]()
end

function SkipServiceServer._player_added(self: SkipServiceServer, player: Player)
	-- Init attribute
	self:set_player_timer(player, SkipServiceShared.skip_timer_seconds)

	-- Loop until player leaves
	local session_active = true
	repeat
		local timer_value = self:get_player_timer(player)
		task.wait(1)
		if timer_value <= 0 then
			self:set_player_timer(player, SkipServiceShared.skip_timer_seconds)
			self:give_skip(player)
		else
			self:set_player_timer(player, timer_value - 1)
		end
	until session_active == false

	-- Store cleanup function for when the player leaves
	cleanup_functions[player] = function()
		session_active = false
	end
end

function SkipServiceServer.give_skip(self: SkipServiceServer, player: Player)
	DataServiceServer:apply_change(player, { "skips" }, function(current_value: number)
		return current_value + 1
	end)
end

function SkipServiceServer.init(self: SkipServiceServer)
	-- Expose use_skip to the client
	self.networker = Networker.server.new("SkipService", self, {
		self.use_skip,
	})

	-- Registed players already in the game
	for index, player in Players:GetPlayers() do
		task.defer(function()
			self:_player_added(player)
		end)
	end

	-- Listen for future players added
	Players.PlayerAdded:Connect(function(player)
		SkipServiceServer:_player_added(player)
	end)
end

return SkipServiceServer
