# Trenchborn Fire Station Kit v1

Reusable modular fire-station building kit derived from the Large City fire-station family.

## Branch

`building-kit-fire-station-v1`

The original `largecity-technology-fire-station-l3` branch remains unchanged.

## Standard

- Kit ID: `TBK_FS`
- Grid: 16 studs
- Core is separate from facades, entrances, roof, props and signage.
- Every module is a Model with a `GroundPivot` PrimaryPart on its lower-left grid origin.
- Modules build into +X/+Z and support 0/90/180/270 degree placement.
- Examples are composed only from kit modules.

## Included examples

- `TBK_FS_Example_Small`: office + 1 apparatus bay
- `TBK_FS_Example_Standard`: office + 2 apparatus bays
- `TBK_FS_Example_Large`: office + 3 apparatus bays + training tower

## Build the import package

```powershell
.\tools\build-fire-station-kit-package.ps1
```

Output:

```text
dist/FireStationKit.rbxmx
```

## Runtime usage

Require `FireStationKitInstaller` and call:

```lua
local kit = FireStationKitInstaller.Install(ReplicatedStorage.TrenchbornAssetWorkshop)
```

Individual modules can then be cloned with `FireStationKitInstaller.CloneModule`.
