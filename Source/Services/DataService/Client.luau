--[[
    @Title: DataService Client
    @Author: Joseph (BreakLoop)
    @Description: Client-side interface for player data management.
]]

local DataServiceClient = {}

function DataServiceClient.Init()
	print("DataServiceClient initialized.")
-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

--Types
export type DataServiceClient = typeof(DataServiceClient)

--Functions
function DataServiceClient.replicate_value_change(self: DataServiceClient, ...)
	print("Value replicated", ...)
end

function DataServiceClient.init(self: DataServiceClient)
	self.networker = Networker.client.new("DataService", self, {})
end

return DataServiceClient
