# Trenchborn Asset Workshop

Synchronized Roblox Studio workspace for specification-driven Trenchborn asset development and automated quality gates.

## Bound Chimera Quality Gate B review

The workshop bootstrap runs a non-destructive deterministic geometry review for
`Kaiju-I Bound Chimera`. `AssetValidator` checks identity, anatomy, budgets,
ground contact, arm clearance, and rig connectivity. Findings are printed as
text and JSON, exposed through `QualityGateBReview*` attributes, and affected
parts are highlighted red (blocker) or amber (warning) in Studio.

`PASS_DETERMINISTIC` does not approve Quality Gate B. The visual criteria in
`KaijuAwakenedReviewProfile` still require the standard-view image review, and
only the user may change `QualityGateB` to `Approved`.

### Automatic Studio review agent

The optional local bridge removes manual Output copying and screenshot work.
It uses Python 3 with Pillow for window capture. Install it once:

```powershell
.\tools\install-review-agent.ps1
codex login
.\tools\start-review-agent.ps1
```

Restart Studio, enable **Game Settings > Security > Allow HTTP Requests**, and
press **Plugins > Trenchborn > Review Agent** while the Golden Master exists.
The plugin runs the deterministic checks, frames five standard camera views,
and asks the local bridge to capture and visually review them. Results return
to the Studio dock widget and are saved under `reviews/` locally. No API key is
required: the agent invokes `codex exec` using the cached ChatGPT login.

If Studio chrome should be cropped from captures, set
`TRENCHBORN_CAPTURE_INSET` to `left,top,right,bottom` pixel values before
starting the agent. `TRENCHBORN_REVIEW_MODEL` optionally selects a Codex model;
when unset, Codex uses the account's configured default.

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
