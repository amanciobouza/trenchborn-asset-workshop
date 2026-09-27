# Police HQ Phase 6

Nutzerfreigaben: P4 nach Fassadenkorrektur bestätigt, P5 nach Schüsselkorrektur bestätigt. Am 27.09.2026 wurden 32'000 HP, Electric-Energie und ein gemeinsamer Gebäudeeinsturz mit „ok“ freigegeben.

## Integration

`LargeCityPoliceInstaller.Attach(model)` integriert den freigegebenen P5-Bau:

- Modell `LargeCity_PoliceHQ_L3`, Plot LC-35, CityTier4.
- `KaijuHouse`-Tag, `MaxHealth=32000`, `EnergyType="Electric"`.
- Genau ein Folder `D1_WholeBuilding` unter `DestructionGroups`. 584 sichtbare Parts einschliesslich Antenne, Leuchten, Wappen, Schranke, Poller, Zaun und Pflanzen werden gemeinsam zugeordnet. Der unsichtbare GroundPivot bleibt separat am Modell.
- Keine Bauteil-HP, keine gestaffelten Einsturzgruppen. `DestructionMode="WholeBuilding"` dokumentiert das gewünschte Verhalten.
- Lichter und SurfaceGuis bleiben Kinder ihrer Trägerparts. Keine Position, Rotation, Grösse oder Material wird bei der Umordnung geändert.
- Alle Zuordnungen werden vor der Umordnung geprüft. Unbekannte Quellgruppen oder doppelte Partnamen brechen frühzeitig ab. Der Tag wird erst nach vollständiger Metadaten-/Gruppenerstellung gesetzt.
- Wiederholtes Attach validiert das Modell und lässt eine vorhandene aktuelle Health unangetastet.

Der Installer folgt dem bestehenden Tag-/Attribut-/Gruppenvertrag der Feuerwache. Der eigentliche Schaden, Einsturz und Energiegewinn müssen vom gemeinsamen Hauptspielsystem kommen. Dieser Branch enthält keine eigene Schadensschleife oder Reward-Auszahlung.

## Prüfung und Grenzen

Ein Lua5.4-Test lädt die tatsächliche P5-XML-Hierarchie in ein einfaches Roblox-Hierarchie-Testmodell und führt den unveränderten Installer aus. Bestanden: Erhalt aller585 Parts, genau eine Gruppe mit584Parts, zwölf Leuchten und zwei SurfaceGuis korrekt unter Trägerparts, Health bleibt123 nach zweitem Attach, unbekannte Geometrie wird vor Mutation abgelehnt. Entfernen der Gesamtgruppe auf einer unparenteten Kopie hinterlässt keine Gruppenteile; das Original bleibt unberührt.

```sh
python3 tools/check_police_contract.py > /tmp/police-test.lua
lua /tmp/police-test.lua
```

`TestGroupCleanup` läuft auch beim Preview-Start in Studio auf einer Kopie. Erwarteter Output: `1/1 group cleanup checks passed`. Das ist ein Hierarchie-/Cleanup-Test, kein Nachweis des echten Kampf- oder Physiksystems.

Noch offen im Hauptspiel: Zielerkennung, Schaden durch Angriffe, gemeinsamer Einsturz, einmalige Energieausgabe, keine zurückbleibenden sichtbaren Teile, Kollisionen und Performance. Daher `QualityGateC="Pending"`, `Phase6Status="ExternalGameTestPending"`, `FinalInstallerReady=false`.

## Eigenständiges Quellpaket

`dist/LargeCityPolicePackage.rbxmx` enthält vier ModuleScripts und keine automatisch laufenden Scripts. Als Folder in Workspace importieren, dann in der Studio-Command-Bar ausführen:

```lua
require(workspace.LargeCityPolicePackage.LargeCityPoliceInstaller).Install(workspace)
```

Optionale Platzierung: `Install(workspace, {GroundCFrame=CFrame.new(...)})`. Pivot ist Grundstücksmitte bei Boden-Y0, Front lokal-Z. Die endgültige Platzierung in der Stadt folgt später. Vorhandene gleichnamige Modelle werden nicht überschrieben.

Paket aus `python3 tools/build_police_package.py` erzeugt und per XML-Roundtrip geprüft: vier vollständige Quellen, keine autorun Scripts. Import dieses P6-Pakets in ein separates Studio-Projekt ist noch offen. P4/P5-Direktexporte bleiben visuelle Archive ohne Gameplay-Integration.
