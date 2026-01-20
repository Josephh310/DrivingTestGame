local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Vehicles = Assets.Vehicles

type Components = {
    horn: {}?,
    engine: {
        max_steer_angle: number
    }
}

export type VehicleConfig = {
    health: number,
    components: Components?,
}

export type VehicleKind = {
    name: string,
    vehicle_model: Model,
    vehicle_config: VehicleConfig
}

local DEFAULT_CONFIG: VehicleConfig = {
    health = 90,
    components = {
        horn = {},
        engine = {
            max_steer_angle = 25
        }
    }
}

local KINDS: { [string]: VehicleKind } = {
    ["Convertable"] = {
        name = "Convertable",
	    vehicle_model = Vehicles.ConvertableModel,
	    vehicle_config = DEFAULT_CONFIG
    },
    ["Sports Racer"] = {
        name = "Sports Racer",
	    vehicle_model = Vehicles.SportsRacerModel,
	    vehicle_config = DEFAULT_CONFIG
    },
    ["Hatchback"] = {
        name = "Hatchback",
	    vehicle_model = Vehicles.HatchbackModel,
	    vehicle_config = DEFAULT_CONFIG
    },
    ["SUV"] = {
        name = "SUV",
	    vehicle_model = Vehicles.SUVModel,
	    vehicle_config = DEFAULT_CONFIG
    }
}

return table.freeze(KINDS)