--[[
	@Title: VehicleService Server
    @Author: Joseph (BreakLoop), heavily modified by 010DevX101
	@Description: Handles the vehicle system on the server
]]

local VehicleServiceServer = {}

-- Dependencies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TextService = game:GetService("TextService")

local Networker = require(ReplicatedStorage.Packages.Networker)

local DataServiceServer = require(ServerScriptService.Services.DataService.DataServiceServer)
local ModelReplicationTools = require(ReplicatedStorage.Shared.Modules.ModelReplicationTools)
local Components = require(ServerScriptService.Services.VehicleService.Server.Components)
local ServerVehicleKinds = require(ServerScriptService.Services.VehicleService.Server.Vehicles)
local VehicleKinds = require(ReplicatedStorage.Shared.Services.VehicleService.Shared.Vehicles)

local SpawnedVehicles = workspace.Vehicles
local Map = workspace.Map
local Stages = Map.Stages

local cleanup: { [Player]: { (...any) -> () } } = {}

-- Types
export type VehicleServiceServer = typeof(VehicleServiceServer)

-- Internal functions
function VehicleServiceServer._spawn_vehicle_model(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model,
	position_or_part: Vector3? | BasePart?
): Model?
	local OFFSET_VECTOR = Vector3.new(0, 4, 0)
	local character = player.Character or player.CharacterAdded:Wait()
	if not character.PrimaryPart then
		return nil
	end

	local position = character.PrimaryPart.Position + OFFSET_VECTOR
	if typeof(position_or_part) == "Vector3" then
		position = position_or_part
	elseif typeof(position_or_part) == "Instance" and position_or_part:IsA("BasePart") then
		position = position_or_part.Position
	end

	local new_vehicle_model = vehicle_model:Clone()
	new_vehicle_model.Name = player.Name
	new_vehicle_model.Parent = SpawnedVehicles
	new_vehicle_model:MoveTo(position)

	if new_vehicle_model.PrimaryPart then
		new_vehicle_model.PrimaryPart:SetNetworkOwner(player)
	end

	ModelReplicationTools.add_descendants_metadata(new_vehicle_model)
	return new_vehicle_model
end

function VehicleServiceServer._force_sit(self: VehicleServiceServer, player: Player, vehicle_model: Model)
	local scripted = vehicle_model:FindFirstChild("Scripted")
	if not scripted then
		warn("Vehicle model is missing Scripted directory!")
		return
	end
	local vehicle_seat = scripted:FindFirstChild("VehicleSeat")
	if not vehicle_seat then
		warn("Vehicle model is missing VehicleSeat!")
		return
	end
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		warn(`Player {player.Name} does not have a valid Humanoid instance!`)
		return
	end
	if vehicle_seat.Occupant ~= humanoid then
		vehicle_seat:Sit(humanoid)
	end
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
	humanoid.Died:Connect(function()
		self:_destroy_vehicle(vehicle_model)
	end)
end

function VehicleServiceServer._set_plate(self: VehicleServiceServer, player: Player, vehicle_model: Model, text: string)
	local license_plate = vehicle_model:FindFirstChild("NumberPlate")
	if not license_plate or not license_plate:IsA("Model") then
		warn("Vehicle does not have a license plate!")
		return
	end
	local base = license_plate:FindFirstChild("Base")
	if not base or not base:IsA("BasePart") then
		warn("License plate does not have a base!")
		return
	end
	local plate_text = base:FindFirstChild("SurfaceGui"):FindFirstChild("PlateText")
	if not plate_text or not plate_text:IsA("TextLabel") then
		return
	end
	plate_text.Text = text
end

function VehicleServiceServer._customise_color(
	self: VehicleServiceServer,
	player: Player,
	vehicle_model: Model,
	color: Color3
)
	for _, colorable_part in vehicle_model:QueryDescendants("BasePart.Colorable") do
		colorable_part = colorable_part :: BasePart
		colorable_part.Color = color
	end
end

