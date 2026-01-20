local MarketplaceClient = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

-- Types
export type MarketplaceClient = typeof(MarketplaceClient)

function MarketplaceClient.init(self: MarketplaceClient)
	self.networker = Networker.client.new("MarketplaceService", self)
end

return MarketplaceClient
