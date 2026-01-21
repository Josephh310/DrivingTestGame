--[[
    @Title: Marketplace client manager
    @Author: Joseph (BreakLoop)
    @Description: Fetch products from server and handle purchases
]]

local MarketplaceClient = {
	products_loaded = false,
	product_cache = {},
}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

-- Types
export type MarketplaceClient = typeof(MarketplaceClient)

-- Functions

function MarketplaceClient.init(self: MarketplaceClient)
	self.networker = Networker.client.new("MarketplaceService", self)
end

return MarketplaceClient
