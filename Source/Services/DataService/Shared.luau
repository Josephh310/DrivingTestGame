--[[
    @Title: DataService Settings
    @Author: Joseph (BreakLoop)
    @Description: 
        Configuration for DataService.
        Game-specific save template configuration.
        Game-specific leaderstat configuration.
        Game-specific config flags.
]]

local DataServiceShared = {}

export type PlayerData = {
	stage: number,
	skips: number,
    badges: { string },
	vehicles: { string },
	equipped_vehicle: string,
	products_owned: { string },
	purchase_history: { any },
}

DataServiceShared.template = {
	stage = 0,
	skips = 0,
    badges = {},
	vehicles = {},
	equipped_vehicle = "",
	products_owned = {},
	purchase_history = {},
}

DataServiceShared.leaderstats = {
	stage = "Stage",
}

DataServiceShared.flags = {
	PROFILE_STORE_NAME = "PlayerStore",
	MOCK_STORE_IN_STUDIO = false,
}

return DataServiceShared
