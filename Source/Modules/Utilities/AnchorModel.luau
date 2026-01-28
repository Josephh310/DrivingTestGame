return function(model: Model, toggle: boolean)
    for _, part in model:GetChildren() do
        if not part:IsA("BasePart") then
            continue
        end
        part.Anchored = toggle
    end
end
