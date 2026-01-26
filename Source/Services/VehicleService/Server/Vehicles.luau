local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundEffects = ReplicatedStorage.Assets.SoundEffects

export type VehicleConfig = {
	components: {
		horn: {
			sound: Sound,
		}?,
	}?,
}

local DEFAULT_CONFIG: VehicleConfig = {
	components = {
		horn = {
			sound = SoundEffects.DefaultCarHorn,
		},
	},
}

local KINDS: { [string]: VehicleConfig } = {
	["convertable"] = DEFAULT_CONFIG,
	["sports_racer"] = DEFAULT_CONFIG,
	["hatchback"] = DEFAULT_CONFIG,
	["suv"] = DEFAULT_CONFIG,
}

return table.freeze(KINDS)
