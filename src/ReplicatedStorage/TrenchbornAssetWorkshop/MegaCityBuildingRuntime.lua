-- Shared server runtime. No RemoteEvents; damage must originate from trusted server code.
local Runtime = {}
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
function Runtime.Attach(model, spec, options)
    options = options or {}
    assert(not model:FindFirstChild("MegaCityAPI"), "Model already has a runtime")
    local maxHealth = options.MaxHealth or spec.MaxHealth
    assert(type(maxHealth) == "number" and maxHealth > 0 and maxHealth < math.huge, "Invalid MaxHealth")
    local initialPivot = model:GetPivot()
    local initial = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            initial[p] = {p.Transparency, p.CanCollide, p.CanQuery, p.CFrame}
        end
    end
    model:SetAttribute("AssetId", spec.AssetId)
    model:SetAttribute("EnergyType", spec.EnergyType)
    model:SetAttribute("MaxHealth", maxHealth)
    model:SetAttribute("Health", maxHealth)
    model:SetAttribute("Destroyed", false)
    CollectionService:AddTag(model, "KaijuHouse")
    local api = Instance.new("Folder")
    api.Name = "MegaCityAPI"
    api.Parent = model
    local damage = Instance.new("BindableFunction")
    damage.Name = "ApplyDamage"
    damage.Parent = api
    local reset = Instance.new("BindableFunction")
    reset.Name = "Reset"
    reset.Parent = api
    local payout = Instance.new("BindableEvent")
    payout.Name = "EnergyReleased"
    payout.Parent = api
    local destroyed = Instance.new("BindableEvent")
    destroyed.Name = "Destroyed"
    destroyed.Parent = api
    local effects = {}
    for _, marker in ipairs(model:GetDescendants()) do
        if marker:IsA("Attachment") and marker.Name == "SteamOutlet" then
            local e = Instance.new("ParticleEmitter")
            e.Name = "CoolingSteam"
            e.Texture = "rbxasset://textures/particles/smoke_main.dds"
            e.Color = ColorSequence.new(Color3.fromRGB(235, 243, 250))
            e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(0.2, 0.3), NumberSequenceKeypoint.new(1, 1)})
            e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 12), NumberSequenceKeypoint.new(0.5, 28), NumberSequenceKeypoint.new(1, 44)})
            e.Lifetime = NumberRange.new(5, 8)
            e.Speed = NumberRange.new(8, 12)
            e.Acceleration = Vector3.new(2, 4, 1)
            e.SpreadAngle = Vector2.new(16, 16)
            e.EmissionDirection = Enum.NormalId.Top
            e.Rate = 8
            e.RotSpeed = NumberRange.new(-12, 12)
            e.Enabled = options.Effects ~= false
            e.Parent = marker
            table.insert(effects, e)
        end
    end
    local epoch, tween, pivotDriver, pivotConnection = 0, nil, nil, nil
    local writing = false
    local function writeHealth(value)
        writing = true
        model:SetAttribute("Health", value)
        writing = false
    end
    local function cancelCollapse()
        if tween then tween:Cancel(); tween = nil end
        if pivotConnection then pivotConnection:Disconnect(); pivotConnection = nil end
        if pivotDriver then pivotDriver:Destroy(); pivotDriver = nil end
    end
    local function collapse(source)
        if model:GetAttribute("Destroyed") then return end
        epoch = epoch + 1
        local generation = epoch
        model:SetAttribute("Destroyed", true)
        writeHealth(0)
        for _, e in ipairs(effects) do e.Enabled = false end
        for p in pairs(initial) do p.CanCollide = false; p.CanQuery = false end
        local total = math.floor(maxHealth ^ 0.75 * 1.2)
        local immediate = math.floor(total * 0.4)
        destroyed:Fire(source)
        -- Notifications only. The game owns absorption/rewards and must subscribe before damage.
        payout:Fire(immediate, spec.EnergyType, source)
        task.spawn(function()
            local remaining, paid = total - immediate, 0
            for tick = 1, 15 do
                task.wait(2)
                if generation ~= epoch or not model.Parent then return end
                local target = math.floor(remaining * tick / 15)
                payout:Fire(target - paid, spec.EnergyType, source)
                paid = target
            end
        end)
        pivotDriver = Instance.new("CFrameValue")
        pivotDriver.Value = model:GetPivot()
        pivotConnection = pivotDriver.Changed:Connect(function(cf)
            if model.Parent then model:PivotTo(cf) end
        end)
        local height = model:GetExtentsSize().Y
        tween = TweenService:Create(pivotDriver, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Value = model:GetPivot() * CFrame.new(0, -height * 0.9, 0) * CFrame.Angles(0, 0, math.rad(7))})
        tween:Play()
        task.delay(2.6, function()
            if generation ~= epoch or not model.Parent then return end
            cancelCollapse()
            for p in pairs(initial) do p.Transparency = 1 end
            for _, e in ipairs(effects) do e:Clear() end
        end)
    end
    damage.OnInvoke = function(amount, source)
        if type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then return false end
        if model:GetAttribute("Destroyed") then return false end
        local h = math.max(0, model:GetAttribute("Health") - amount)
        writeHealth(h)
        if h == 0 then collapse(source) end
        return true, h
    end
    reset.OnInvoke = function()
        epoch = epoch + 1
        cancelCollapse()
        model:PivotTo(initialPivot)
        for p, state in pairs(initial) do
            p.CFrame = state[4]
            p.Transparency = state[1]; p.CanCollide = state[2]; p.CanQuery = state[3]
        end
        for _, e in ipairs(effects) do e:Clear(); e.Enabled = options.Effects ~= false end
        model:SetAttribute("Destroyed", false)
        writeHealth(maxHealth)
        return true
    end
    local healthConnection = model:GetAttributeChangedSignal("Health"):Connect(function()
        if writing then return end
        local h = model:GetAttribute("Health")
        if type(h) ~= "number" or h ~= h then writeHealth(maxHealth); return end
        h = math.clamp(h, 0, maxHealth)
        writeHealth(h)
        if h == 0 then collapse(nil) end
    end)
    model.Destroying:Connect(function()
        epoch = epoch + 1
        cancelCollapse()
        healthConnection:Disconnect()
    end)
    return {ApplyDamage = damage, Reset = reset, EnergyReleased = payout, Destroyed = destroyed}
end
return Runtime
