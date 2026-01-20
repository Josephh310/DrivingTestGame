local function get_descendants_which_are_parts(model: Model): { BasePart }
	return model:QueryDescendants("BasePart")
end

local function add_descendants_metadata(model: Model)
	local model_descendants = #get_descendants_which_are_parts(model)
	model:SetAttribute("Descendants", model_descendants)
end

local function wait_for_descendants(model: Model, timeout: number)
	timeout = timeout or 5
	local model_descendants = model:GetAttribute("Descendants")
	if not model_descendants then
		error(`{model:GetFullName()} does not have a descendants tag`)
	end
	local combined_time = 0
	local model_passed = false
	repeat
		local time_waited = task.wait()
		combined_time += time_waited
		local current_descendants = #get_descendants_which_are_parts(model)
		if current_descendants == model_descendants then
			model_passed = true
		end
	until model_passed or combined_time > timeout
	if not model_passed then
		error("Model did not load within the time allowed")
	end
end

return {
    add_descendants_metadata = add_descendants_metadata,
    get_descendants_which_are_parts = get_descendants_which_are_parts,
    wait_for_descendants = wait_for_descendants
}