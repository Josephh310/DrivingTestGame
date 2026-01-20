local MarketplaceServer = {
	product_cache = {},
}

-- Dependancies
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)
local MarketplaceServiceShared = require(ReplicatedStorage.Shared.Services.MarketplaceService.MarketplaceServiceShared)

-- Types
export type MarketplaceServer = typeof(MarketplaceServer)

-- Functions
function MarketplaceServer.get_cached_products(self: MarketplaceServer)
	return self.product_cache
end

function MarketplaceServer.get_product_info(self: MarketplaceServer, asset_id: number, product_type: Enum.InfoType)
	local attempts = 0
	local info = nil
	local get_info = function()
		return MarketplaceService:GetProductInfoAsync(asset_id, product_type)
	end
	repeat
		local success, returned = pcall(get_info)
		if success then
			info = returned
		else
			warn(returned)
			attempts += 1
		end
	until attempts >= 5 or info ~= nil
	return info
end

function MarketplaceServer.init(self: MarketplaceServer)
	self.networker = Networker.server.new("MarketplaceService", self, {
		self.get_cached_products,
		self.get_product_info,
	})
	for index, product_data in MarketplaceServiceShared.products do
		local asset_id = product_data.product_id
		local product_type = product_data.product_type
		self.product_cache[index] = self:get_product_info(asset_id, product_type)
	end
end

return MarketplaceServer
