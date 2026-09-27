# Residential Tower — Phase 6

Am27.09.2026 wurden P5 und anschliessend 64'000 HP / Electric-Energie / ein gemeinsamer Einsturz mit „passt“ freigegeben.

## Gebäudeintegration

`LargeCityResidentialInstaller` setzt `KaijuHouse`, `MaxHealth=64000`, `EnergyType="Electric"`, LC-14 und CityTier4. Das integrierte Modell heisst `LargeCity_ResidentialTower_L3`.

Alle1221 sichtbaren Parts liegen in genau einem Folder `DestructionGroups.D1_WholeBuilding`. Der unsichtbare GroundPivot bleibt separat am Modell. Balkone, Pflanzen, Geländer, Dachtechnik, Grundstück und Garagenzufahrt gehören gemeinsam dazu. Keine getrennten Bauteil-HP. Acht Leuchten bleiben Kinder ihrer jeweiligen Trägerparts.

Vor der Umordnung werden alle Quellgruppen und Partnamen geprüft. Unbekannte Gruppen oder doppelte Namen werden vor Mutation abgelehnt. Der Tag wird erst nach vollständiger Einrichtung gesetzt. Wiederholtes Attach validiert nur und setzt aktuelle Health nicht zurück. Positionen, Rotationen, Grössen, Materialien und Transparenzen bleiben erhalten.

Keine eigene Schadensschleife, keine Reward-Auszahlung oder separate Einsturzsimulation. Die gemeinsame Hauptspiel-Engine muss Schaden, Gesamteinsturz und Energiegewinn ausführen. `DestructionMode="WholeBuilding"` dokumentiert dieses Verhalten.

## Prüfungen

Tatsächliche P5-XML-Hierarchie in einem einfachen Lua5.4-Roblox-Hierarchiemodell geladen; unveränderten Installer ausgeführt. Bestanden:1222 Parts bleiben erhalten, genau eine Gruppe mit1221 sichtbaren Parts, acht Leuchten korrekt zugeordnet, Health123 bei erneutem Attach unverändert, unbekannte Ergänzung vor Mutation abgelehnt. Entfernen der Gesamtgruppe auf einer unparenteten Kopie hinterlässt keine Gruppenteile und verändert das Original nicht.

```sh
python3 tools/check_residential_contract.py > /tmp/residential-test.lua
lua /tmp/residential-test.lua
```

Preview führt denselben strukturellen Cleanup-Test auf einer Kopie aus. Output: `1/1 group cleanup checks passed`. Das ist kein Roblox-Physik- oder Hauptspiel-Kampftest.

Gate C bleibt Pending. Noch im Hauptspiel zu prüfen: Zielerkennung, Schaden durch Angriffe, gemeinsamer Einsturz, einmalige Energieausgabe, vollständige Entfernung aller Anbauteile, Rampenkollisionen und Performance. `Phase6Status="ExternalGameTestPending"`, `FinalInstallerReady=false`.

## Eigenständig importierbares Quellpaket

`dist/LargeCityResidentialPackage.rbxmx` enthält vier vollständige ModuleScripts, keine automatisch laufenden Scripts. Als Folder in Workspace importieren, dann Studio-Command-Bar:

```lua
require(workspace.LargeCityResidentialPackage.LargeCityResidentialInstaller).Install(workspace)
```

Optionale Platzierung: `Install(workspace, {GroundCFrame=CFrame.new(0,12,0)})`. Vorhandene gleichnamige Modelle werden nicht überschrieben. GroundCFrame bezieht sich auf GrundstücksbodenY0, nicht auf den tiefsten Teil der Rampe. Der Workshop behält die erhöhte Ansicht beiY12.

Für die endgültige Stadtplatzierung bleibt die Geländeöffnung im lokalen Bereich X44..62 / Z-48..16 / Y-9..0 notwendig. `GarageRequiresTerrainCut=true`. Der Installer löscht kein fremdes Gelände und hebt den Bau nicht automatisch nach BoundingBox an.

`python3 tools/build_residential_package.py` erzeugt das Paket. XML-Roundtrip mit vier unverändert eingebetteten Quellen und ohne autorun Scripts bestanden. Praktischer P6-Standalone-Import noch offen; P4/P5-Direktexporte sind visuelle Archive ohne Gameplay-Integration. Die Rojo-Ordnerzuordnung bleibt unverändert.
