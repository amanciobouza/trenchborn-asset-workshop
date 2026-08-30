# Trenchborn Asset Workshop

Synchronized Roblox Studio workspace for specification-driven Trenchborn asset development and automated quality gates.

## Warden-I Shepherd final installer

`WardenShepherdInstaller` is the Phase 7 installation API. It installs the approved geometry,
dressing, gameplay contract, and visual reactions without the workshop test console.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(packageFolder:WaitForChild("WardenShepherdInstaller"))

local warden, gameplayApi = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
	EnableVisualReactions = true,
})
```

`GroundCFrame` is the desired ground position and orientation beneath the Warden. The installer
applies the approved root-height offset automatically.
