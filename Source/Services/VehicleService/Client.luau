--[[
	@Title: VehicleService Client
    @Author: 010DevX101
	@Description: Handles the vehicle system on the client
]]

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Components = require(ReplicatedStorage.Shared.Services.VehicleService.Shared.Components)
local VehicleKinds = require(ReplicatedStorage.Shared.Services.VehicleService.Shared.Vehicles)
local Networker = require(ReplicatedStorage.Packages.Networker)
local ModelReplicationTools = require(ReplicatedStorage.Shared.Modules.Utilities.ModelReplicationTools)

local player = Players.LocalPlayer

local VehicleServiceClient = {}

local cleanup: { [number]: (...any) -> () } = {}

-- Types
type VehicleServiceClient = typeof(VehicleServiceClient)
type VehicleConfig = VehicleKinds.VehicleConfig

-- Public functions
function VehicleServiceClient.init(self: VehicleServiceClient)
	self.networker = Networker.client.new("VehicleService", self)
end

function VehicleServiceClient._setup_components(self: VehicleServiceClient)
	local components = self.vehicle_config.components
	if components.horn then
		table.insert(cleanup, Components.horn())
	end
	if components.engine then
		local chassis = self.scripted.Chassis
		local platform = chassis.Platform
		local constraints = self.scripted.Constraints
		table.insert(
			cleanup,
			Components.engine(
				self.vehicle_seat,
				constraints:GetChildren(),
				{ platform.AttachmentFL, platform.AttachmentFR },
				components.engine.max_steer_angle
			)
		)
	end
end

function VehicleServiceClient._force_sit(self: VehicleServiceClient)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	return function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

function VehicleServiceClient.setup_vehicle(
	self: VehicleServiceClient,
	vehicle_name: string,
	vehicle_model: Model,
	vehicle_config: VehicleConfig
)
	self.vehicle_model = vehicle_model
	self.vehicle_config = vehicle_config
	self.vehicle_name = vehicle_name
	ModelReplicationTools.wait_for_descendants(self.vehicle_model, 5)
	self.scripted = self.vehicle_model.Scripted :: Model
	self.vehicle_seat = self.scripted.VehicleSeat :: VehicleSeat

	table.insert(cleanup, self:_force_sit())
	self:_setup_components()
end

function VehicleServiceClient.cleanup()
	for _, fn in cleanup do
		fn()
	end
end

function VehicleServiceClient.reset_vehicle(self: VehicleServiceClient)
	self.networker:fire("reset_vehicle")
end

function VehicleServiceClient.equip_vehicle(self: VehicleServiceClient, vehicle_name: string): string
	return self.networker:fetch("request_equip_vehicle", vehicle_name)
end

return VehicleServiceClient
