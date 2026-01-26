local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Vehicles = Assets.Vehicles

type Components = {
	horn: {}?,
	engine: {
		max_steer_angle: number,
	},
}

export type VehicleConfig = {
	health: number,
	components: Components?,
}

export type VehicleKind = {
	display_name: string,
	vehicle_model: Model,
	vehicle_config: VehicleConfig,
}

local DEFAULT_CONFIG: VehicleConfig = {
	health = 90,
	components = {
		horn = {},
		engine = {
			max_steer_angle = 25,
		},
	},
}

local KINDS: { [string]: VehicleKind } = {
	["convertable"] = {
		display_name = "Convertable",
		vehicle_model = Vehicles.ConvertableModel,
		vehicle_config = DEFAULT_CONFIG,
	},
	["sports_racer"] = {
		display_name = "Sports Racer",
		vehicle_model = Vehicles.SportsRacerModel,
		vehicle_config = DEFAULT_CONFIG,
	},
	["hatchback"] = {
		display_name = "Hatchback",
		vehicle_model = Vehicles.HatchbackModel,
		vehicle_config = DEFAULT_CONFIG,
	},
	["suv"] = {
		display_name = "SUV",
		vehicle_model = Vehicles.SUVModel,
		vehicle_config = DEFAULT_CONFIG,
	},
}

return table.freeze(KINDS)
