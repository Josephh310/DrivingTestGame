local SkipServiceClient = {}

-- Dependencies
local Players = game:GetService("Players")
local SkipServiceSettings = require(script.Parent.SkipServiceSettings)

-- Constants
local timer_connections = {}
local player = Players.LocalPlayer

-- Types
export type SkipServiceClient = typeof(SkipServiceClient)
export type Timer = number

-- Functions
function SkipServiceClient._timer_updated(self: SkipServiceClient)
	local value = self:get_timer()
	for index, callback in timer_connections do
		callback(value)
	end
end

function SkipServiceClient.get_timer(self: SkipServiceClient)
	-- :3
	return player:GetAttribute(SkipServiceSettings.timer_attribute_name)
end

function SkipServiceClient.listen_to_timer(self: SkipServiceClient, callback: (Timer) -> ())
	-- Store the callback to call whenever the SkipTimer updates
	local callback_index = #timer_connections + 1
	timer_connections[callback_index] = callback

	-- Send an initial value to the callback to instantly update ui
	local current_time = self:get_timer()
	callback(current_time)

	-- Return a function to disconnect the listener
	return function()
		timer_connections[callback_index] = nil
	end
end

function SkipServiceClient.init(self: SkipServiceClient)
	-- Subscribe to SkipTimer replication from the server
	player:GetAttributeChangedSignal(SkipServiceSettings.timer_attribute_name):Connect(function()
		self:_timer_updated()
	end)
end

return SkipServiceClient
