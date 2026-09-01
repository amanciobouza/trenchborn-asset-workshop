# Trenchborn Asset Workshop

Synchronized Roblox Studio workspace for specification-driven Trenchborn asset development and automated quality gates.

## Marshal-II Roadblock final installer

`MarshalRoadblockInstaller` is the Phase 7 production API. It installs the approved model, dressing, fleet rig, gameplay, animations, combat VFX, and spatial sound pass. It does not install the workshop HUD, test buttons, or test targets.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(packageFolder:WaitForChild("MarshalRoadblockInstaller"))

local marshal, api = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
	AnchorRoot = true,
})

api.RequestAbility:Invoke("RiotShield")
api.RequestAbility:Invoke("PulseCannon", workspace.TargetPart)
api.RequestAbility:Invoke("ContainmentNet", workspace.TargetPart)
api.ApplyDamage:Invoke(500, true)
api.Runtime.PlayAnimation("Walk")
```

`GroundCFrame` is the desired ground position and orientation beneath the Guardian. The installer computes the correct vertical placement from the finished geometry. `AnchorRoot` defaults to `true`, which supports server-controlled movement through `Model:PivotTo()`; set it to `false` only when an external character controller supplies collision and physics.

Call `api.Runtime.Destroy()` before removing a live installation so its per-player animation bridge is cleaned up.

## Warden-I Shepherd final installer

`WardenShepherdInstaller` installs the approved Warden geometry, dressing, gameplay contract, and visual reactions without the workshop test console.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(packageFolder:WaitForChild("WardenShepherdInstaller"))

local warden, gameplayApi = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
	EnableVisualReactions = true,
})
```
