return function(part: BasePart)
	-- Instances
	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	local activated = part:FindFirstChildOfClass("BoolValue")

	-- Checks
	if not prompt then
		warn(`ProximityPrompt component in {part.Name} is missing a ProximityPrompt instance.`)
		return
	end
	if not activated then
		warn(`ProximityPrompt component in {part.Name} is missing an activated BoolValue instance.`)
		return
	end

	-- Connections
	local triggered_connection = prompt.Triggered:Connect(function()
		prompt.Enabled = false
		activated.Value = true
	end)

	-- Destructor
	return function()
		triggered_connection:Disconnect()
		triggered_connection = nil
	end
end
