-- Office P5. Approved P4 geometry is preserved; additions use its ground pivot.
local Dressing = {}
function Dressing.Apply(model)
    assert(model and model.PrimaryPart, "Office model with GroundPivot required")
    local previous = model:FindFirstChild("OfficeDressing")
    if previous then previous:Destroy() end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "GroundPivot" then
            p.Material = Enum.Material.Metal
            p.Reflectance = 0
            p.Transparency = 0
            if string.find(p.Name, "Glass") or string.match(p.Name, "^Door%d") then
                p.Material = Enum.Material.Glass
                p.Color = Color3.fromRGB(54, 97, 125)
                p.Reflectance = 0.12
                -- Opaque architectural glass avoids seeing the unfinished interior.
            elseif string.match(p.Parent.Name, "^Podium") then
                p.Material = Enum.Material.Slate
            elseif p.Parent.Name == "Site" or p.Name == "Threshold" then
                p.Material = Enum.Material.Concrete
            end
        end
    end
    local group = Instance.new("Model")
    group.Name = "OfficeDressing"
    group.Parent = model
    local origin = model:GetPivot()
    local function part(name, size, cf, color, material)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.CFrame = origin * cf
        p.Color = color
        p.Material = material
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = group
        return p
    end
    local wood = Color3.fromRGB(132, 96, 62)
    local dark = Color3.fromRGB(58, 70, 79)
    local function palm(id, x, z, h)
        part(id.."Trunk", Vector3.new(1.4,h,1.4), CFrame.new(x,2+h/2,z), wood, Enum.Material.Wood)
        -- Eight fronds, two tapered segments per frond; broad tropical silhouette.
        for k = 0, 7 do
            local radial = CFrame.new(x,2+h,z) * CFrame.Angles(0,k*math.pi/4,0)
            part(id.."Frond"..k.."Inner",Vector3.new(1.7,.35,4.2),radial*CFrame.new(0,.5,-1.9)*CFrame.Angles(.23,0,0),Color3.fromRGB(64,112,64),Enum.Material.Grass)
            part(id.."Frond"..k.."Tip",Vector3.new(.95,.25,3.4),radial*CFrame.new(0,.1,-5.3)*CFrame.Angles(-.5,0,0),Color3.fromRGB(79,130,69),Enum.Material.Grass)
        end
    end
    for i, v in ipairs({{-45,-53,23},{45,-53,26},{-62,-14,22},{-62,14,26},{61,48,23}}) do
        palm("Palm"..i,v[1],v[2],v[3])
    end
    for i, v in ipairs({{-41,-53,28,6},{41,-53,28,6},{-62,0,6,44},{61,48,16,6}}) do
        part("Soil"..i,Vector3.new(v[3],.5,v[4]),CFrame.new(v[1],1.3,v[2]),Color3.fromRGB(73,66,48),Enum.Material.Ground)
    end
    -- Benches sit behind front planters, leaving the central entrance clear.
    for i, x in ipairs({-39,39}) do
        for k=0,2 do
            part("Bench"..i.."Slat"..k,Vector3.new(12,.45,.7),CFrame.new(x,2.4,-47+k*.85),wood,Enum.Material.Wood)
        end
        part("Bench"..i.."Back",Vector3.new(12,2,.4),CFrame.new(x,3.7,-47.5),wood,Enum.Material.Wood)
        for j, dx in ipairs({-4.5,4.5}) do
            part("Bench"..i.."Leg"..j,Vector3.new(.6,2.2,2.6),CFrame.new(x+dx,1.1,-46.2),dark,Enum.Material.Metal)
        end
    end
    local function light(name, x,y,z,range,brightness)
        local p = part(name,Vector3.new(1.2,.25,1.2),CFrame.new(x,y,z),Color3.fromRGB(255,223,172),Enum.Material.Neon)
        local l = Instance.new("PointLight")
        l.Name = "WarmLight"
        l.Color = p.Color
        l.Range = range
        l.Brightness = brightness
        l.Shadows = false
        l.Parent = p
    end
    for i,x in ipairs({-12,0,12}) do light("CanopyLight"..i,x,17.85,-39,16,.7) end
    for i,v in ipairs({{-24,-58},{24,-58},{-66,32},{66,-8}}) do
        part("Bollard"..i,Vector3.new(1,3.5,1),CFrame.new(v[1],1.75,v[2]),dark,Enum.Material.Metal)
        light("BollardLight"..i,v[1],3.7,v[2],12,.5)
    end
    light("DeliveryLight",55,15.85,22,12,.5)
    model.Name = "LargeCity_OfficeTower_P5"
    model:SetAttribute("Phase",5)
    model:SetAttribute("QualityGateB","Approved")
    model:SetAttribute("DressingReview","Pending")
    model:SetAttribute("BuildRevision","Office-P5-v1")
    return model
end
return Dressing
