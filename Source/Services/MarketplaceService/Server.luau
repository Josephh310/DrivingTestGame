--[[
    @Title: Marketplace server manager
    @Author: Joseph (BreakLoop)
    @Description: Fetch product info via MarketplaceService and handle purchase rewards.
]]

local MarketplaceServer = {
	products_loaded = false,
	product_cache = {},
}

-- Dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

-- Types
export type MarketplaceServer = typeof(MarketplaceServer)

-- Functions

function MarketplaceServer.init(self: MarketplaceServer)
	self.networker = Networker.server.new("MarketplaceService", self, {})
end

return MarketplaceServer
