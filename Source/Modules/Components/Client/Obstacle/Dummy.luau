local DEFAULT_EFFECT_DURATION = 10
local DUMMY_IMPULSE_STRENGTH = 100

local function set_instances_enabled(instances: { Instance }, is_visible: boolean)
	for index, instance in instances do
		if instance:IsA("BasePart") then
			instance.Transparency = if is_visible then 0 else 1
			instance.CanCollide = if is_visible then true else false
			instance.CanTouch = if is_visible then true else false
		elseif instance:IsA("Beam") or instance:IsA("SurfaceLight") then
			instance.Enabled = if is_visible then true else false
		end
	end
end

return function(obstacle: Model | BasePart, hit: BasePart)
	-- Attributes
	local effect_duration = obstacle:GetAttribute("Dummy_Duration") or DEFAULT_EFFECT_DURATION

	-- Create a dummy obstacle to unanchor
	local dummy = obstacle:Clone()
	dummy:RemoveTag("Obstacle")
	dummy.Name = "Dummy"
	dummy.Parent = workspace.Debris

	-- Hide the real obstacle
	local obstacle_descendants = obstacle:GetDescendants()
	set_instances_enabled(obstacle_descendants, false)

	-- Grab all parts inside the dummy
	-- Elect a dummy leader that all the parts will be welded to
	local dummy_parts = dummy:QueryDescendants("BasePart")
	local dummy_leader = dummy.PrimaryPart or dummy_parts[1] :: BasePart

	-- Weld together so the dummy doesn't collapse
	-- Unanchor so the dummy can be kicked around
	for index, part in dummy_parts do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = part
		weld.Part1 = dummy_leader
		weld.Parent = part
	end

	-- Unanchor all the parts
	-- Make them massless so the car can kick them around easier
	for index, part in dummy_parts do
		part.Massless = true
		part.Anchored = false
	end

	-- Impulse the dummy in the direction of the vehicle
	-- This is to create the effect of the dummy being kicked around
	dummy_leader:ApplyImpulse(hit.CFrame.LookVector * DUMMY_IMPULSE_STRENGTH)
	print("impulsing")

	-- Remove the obstacle after a delay
	task.delay(effect_duration, function()
		-- Delete the dummy
		dummy:Destroy()

		-- Show the real obstacle
		set_instances_enabled(obstacle_descendants, true)
	end)
end
