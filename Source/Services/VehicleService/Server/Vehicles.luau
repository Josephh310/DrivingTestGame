local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundEffects = ReplicatedStorage.Assets.SoundEffects

export type VehicleConfig = {
    components: {
        horn: {
            sound: Sound
        }?
    }?
}

local DEFAULT_CONFIG: VehicleConfig = {
    components = {
        horn = {
            sound = SoundEffects.DefaultCarHorn
        }
    }
}

local KINDS: { [string]: VehicleConfig } = {
    ["Convertable"] = DEFAULT_CONFIG,
    ["Sports Racer"] = DEFAULT_CONFIG,
    ["Hatchback"] = DEFAULT_CONFIG,
    ["SUV"] = DEFAULT_CONFIG
}

return table.freeze(KINDS)