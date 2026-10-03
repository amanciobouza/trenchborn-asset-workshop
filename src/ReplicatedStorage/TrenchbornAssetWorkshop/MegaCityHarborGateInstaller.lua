-- MC-01 review candidate. Origin is ground level; sea facade faces local -Z.
local Geometry = require(script.Parent.MegaCityHarborGateGeometry)
local Spec = require(script.Parent.MegaCityHarborGateSpecification)
local Runtime = require(script.Parent.MegaCityBuildingRuntime)
local Installer = {}
function Installer.Install(parent, options)
    options = options or {}
    local scale = options.Scale or 1
    assert(type(scale) == "number" and scale > 0 and scale < math.huge, "Scale must be positive")
    local model = Instance.new("Model")
    model.Name = options.Name or "MegaCityHarborGateTerminal"
    local origin = Instance.new("Part")
    origin.Name = "Origin"
    origin.Size = Vector3.new(1, 1, 1)
    origin.Anchored = true
    origin.Transparency = 1
    origin.CanCollide = false
    origin.CanQuery = false
    origin.CanTouch = false
    origin.Parent = model
    model.PrimaryPart = origin
    for _, d in ipairs(Geometry) do
        local p = Instance.new("Part")
        p.Name = d.name
        p.Size = Vector3.new(d.size[1], d.size[2], d.size[3])
        local m = d.matrix
        p.CFrame = CFrame.new(d.pos[1], d.pos[2], d.pos[3], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8], m[9])
        if d.shape == "CylinderY" then
            p.Shape = Enum.PartType.Cylinder
            p.Size = Vector3.new(d.size[2], d.size[1], d.size[3])
            p.CFrame = p.CFrame * CFrame.Angles(0, 0, math.pi / 2)
        end
        p.Color = Color3.fromRGB(d.color[1], d.color[2], d.color[3])
        p.Material = Enum.Material[d.material]
        p.Transparency = d.alpha
        p.Anchored = true
        p.CanCollide = d.solid
        p.CanQuery = d.solid
        p.CanTouch = false
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = model
        if d.text then
            local gui = Instance.new("SurfaceGui")
            gui.Name = "Sign"
            gui.Face = Enum.NormalId.Front
            gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
            gui.PixelsPerStud = 30
            gui.LightInfluence = 0
            gui.MaxDistance = 600
            gui.Parent = p
            local text = Instance.new("TextLabel")
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.TextScaled = true
            text.Font = Enum.Font.SciFi
            text.TextColor3 = Color3.fromRGB(d.textColor[1], d.textColor[2], d.textColor[3])
            text.Text = d.text
            text.Parent = gui
        end
    end
    model:SetAttribute("VisiblePartCount", #Geometry)
    model:SetAttribute("VisiblePartBudget", Spec.PerformanceBudget.MaxVisibleParts)
    model:SetAttribute("QualityGateB", "Pending")
    model:SetAttribute("QualityGateC", "Pending")
    model:SetAttribute("ReviewCandidate", true)
    model:ScaleTo(scale)
    model:PivotTo(options.GroundCFrame or CFrame.new())
    model.Parent = parent
    local api
    if game:GetService("RunService"):IsRunning() then
        api = Runtime.Attach(model, Spec, options)
    else
        -- Save a real bootstrap in the edit-mode model so Play has live handlers.
        local bootstrap = script.Parent.MegaCityHarborBootstrap:Clone()
        bootstrap.Name = "HarborRuntime"
        bootstrap:SetAttribute("Effects", options.Effects ~= false)
        bootstrap:SetAttribute("MaxHealth", options.MaxHealth or Spec.MaxHealth)
        bootstrap.Parent = model
        model:SetAttribute("AssetId", Spec.AssetId)
        model:SetAttribute("EnergyType", Spec.EnergyType)
        model:SetAttribute("MaxHealth", options.MaxHealth or Spec.MaxHealth)
        model:SetAttribute("Health", options.MaxHealth or Spec.MaxHealth)
        model:SetAttribute("Destroyed", false)
        game:GetService("CollectionService"):AddTag(model, "KaijuHouse")
    end
    return model, api
end
return Installer
