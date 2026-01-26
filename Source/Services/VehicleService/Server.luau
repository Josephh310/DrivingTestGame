--[[
	@Title: VehicleService Server
    @Author: Joseph (BreakLoop), heavily modified by 010DevX101
	@Description: Handles the vehicle system on the server
]]

local VehicleServiceServer = {}

-- Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Networker = require(ReplicatedStorage.Packages.Networker)

local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local ModelReplicationTools = require(ReplicatedStorage.Shared.Modules.ModelReplicationTools)
local Components = require(ServerScriptService.Modules.VehicleServer.Components)

local ServerVehicleKinds = require(ServerScriptService.Modules.VehicleServer.Kinds)

local VehicleKinds = require(ReplicatedStorage.Shared.Modules.VehicleKinds)
local SpawnedVehicles = workspace.Vehicles

local cleanup: { [Player]: { (...any) -> () } } = {}

-- Types
export type VehicleServiceServer = typeof(VehicleServiceServer)

-- Internal functions
function VehicleServiceServer._spawn_vehicle_model(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model
): Model
	-- TODO: Rework to use stage spawn locations later
	local OFFSET_VECTOR = Vector3.new(0, 4, 0)
	local character = player.Character or player.CharacterAdded:Wait()

	local new_vehicle_model = vehicle_model:Clone()
	new_vehicle_model.Name = player.Name
	new_vehicle_model.Parent = SpawnedVehicles
	new_vehicle_model:MoveTo(character.PrimaryPart.Position + OFFSET_VECTOR)

	new_vehicle_model.PrimaryPart:SetNetworkOwner(player)

	ModelReplicationTools.add_descendants_metadata(new_vehicle_model)
	return new_vehicle_model
end

function VehicleServiceServer._setup_components(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model,
	equipped_vehicle: string
)
	local server_vehicle_config = ServerVehicleKinds[equipped_vehicle]
	if not server_vehicle_config then
		return
	end
	if not cleanup[player] then
		cleanup[player] = {}
	end
	local components = server_vehicle_config.components
	if components.horn then
		table.insert(cleanup[player], Components.horn(player, vehicle_model, components.horn.sound))
	end
end

function VehicleServiceServer._setup_collisions(self: VehicleServiceServer, humanoid: Humanoid, vehicle_model: Model)
	local body = vehicle_model:FindFirstChild("Body")
	if not body or not body:IsA("BasePart") then
		return
	end
	body.Touched:Connect(function(part: BasePart)
		local damage = part:GetAttribute("Damage")
		if not damage then
			return
		end
		humanoid:TakeDamage(damage)
	end)
end

-- Public functions
function VehicleServiceServer.spawn_vehicle(self: VehicleServiceServer, player: Player, _vehicle: string?) -- VehicleOverride is optional
	-- Grab currently equipped vehicle
	local equipped_vehicle = _vehicle or DataServiceServer:get_value(player, { "equipped_vehicle" })
	if not equipped_vehicle then
		return
	end
	-- Get vehicle-specific data
	local vehicle_data = VehicleKinds[equipped_vehicle]
	if not vehicle_data then
		error(`Vehicle module for vehicle {equipped_vehicle} does not exist.`)
	end
	-- Process vehicle-specific data
	local vehicle_model = vehicle_data.vehicle_model
	local vehicle_config = vehicle_data.vehicle_config
	-- Spawn new vehicle
	local new_vehicle, reason = self:_spawn_vehicle_model(player, vehicle_model, vehicle_config)
	if not new_vehicle then
		error(`Unable to spawn vehicle for {player.Name} - {reason}`)
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end
	humanoid.MaxHealth = vehicle_config.health
	humanoid.Health = vehicle_config.health

	self:_setup_components(player, new_vehicle, equipped_vehicle)
	self:_setup_collisions(humanoid, new_vehicle)

	self.networker:fire(player, "setup_vehicle", equipped_vehicle, new_vehicle, vehicle_config)
end

function VehicleServiceServer.request_equip_vehicle(self: VehicleServiceServer, player: Player, vehicle_name: string)
	local SUCCESS_MESSAGE = `Successfully equipped vehicle {vehicle_name}!`
	local owned_vehicles = DataServiceServer:get_value(player, { "vehicles_owned" })
	if not owned_vehicles then
		error(`Error fetching {player.Name}'s owned vehicles.`)
		return
	end
	if not table.find(owned_vehicles, vehicle_name) then
		return "You don't own this vehicle!"
	end
	DataServiceServer:set_value(player, { "equipped_vehicle" }, vehicle_name)
	local equipped_vehicle = DataServiceServer:get_value(player, { "equipped_vehicle" })
	if equipped_vehicle then
		self:reset_vehicle(player)
		return SUCCESS_MESSAGE
	end
	self:spawn_vehicle(player, vehicle_name)
	return SUCCESS_MESSAGE
end

function VehicleServiceServer.reset_vehicle(self: VehicleServiceServer, player: Player)
	local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
	if not vehicle_model or not vehicle_model:IsA("Model") then
		return
	end
	if cleanup[player] then
		for _, fn in cleanup[player] do
			fn()
		end
	end
	vehicle_model:Destroy()
	player.CharacterAdded:Once(function()
		self:spawn_vehicle(player)
	end)
	player:LoadCharacterAsync()
end

function VehicleServiceServer.init(self: VehicleServiceServer)
	self.networker = Networker.server.new("VehicleService", self, { self.request_equip_vehicle, self.reset_vehicle })
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		cleanup[player] = nil
	end)
end

return VehicleServiceServer
