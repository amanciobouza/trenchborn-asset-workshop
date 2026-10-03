-- Fixed native-Part pool: edit-mode lightning remains visible; Play animates it.
local Lightning = {}
function Lightning.Attach(model)
    local rng = Random.new()
    local segments = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and (p.Name == "LightningHalo" or p.Name == "LightningCore") then
            local id = p:GetAttribute("LightningSegment")
            if id then
                segments[id] = segments[id] or {}
                segments[id][p.Name] = p
            end
        end
    end
    local alive = true
    local function hide()
        for _, pair in pairs(segments) do
            for _, p in pairs(pair) do p.Transparency = 1 end
        end
    end
    local changed = model:GetAttributeChangedSignal("Destroyed"):Connect(function()
        if model:GetAttribute("Destroyed") then hide() end
    end)
    model.Destroying:Connect(function()
        alive = false
        changed:Disconnect()
    end)
    task.spawn(function()
        while alive and model.Parent do
            if not model:GetAttribute("Destroyed") then
                local pivot = model:GetPivot()
                for bolt = 0, 3 do
                    local z = bolt < 2 and -20 or 20
                    local side = bolt % 2 == 0 and -1 or 1
                    local points = {}
                    for node = 0, 8 do
                        local x = side * (node % 2 == 0 and 3 or 13)
                        if node > 0 and node < 8 then x = x + rng:NextNumber(-3, 3) end
                        points[node + 1] = Vector3.new(x, 41 + node * 14.4, z + rng:NextNumber(-0.6, 0.6))
                    end
                    local dim = rng:NextNumber()
                    for node = 1, 8 do
                        local pair = segments[bolt * 8 + node]
                        if pair then
                            local a, b = pivot:PointToWorldSpace(points[node]), pivot:PointToWorldSpace(points[node + 1])
                            local cf = CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(math.pi / 2, 0, 0)
                            for name, p in pairs(pair) do
                                local halo = name == "LightningHalo"
                                local width = halo and 1.5 or 0.55
                                p.Size = Vector3.new(width, (b - a).Magnitude, width)
                                p.CFrame = cf
                                p.Transparency = halo and (0.25 + dim * 0.3) or (dim * 0.18)
                            end
                        end
                    end
                end
            end
            task.wait(0.13)
        end
    end)
end
return Lightning
