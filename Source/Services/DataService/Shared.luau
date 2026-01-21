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
	equipped_vehicle: string,
	vehicles_owned: { string },
	owned_gamepasses: { string },
	purchase_history: { any },
	pending_gifts: { any },
}

DataServiceShared.template = {
	stage = 0,
	skips = 0,
	vehicles = {},
	equipped_vehicle = "",
	owned_gamepasses = {},
	purchase_history = {},
	pending_gifts = {},
}

DataServiceShared.leaderstats = {
	stage = "Stage",
}

DataServiceShared.flags = {
	PROFILE_STORE_NAME = "PlayerStore",
	MOCK_STORE_IN_STUDIO = false,
}

return DataServiceShared
