local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleServiceClient = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceClient)

return function(obstacle: Model | BasePart, hit: BasePart)
	VehicleServiceClient:reset_vehicle_position()
end
