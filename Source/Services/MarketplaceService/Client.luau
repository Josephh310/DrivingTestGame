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

function MarketplaceClient.get_product_cache(self: MarketplaceClient)
	-- Wait until product info has been fetched from the server
	repeat
		task.wait()
	until self.products_loaded == true

	-- Return fetched products
	return self.product_cache
end

function MarketplaceClient.get_product_info(self: MarketplaceServiceClient, product_code: string)
	-- This function will yield if a server was just started up
	local product_cache = self:get_product_cache()
	local product_info = product_cache[product_code]

	-- Check if the product is missing, this may happen if MarketplaceService is down,
	-- or if an invalid product code is provided.
	if not product_info then
		warn(`Unable to get info for product with code {product_code}, MarketplaceService may be down`)
		return
	end

	-- Product info exists, return it to the calling script
	return product_info
end

function MarketplaceClient.init(self: MarketplaceClient)
	self.networker = Networker.client.new("MarketplaceService", self)
	task.defer(function()
		self.product_cache = self.networker:fetch("get_cached_products")
		self.products_loaded = true
	end)
end

return MarketplaceClient
