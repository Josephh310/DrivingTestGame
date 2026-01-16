--[[
    @Title: DataService Settings
    @Author: Joseph (BreakLoop)
    @Description: 
        Configuration for DataService.
        Game-specific save template configuration.
        Game-specific leaderstat configuration.
        Game-specific config flags.
]]

export type PlayerData = {
    stage: number,
    equipped_vehicle: string,
    vehicles_owned: { string }
}

return table.freeze({
    template = {
		stage = 0,
		equipped_vehicle = "Hatchback",
		vehicles_owned = {
			"Hatchback",
		},
	},
	leaderstats = {
		stage = "Stage",
	},
	flags = {
		PROFILE_STORE_NAME = "PlayerStore",
		MOCK_STORE_IN_STUDIO = false,
	},
})
