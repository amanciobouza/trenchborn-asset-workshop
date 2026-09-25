local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local workshop = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(workshop:WaitForChild("FireStationKitInstaller"))

local kit = installer.Install(workshop)

local root = Workspace:FindFirstChild("TrenchbornAssetWorkshop")
if not root then
	root = Instance.new("Folder")
	root.Name = "TrenchbornAssetWorkshop"
	root.Parent = Workspace
end

local previous = root:FindFirstChild("FireStationKitPreview")
if previous then
	previous:Destroy()
end

local preview = Instance.new("Folder")
preview.Name = "FireStationKitPreview"
preview.Parent = root

local examples = kit:WaitForChild("Examples")
local layout = {
	TBK_FS_Example_Small = CFrame.new(-55, 0, 0),
	TBK_FS_Example_Standard = CFrame.new(0, 0, 0),
	TBK_FS_Example_Large = CFrame.new(65, 0, 0),
}

for name, cf in pairs(layout) do
	local source = examples:FindFirstChild(name)
	if source then
		local clone = source:Clone()
		clone.Parent = preview
		clone:PivotTo(cf)
	end
end

preview:SetAttribute("KitId", installer.KitId)
preview:SetAttribute("KitVersion", installer.Version)
preview:SetAttribute("Preview", true)
