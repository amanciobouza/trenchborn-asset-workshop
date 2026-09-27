# Courthouse — P6 / Issue #8

Ein Gerichtsgebäude für LC-34, kein Kit. Gate A und P3 freigegeben; P4/Gate B inklusive geschlossener Gebäudeanschlüsse vom Benutzer freigegeben; P5-Dressing inklusive Leuchtenkorrektur und P6-Werte vom Benutzer freigegeben.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-courthouse-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist unverändert vom Hotel-Branch übernommen. Falls kein Server läuft: `rojo serve default.project.json`, dann Studio verbinden. Spätere Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace: `LargeCity_Courthouse_L3`. Grundstückspivot Y0, Front lokal -Z. Endgültige Stadtplatzierung folgt später.

## Geometrie

Grundstück 192×144; Vorplatz Y0, Plateau Y8. Mittelbau 64×80×72 bis Y80, Seitenflügel je48×72×60 bis Y68. Drei Geschosse. Alle Dachgesimse sind in den Höhen enthalten. Vorhalle 64×20×48 bis Y56. Genau sechs runde Säulen mit maximal6Studs Durchmesser und40Studs Gesamthöhe: Basis3 + Schaft34 + Kapitell3. Schaftdurchmesser5.

Freitreppe 72×24×8 mit16 Stufen à0.5 Höhe und1.5 Tiefe. Seitliche Rampe rechts:48Studs Lauf,8Studs lichte Breite, Steigung1:6. Verlauf von X84/Y0 zu X36/Y8, Z=-38..-30. Ein4Studs langes Podest schliesst lückenlos an die Vorhalle bei X32 an. Geländer liegen ausserhalb der lichten Breite. Spielbarkeit von Rampe, Treppe und Säulenzwischenräumen muss in Studio geprüft werden.

Heller Stein, dunkle Fenster und Rahmen als Grundfarben. P5 ergänzt ein geometrisches Waage-Symbol, den COURTHOUSE-Schriftzug, Rampen-/Treppengeländer, fünf warme Lampen, zwei Bänke, zwei kleine Palmen, Sträucher und vier blaue Fahnen. Keine eingerichteten Gerichtssäle. 32’000 HP, Electric und eine gemeinsame Ganzgebäude-Zerstörungsgruppe D1_WholeBuilding.

## Export / Nachweise

`dist/LargeCityCourthouse_P4.rbxmx`: statisches Geometriemodell, keine automatisch laufenden Scripts. Alternativ zur Rojo-Vorschau importieren.

`python3 tools/build_courthouse.py --preview` reproduziert Lua, XML, Massbericht und sechs technische Ansichten. Vorschau benötigt Pillow/NumPy. Ansichten sind keine Studio-Screenshots. Prüfungen: Parzellengrenzen, sechs Säulen, Höhenbezüge, Stufen, Rampenfreiraum und Anschluss, XML-Teilzahl. Lua-5.4-Modulprüfung bestanden. Roblox-Runtime, Bewegung, Performance und Kollaps bleiben ungeprüft; Gate C im Hauptspiel offen. Das statische P4-XML bleibt ein Geometriearchiv; P6 wird durch den Installer in der Rojo-Vorschau erzeugt.

Spezifikation/Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/8

## Eigenständiger Import

`dist/LargeCityCourthousePackage.rbxmx` in Workspace importieren. Das Paket enthält vier ModuleScripts und startet nichts automatisch. In der Studio Command Bar ausführen:

```lua
require(workspace.LargeCityCourthousePackage.LargeCityCourthouseInstaller).Install(workspace)
```

Optional `Install(workspace, {GroundCFrame=CFrame.new(x,y,z)})`. Bodenpivot liegt auf Vorplatzhöhe Y0; Plateau +8, Front lokal -Z. Vorhandene gleichnamige Modelle werden nicht überschrieben.

Installer setzt KaijuHouse, MaxHealth=32000 und EnergyType="Electric". Alle sichtbaren Teile, fünf Lampen und der Schriftzug gehören zu D1_WholeBuilding. Erneutes Attach erhält Health. Schaden, Energieauszahlung und tatsächlichen Kollaps übernimmt das gemeinsame Hauptspiel-System.

Strukturprüfung mit Lua-5.4-Hierarchiemock der tatsächlichen Module:1164 BaseParts inklusive Pivot,1163 sichtbare Teile in einer Gruppe, fünf Lichter und eine Schriftfläche. Health-Erhalt, keine Dressing-Duplikate, Ablehnung unbekannter Teile vor Umbau und vollständige Gruppenbereinigung auf Kopien geprüft. Kein Roblox-Physik-, Bewegungs- oder Performancetest. Standalone-Import und Gate C bleiben offen.

Paket reproduzieren: `python3 tools/build_courthouse_package.py`. Vertragsprüfung: `python3 tools/check_courthouse_contract.py > courthouse-test.lua`, danach `lua courthouse-test.lua` (Lua5.4).
