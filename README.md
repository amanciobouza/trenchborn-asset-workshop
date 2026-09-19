# Trenchborn Asset Workshop

Synchronized Roblox Studio workspace for specification-driven Trenchborn asset development and automated quality gates.

## Large City Uptown Arena integration package

The Uptown Arena can be imported into another Roblox project without workshop preview or bootstrap scripts. The package contains its Specification, Golden Master, Dressing, and Installer modules.

Build the Studio-importable package with Rojo:

```powershell
.\tools\build-largecity-uptown-arena-package.ps1
```

This creates `dist/LargeCityUptownArenaPackage.rbxmx`. Insert that model into `ReplicatedStorage` in the target place, then call the installer from a server script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("LargeCityUptownArenaPackage")
local installer = require(packageFolder:WaitForChild("LargeCityUptownArenaInstaller"))

local arena = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
})
```

`GroundCFrame` identifies the desired ground position and orientation. The installer builds the approved geometry and dressing, aligns the lowest visible part to the requested ground height, validates all seven destruction groups, sets `MaxHealth` to `64000`, sets `EnergyType` to `Electric`, and adds the `KaijuHouse` tag. Calling `Install` again replaces the previous installation; `installer.Uninstall(parent)` removes it.

This is a Phase 6 integration package. It is ready for use by the target project's shared damage and collapse system, but Quality Gate C remains pending until that external gameplay test passes. It must not be treated as the final Phase 7 release yet.

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


## Aegis-III Interceptor final installer

`AegisInterceptorInstaller` installs the approved Phase 7 Aegis-III geometry, dressing, fleet rig, gameplay, production animations, combat VFX, spatial sounds, and targeted missile warning audio. Workshop HUDs and test targets are not included.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(packageFolder:WaitForChild("AegisInterceptorInstaller"))

local aegis, api = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
	AnchorRoot = true,
})

api.RequestAbility:Invoke("TwinIonCannons", workspace.TargetPart)
api.RequestAbility:Invoke("ShoulderMissiles", workspace.TargetPart)
api.RequestAbility:Invoke("DirectionalAegis")
api.ApplyDamage:Invoke(5000, workspace.DamageSource)
```

The installed gameplay contract exposes 18,000 health, 150,000 shield points, directional frontal damage reduction, independent ability cooldowns, reset support, and explicit runtime cleanup through `api.Runtime.Destroy()`.

## Sovereign-V Apex final installer

`SovereignApexInstaller` installs the approved Sovereign-V geometry, dressing, fleet rig, gameplay contract, production animations, wing inertia, Apex Lance, Hunter Drones, Sovereign Lock, VFX, and spatial sound pass. It does not install the workshop HUD or test target.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local installer = require(packageFolder:WaitForChild("SovereignApexInstaller"))

local sovereign, api = installer.Install(workspace, {
	GroundCFrame = CFrame.new(0, 0, 0),
	AnchorRoot = true,
})

api.RequestAbility:Invoke("ApexLanceBeam", workspace.Kaiju)
```
