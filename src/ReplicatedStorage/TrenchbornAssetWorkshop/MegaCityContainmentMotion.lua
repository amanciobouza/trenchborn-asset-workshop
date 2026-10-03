-- One shared animation loop; keeps all existing Parts and follows the model pivot.
local Motion = {}
function Motion.Attach(model)
    local RunService = game:GetService("RunService")
    local initialPivot = model:GetPivot()
    local entries = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "CoreHalo" or part.Name == "EnergyHelix") then
            local localFrame = initialPivot:ToObjectSpace(part.CFrame)
            entries[#entries + 1] = {part = part, frame = localFrame,
                ring = part.Name == "CoreHalo", phase = localFrame.Position.Y * 0.065}
        end
    end
    local elapsed, accumulated = 0, 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        -- Let the shared destruction runtime move/hide the whole model unhindered.
        if not model.Parent or model:GetAttribute("Destroyed") then return end
        elapsed = elapsed + dt
        accumulated = accumulated + dt
        if accumulated < 1 / 30 then return end
        accumulated = accumulated % (1 / 30)
        local pivot = model:GetPivot()
        -- Both strands rotate together, preserving their separation.
        local turn = CFrame.new(0, 0, 10) * CFrame.Angles(0, elapsed * math.pi / 9, 0) * CFrame.new(0, 0, -10)
        for _, entry in ipairs(entries) do
            if entry.part.Parent then
                if entry.ring then
                    local offset = 3 * math.sin(elapsed * math.pi / 3 + entry.phase)
                    entry.part.CFrame = pivot * CFrame.new(0, offset, 0) * entry.frame
                else
                    entry.part.CFrame = pivot * turn * entry.frame
                end
            end
        end
    end)
    model.Destroying:Connect(function() connection:Disconnect() end)
end
return Motion
