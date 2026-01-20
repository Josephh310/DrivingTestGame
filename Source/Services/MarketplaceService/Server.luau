local MarketplaceServer = {}

-- Dependancies
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

-- Types
export type MarketplaceServer = typeof(MarketplaceServer)

-- Functions
function MarketplaceServer.get_cached_products(self: MarketplaceServer) end

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
	})
end

return MarketplaceServer
