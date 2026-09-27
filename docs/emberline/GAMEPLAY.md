# Emberline - Phase 6

P5 wurde im Gespräch am 27.09.2026 mit „passt“ bestätigt. Danach wurden **32'000 MaxHealth und Thermal** ausdrücklich mit „ok“ freigegeben.

## Integration

`LargeCityEmberlineInstaller` setzt den Tag `KaijuHouse`, numerisches `MaxHealth=32000`, `EnergyType="Thermal"`, CityTier 4 und die vorhandenen Integrations-/Qualitätsattribute entsprechend dem Central-Hospital-Installer. Aktueller Modellname: `LargeCity_EmberlineResponseHQ_L3`.

Es gibt sechs echte Folder unter `DestructionGroups`. Alle 350 sichtbaren Parts liegen direkt in genau einem Folder. Der unsichtbare GroundPivot bleibt am Modell.

| Gruppe | Inhalt / mitgehörige Details |
| --- | --- |
| D1_VehicleBayDoors | Vier Tore mit Fensterbändern und Fugen |
| D2_VehicleHall | Halle, Namensschild, Hallensymbol, Hallen-Dachtechnik, Hallenleuchten und Warnleuchten |
| D3_Administration | Verwaltung, Eingang und Vordach, Verwaltungssymbol, eigene Dachtechnik und Eingangsleuchten |
| D4_TrainingTower | Turm, alle sechs Ebenen, Geländer, Symbol, Antenne und zugehörige Leuchten |
| D5_Forecourt | Grundstücksplatte, Vorplatz, Markierungen und Poller |
| D6_ServiceAndLandscape | Technikschrank, Zaun und Pflanztröge samt Pflanzen |

Schilder und Leuchten bleiben Kinder ihres jeweiligen Parts. Es gibt keinen separaten Dekorationsordner, der beim Entfernen eines tragenden Gebäudeteils in der Luft stehen bleibt. Vor der Umordnung werden alle Parts geprüft; unbekannte Ergänzungen führen zu einem Fehler vor der Mutation. Wiederholtes Attach validiert nur und setzt keine aktuelle Health zurück.

## Was hier getestet wurde

Ein Lua-5.4-Test mit einem ausdrücklich vereinfachten Roblox-Objektmodell lädt die echte P5-XML-Hierarchie und führt den unveränderten Installer-Code aus. Bestanden: Erhalt aller 351 Parts, sechs Gruppen, richtige Eigentümer für zwölf Leuchten/vier SurfaceGuis, unveränderte Health bei erneutem Attach, frühzeitige Ablehnung unbekannter Parts, vollständige Löschung jeder Gruppe auf separaten Testkopien. Dies prüft Logik und Hierarchie, **nicht** die Roblox-Engine.

Reproduktion bei installiertem Lua 5.4:

```sh
python3 tools/check_emberline_contract.py > /tmp/emberline-test.lua
lua /tmp/emberline-test.lua
```

In Studio führt der Workshop beim Play-Start zusätzlich `TestGroupCleanup` auf unparenteten Kopien aus. Der sichtbare Originalbau bleibt erhalten. Output soll `6/6 group cleanup checks passed` melden.

## Standalone-Paket

`dist/LargeCityEmberlinePackage.rbxmx` enthält vier ModuleScripts und keine automatisch laufenden Scripts. Als Folder `LargeCityEmberlinePackage` in Workspace importieren. Dann bewusst in der Studio-Command-Bar ausführen:

```lua
require(workspace.LargeCityEmberlinePackage.LargeCityEmberlineInstaller).Install(workspace)
```

Für eine andere Position `Install(workspace, {GroundCFrame=CFrame.new(...)})` verwenden. Die aktuelle Stadtposition wird hier noch nicht automatisch gesetzt. Bei bereits vorhandenem gleichnamigem Gebäude wird die Installation abgelehnt statt das vorhandene Gebäude zu löschen.

## Gate C bleibt offen

Der Adapter verwendet den beobachteten Tag-/Attribut-/Folder-Vertrag vorhandener Gebäude. Der tatsächliche Hauptspiel-Schadens- und Einsturzcode ist im geprüften Workshop/Integration-Branch nicht enthalten. Deshalb gibt es hier keinen erfundenen parallelen Health-, Reward- oder Einsturzmechanismus und noch keinen Nachweis, wie die Hauptspiel-Engine die Gruppen verarbeitet.

Im Hauptspiel prüfen:

- [ ] Tag registriert das Gebäude als Ziel; 32'000 HP und Thermal werden erkannt.
- [ ] Alle vorhandenen Angriffe verringern Gesundheit über das gemeinsame System.
- [ ] Zerstörung und Energieausgabe laufen genau einmal über dieses System.
- [ ] Schilder, Warn-/Wandleuchten, Dachgeräte und Pflanzen werden mit ihren Bauteilen entfernt.
- [ ] Kollisionen, Geländeauflage, mobile Lesbarkeit und Performance sind passend.
- [ ] Gate C nach diesen Tests bestätigen; erst dann P7 als final freigeben.

`QualityGateC="Pending"`, `Phase6Status="ExternalGameTestPending"`, `FinalInstallerReady=false` bleiben bewusst bestehen. Die alten P4/P5-Direktmodelle sind historische visuelle Exporte; das P6-Paket installiert die integrierte Version.
