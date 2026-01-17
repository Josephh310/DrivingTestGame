local SkipServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)

-- Types
export type SkipServiceServer = typeof(SkipServiceServer)

-- Constants
local CleanupFunctions = {}

-- Functions
function SkipServiceServer._player_removing(self: SkipServiceServer, player: Player)
	CleanupFunctions[player]()
end

function SkipServiceServer._player_added(self: SkipServiceServer, player: Player)
	-- Init attribute
	player:SetAttribute("SkipTimer", 600)

	-- Loop until player leaves
	local session_active = true
	repeat
		local timer_value = player:GetAttribute("SkipTimer")
		task.wait(1)
		if timer_value <= 0 then
			player:SetAttribute("SkipTimer", 600)
			self:give_skip(player)
		else
			player:SetAttribute("SkipTimer", timer_value - 1)
		end
	until session_active == false

	-- Store cleanup function for when the player leaves
	CleanupFunctions[player] = function()
		session_active = false
	end
end

function SkipServiceServer.give_skip(self: SkipServiceServer, player: Player)
	DataServiceServer:apply_change(player, { "Skips" }, function(current_value: number)
		return current_value + 1
	end)
end

function SkipServiceServer.init(self: SkipServiceServer)
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
