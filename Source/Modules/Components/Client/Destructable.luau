local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleServiceUtils = require(ReplicatedStorage.Shared.Services.VehicleService.VehicleServiceUtils)

type PartsPool = {
	[BasePart]: {
		original_transparency: number,
		original_can_collide: boolean,
		touched_connection: RBXScriptConnection,
	},
}

return function(obstacle: Model | BasePart)
	-- Initialize the pool
	-- This will allow for streaming compatibility, as parts can be streamed in and out the model
	local is_on_cooldown = false
	local parts_pool: PartsPool = {}

	local function on_touched(hit: BasePart)
		-- Reject if the destructable is on cooldown
		-- Avoid creating duplicate dummy destructables and doubling-up on damage
		if is_on_cooldown then
			return
		end

		-- Reject if the part colliding with the hitbox is not a vehicle hitbox
		if not hit:HasTag("VehicleHitbox") then
			return
		end

		-- Reject if the vehicle the hitbox belongs to is not the local player's
		local player = VehicleServiceUtils:get_player_from_vehicle(hit.Parent)
		if player ~= Players.LocalPlayer then
			return
		end

		-- Put destructable on cooldown so it cannot be destroyed again
		is_on_cooldown = true

		-- Get the player's humanoid
		-- If it exists and the destructable has damage set up, deal the damage
		if player and player.Character then
			local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
			local damage = obstacle:GetAttribute("Damage")
			if humanoid and damage then
				print(`Damaging {humanoid} by {damage}`)
				humanoid.Health -= damage
			end
		end

		-- Create a dummy prop
		local dummy = obstacle:Clone()
		dummy:RemoveTag("Destructable")
		dummy.Name = `{obstacle.Name} Dummy`
		dummy.Parent = workspace.Debris

		-- Hide real prop
		for part, data in parts_pool do
			part.Transparency = 1
			part.CanCollide = false
		end

		-- Get all parts in the dummy
		local dummy_parts = dummy:QueryDescendants("BasePart")

		-- Weld parts together so the model doesn't break apart
		-- when unanchored
		for _, part in dummy_parts do
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = part
			weld.Part1 = dummy_parts[1] -- Elect a random root part
			weld.Parent = part
		end

		-- Unanchor all parts and make them massless
		-- Encourage them to be moved further by the collision
		for _, part in dummy_parts do
			part.Massless = true
			part.Anchored = false
		end

		-- Impluse the dummy
		local dummy_leader = dummy_parts[1] :: BasePart
		local look_vector = hit.CFrame.LookVector * 100
		dummy_leader:ApplyImpulse(look_vector)

		-- Respawn the destructable after a delay and take it off cooldown
		-- Destroy the dummy
		task.delay(10, function()
			-- Remove the dummy
			dummy:Destroy()

			-- Show the real destructable
			for part, data in parts_pool do
				part.Transparency = data.original_transparency
				part.CanCollide = data.original_can_collide
			end

			-- Take the destructable off-cooldown
			is_on_cooldown = false
		end)
	end

	-- Pool modification functions
	local function add_part(part: BasePart)
		-- Ensure part is actually a part
		if not part:IsA("BasePart") then
			return
		end

		-- Add new part data to the pool
		parts_pool[part] = {
			original_transparency = part.Transparency,
			original_can_collide = part.CanCollide,
			touched_connection = part.Touched:Connect(on_touched),
		}
	end

	local function remove_part(part: BasePart)
		local part_data = parts_pool[part]
		if not part_data then
			return
		end
		if part_data.touched_connection then
			part_data.touched_connection:Disconnect()
		end
		parts_pool[part] = nil
	end

	-- If the tagged instance is a part rather than a model, we should include it in the parts pool.
	if obstacle:IsA("BasePart") then
		add_part(obstacle)
	end

	-- Add all descendants of type BasePart to the parts pool.
	for _, part in obstacle:QueryDescendants("BasePart") do
		add_part(part)
	end

	-- Connect to add or remove parts in the future
	local added_connection = obstacle.DescendantAdded:Connect(add_part)
	local removed_connection = obstacle.DescendantRemoving:Connect(remove_part)

	return function()
		-- Disconnect listeners
		added_connection:Disconnect()
		removed_connection:Disconnect()

		-- Remove all parts from the parts pool
		-- This will disconnect all .Touched connections.
		for part, data in parts_pool do
			remove_part(part)
		end
	end
end
