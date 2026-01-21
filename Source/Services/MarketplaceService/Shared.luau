local MarketplaceShared = {}

MarketplaceShared.products = {
	-- Gamepasses
	exclusive_vehicles = {
		asset_id = 1674981873,
		giftable_id = 3517122956,
		product_type = Enum.InfoType.GamePass,
	},
	plate_customisation = {
		asset_id = 1675388395,
		giftable_id = 3517287703,
		product_type = Enum.InfoType.GamePass,
	},
	speed_boost = {
		asset_id = 1674854149,
		giftable_id = 3517122860,
		product_type = Enum.InfoType.GamePass,
	},
	color_customisation = {
		asset_id = 1674736165,
		giftable_id = 3517287554,
		product_type = Enum.InfoType.GamePass,
	},
	vip_pass = {
		asset_id = 1675376816,
		giftable_id = 3517122426,
		product_type = Enum.InfoType.GamePass,
	},

	-- Developer products (automatically giftable)
	skip_1 = {
		asset_id = 3517120513,
		product_type = Enum.InfoType.Product,
	},
	skip_2 = {
		asset_id = 3517120754,
		product_type = Enum.InfoType.Product,
	},
	skip_4 = {
		asset_id = 3517120904,
		product_type = Enum.InfoType.Product,
	},
	skip_8 = {
		asset_id = 3517121010,
		product_type = Enum.InfoType.Product,
	},
	skip_to_end = {
		asset_id = 3517121647,
		product_type = Enum.InfoType.Product,
	},
	troll_everyone = {
		asset_id = 3517122310,
		product_type = Enum.InfoType.Product,
	},
	troll_individual = {
		asset_id = 3517287382,
		product_type = Enum.InfoType.Product,
	},
}

MarketplaceShared.error_codes = {
	ALREADY_OWNS_GAMEPASS = "You already own this gamepass!",
	INSUFFICIENT_FUNDS = "Insufficient Robux",
	PURCHASE_CANCELLED = "Purchase was cancelled",
	PRODUCT_NOT_FOUND = "Product not found",
	INVALID_RECIPIENT = "Invalid gift recipient",
	CANNOT_GIFT_TO_SELF = "Cannot gift to yourself",
	RECIPIENT_OWNS_GAMEPASS = "Recipient already owns this gamepass",
	MARKETPLACE_SERVICE_DOWN = "Marketplace service is currently unavailable",
	UNKNOWN_ERROR = "An unknown error occurred",
}

function MarketplaceShared.get_product(product_code: string)
	return MarketplaceShared.products[product_code]
end

function MarketplaceShared.is_gamepass(product_code: string): boolean
	local product = MarketplaceShared.get_product(product_code)
	return product and product.product_type == Enum.InfoType.GamePass
end

return MarketplaceShared