function VehicleServiceServer._spawn_vehicle_at_stage(self: VehicleServiceServer, player: Player, stage: number)
	if stage == 0 then
		return
	end
	local Stage = Stages:FindFirstChild(`Stage{stage}`)
	if not Stage or not Stage:IsA("Folder") then
		warn(`Invalid stage {stage}!`)
		return
	end
	local Spawns = Stage:FindFirstChild("Spawns")
	if not Spawns or not Spawns:IsA("Folder") then
		warn(`Stage {stage} does not contain a Spawns directory!`)
		return
	end
	local spawns = Spawns:GetChildren()
	local selected_spawn: BasePart = spawns[math.random(1, #spawns)]
	local overlap_params = OverlapParams.new()
	overlap_params.FilterType = Enum.RaycastFilterType.Include
	overlap_params.MaxParts = 1
	for _, spawn in spawns do
		if not spawn:IsA("BasePart") then
			continue
		end
		overlap_params.FilterDescendantsInstances = SpawnedVehicles:GetChildren()
		local part_bounds_in_box = workspace:GetPartBoundsInBox(spawn.CFrame, spawn.Size, overlap_params)
		if #part_bounds_in_box > 0 then
			continue
		end
		selected_spawn = spawn
	end
	self:spawn_vehicle(player, selected_spawn.Position)
end

function VehicleServiceServer._destroy_vehicle(self: VehicleServiceServer, player: Player, vehicle_model: Model?)
	vehicle_model = vehicle_model or SpawnedVehicles:FindFirstChild(player.Name)
	if not vehicle_model or not vehicle_model:IsA("Model") then
		return
	end
	local body = vehicle_model:FindFirstChild("Body")
	if not body or not body:IsA("BasePart") then
		return
	end
	local explosion = Instance.new("Explosion")
	explosion.Visible = false
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.TimeScale = 1.5
	explosion.BlastRadius = 8
	explosion.BlastPressure = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.Position = body.Position
	explosion.Parent = body
	explosion.Visible = true
	task.delay(2, explosion.Destroy, explosion)
	for _, weld in vehicle_model:QueryDescendants("WeldConstraint") do
		weld:Destroy()
	end
	task.delay(1, vehicle_model.Destroy, vehicle_model)
	self.networker:fire(player, "cleanup")
	self:_cleanup(player)
end

function VehicleServiceServer._cleanup(self: VehicleServiceServer, player: Player)
	for _, fn in cleanup[player] do
		fn()
	end
end

function VehicleServiceServer._spawn_vehicle(
	self: VehicleServiceServer,
	player: Player,
	position: Vector3?,
	vehicle: string?
) -- VehicleOverride is optional
	-- Grab currently equipped vehicle
	local equipped_vehicle = vehicle or DataServiceServer:get_value(player, { "equipped_vehicle" })
	if not equipped_vehicle then
		return
	end
	local spawned_vehicle = SpawnedVehicles:FindFirstChild(player.Name)
	if spawned_vehicle and spawned_vehicle:IsA("Model") then
		self:_destroy_vehicle(player, spawned_vehicle)
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
	local new_vehicle, reason = self:_spawn_vehicle_model(player, vehicle_model, position)
	if not new_vehicle then
		error(`Unable to spawn vehicle for {player.Name} - {reason}`)
		return
	end
	local plate = DataServiceServer:get_value(player, { "plate" })
	if plate ~= nil then
		self:_set_plate(player, new_vehicle, plate)
	end
	local vehicles = DataServiceServer:get_value(player, { "vehicles" })
	local color_data: { r: number, g: number, b: number }? = vehicles[equipped_vehicle].color
	if color_data then
		self:_customise_color(player, new_vehicle, Color3.fromRGB(color_data.r, color_data.g, color_data.b))
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
	self:_force_sit(player, new_vehicle)

	self.networker:fire(player, "setup_vehicle", equipped_vehicle, new_vehicle, vehicle_config)
end

-- Public functions
function VehicleServiceServer.request_customise_color(
	self: VehicleServiceServer,
	player: Player,
	vehicle_name: string,
	color: Color3
)
	if typeof(color) ~= "Color3" or typeof(vehicle_name) ~= "string" then
		return
	end
	local products = DataServiceServer:get_value(player, { "products_owned" })
	if not table.find(products, "color_customisation") then
		warn(`User {player.Name} does not own color customisation gamepass!`)
		return
	end
	local vehicles = DataServiceServer:get_value(player, { "vehicles" })
	local vehicle = vehicles[vehicle_name]
	if not vehicle then
		warn(`User does not own vehicle {vehicle_name}!`)
		return
	end
	DataServiceServer:apply_change(player, { "vehicles" }, function(current)
		current[vehicle_name] = {
			color = {
				r = color.R * 255,
				g = color.G * 255,
				b = color.B * 255,
			},
		}
		return current
	end)
	local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
	if vehicle_model and vehicle_model:IsA("Model") then
		self:_customise_color(player, vehicle_model, color)
	end
end

function VehicleServiceServer.request_set_plate(self: VehicleServiceServer, player: Player, original_text: string)
	local function save_and_set_plate(filtered: string)
		DataServiceServer:set_value(player, { "plate" }, filtered)
		local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
		if not vehicle_model or not vehicle_model:IsA("Model") then
			self:_set_plate(player, vehicle_model, filtered)
		end
	end
	if typeof(original_text) ~= "string" then
		return
	end
	local text: string
	local MAX_PLATE_LENGTH = 8
	local products = DataServiceServer:get_value(player, { "products_owned" })
	if not table.find(products, "plate_customisation") then
		warn(`User {player.Name} does not own plate customisation gamepass!`)
		return
	end
	if text == "" then
		save_and_set_plate(text)
		return
	end
	text = string.upper(string.sub(original_text, 1, MAX_PLATE_LENGTH))
	local success, result = pcall(function()
		return TextService:FilterStringAsync(original_text, player.UserId)
	end)
	if not success then
		warn(`Failed to filter text: {result}`)
		return
	end
	text = result:GetNonChatStringForBroadcastAsync()
	save_and_set_plate(text)
end

function VehicleServiceServer.request_equip_vehicle(
	self: VehicleServiceServer,
	player: Player,
	vehicle_name: string
): string
	local SUCCESS_MESSAGE = `Successfully equipped vehicle {vehicle_name}!`
	local owned_vehicles = DataServiceServer:get_value(player, { "vehicles" })
	if not owned_vehicles then
		return `Error fetching {player.Name}'s owned vehicles.`
	end
	if not owned_vehicles[vehicle_name] then
		return "You don't own this vehicle!"
	end
	DataServiceServer:set_value(player, { "equipped_vehicle" }, vehicle_name)
	local equipped_vehicle = DataServiceServer:get_value(player, { "equipped_vehicle" })
	if equipped_vehicle then
		self:reset_vehicle(player)
		return SUCCESS_MESSAGE
	end
	local stage = DataServiceServer:get_value(player, { "stage" })
	self:_spawn_vehicle_at_stage(player, stage)
	return SUCCESS_MESSAGE
end

function VehicleServiceServer.reset_vehicle(self: VehicleServiceServer, player: Player)
	local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
	if not vehicle_model or not vehicle_model:IsA("Model") then
		return
	end
	local stage = DataServiceServer:get_value(player, { "stage" })
	self:_destroy_vehicle(player, vehicle_model)
	player.CharacterAdded:Once(function()
		self:_spawn_vehicle_at_stage(player, stage)
	end)
	player:LoadCharacterAsync()
end

function VehicleServiceServer.init(self: VehicleServiceServer)
	self.networker = Networker.server.new("VehicleService", self, {
		self.request_equip_vehicle,
		self.reset_vehicle,
		self.request_set_plate,
		self.request_customise_color,
	})

	local function player_added(player: Player)
		cleanup[player] = {}
		local equipped_vehicle = DataServiceServer:get_value(player, { "equipped_vehicle" })
		local stage = DataServiceServer:get_value(player, { "stage" })
		if VehicleKinds[equipped_vehicle] ~= nil then
			self:_spawn_vehicle_at_stage(player, stage)
		end
	end

	-- Vehicle removal logic
	Players.PlayerRemoving:Connect(function(player)
		local vehicle_model = SpawnedVehicles:FindFirstChild(player.Name)
		if vehicle_model then
			self:_destroy_vehicle(player, vehicle_model)
		end
		cleanup[player] = nil
	end)

	-- Vehicle spawning logic
	Players.PlayerAdded:Connect(player_added)
	for _, player in Players:GetPlayers() do
		player_added(player)
	end
end

return VehicleServiceServer
