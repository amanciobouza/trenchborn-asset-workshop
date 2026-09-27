# City Hotel — P6 / Issue #7

Ein Stadthotel für LC-16: zwölf Geschosse, warmer heller Stein, regelmässige Zimmerfenster und vorspringender Mittelteil. Gate A/P3 freigegeben; P4/Gate B vom Benutzer freigegeben; P5-Dressing und P6-Werte vom Benutzer freigegeben. Bestehendes Stadium Hotel und Waterfront Resort sind separate Assets.

## Studio-Vorschau

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-city-hotel-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist unverändert vom Office-Branch übernommen. Bei noch nicht laufendem Server: `rojo serve default.project.json`, dann Studio verbinden. Spätere Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace-Modell: `LargeCity_CityHotel_L3`. Bodenpivot ist Grundstücksmitte Y=0, Front lokal -Z. Gebäudemitte liegt lokal bei Z=12, um Platz für die Vorfahrt zu schaffen. Die endgültige Stadtplatzierung folgt später.

## Masse und Ausführung

Sockel 128×80×36, zwei Geschosse à18. Zimmerbau 120×72×160, zehn Geschosse à16. Mittelteil 24 breit und 6 vorspringend, je Geschoss segmentiert. Dachgesims 128×80×8 bis Y204; Mittelabschluss maximal Y208. Vordach 72×28×6, Unterkante Y20. Grundstück 176×144.

Vier Säulen begrenzen die Vorfahrt; der durchgehende Fahrstreifen Z=-52 bis -32 bleibt von Y0 bis Y20 frei. Pflanzeninseln liegen ausserhalb dieses Streifens. Separater Lieferzugang links. Reale Fensteröffnungen mit zwei Scheiben pro Fenster, voneinander getrennten Rahmen und Mittelpfosten. Zimmer bleiben unmöbliert.

P5 ergänzt fünf vertikale HOTEL-Buchstaben, warme Gesimsstreifen, zwölf PointLights, transparente Sockelverglasung, einfache Lobby-/Restaurant-Einrichtung auf beiden Sockelebenen, vier Palmen und bepflanzte Inseln. Die Leuchten am Vordach liegen oberhalb Y20. Die globale Beleuchtung bleibt unverändert. 64’000 HP, Electric und eine gemeinsame Zerstörungsgruppe D1_WholeBuilding.

## Export und Prüfungen

`dist/LargeCityHotel_P4.rbxmx` ist das statische P4-Modell ohne automatisch laufende Scripts. Alternativ zur Rojo-Vorschau importieren, nicht gleichzeitig am selben Ort.

`python3 tools/build_hotel.py --preview` reproduziert Luau, XML, Massbericht und sechs technische Ansichten (Preview benötigt Pillow/NumPy). Nachweise in docs/hotel. Die Bilder sind technische Renderings ausserhalb Studio. Geprüft werden Hauptmasse, Höhen, Fenster-/Wandvolumen, Parzellengrenzen und freie Vorfahrt sowie XML-Teilzahl. Roblox-Laufzeit, Performance und Kollaps noch nicht getestet. Gate C im Hauptspiel bleibt offen. Das statische P4-XML bleibt ein Geometriearchiv; die aktuelle P6-Version wird über die Rojo-Vorschau erzeugt.

Verbindliche Spezifikation und Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/7

## Eigenständiger Import

`dist/LargeCityHotelPackage.rbxmx` in Workspace importieren. Es enthält vier ModuleScripts und startet nichts automatisch. In der Studio Command Bar ausführen:

```lua
require(workspace.LargeCityHotelPackage.LargeCityHotelInstaller).Install(workspace)
```

Optional `Install(workspace, {GroundCFrame=CFrame.new(x,y,z)})`. Bodenpivot = Grundstücksmitte, Front lokal -Z. Bestehende gleichnamige Gebäude werden nicht überschrieben.

Installer setzt KaijuHouse, MaxHealth=64000, EnergyType="Electric" und einen gemeinsamen Besitzer für alle sichtbaren Teile, Lampen und Schriftzüge. Erneutes Attach setzt Health nicht zurück. Schaden, Energieauszahlung und Kollaps übernimmt das bestehende Hauptspiel-System. Es wird kein zweites Gameplay-System gestartet.

Prüfung mit Lua-5.4-Hierarchiemock: tatsächliche Builder/Dressing/Installer-Module; 3480 BaseParts inklusive Pivot, 3479 Teile in einer Gruppe, zwölf Lichter und fünf Schriftflächen. Getestet: wiederholte Anwendung ohne Duplikate, Health-Erhalt, Ablehnung unbekannter Teile vor Umbau und vollständige Gruppenbereinigung auf Kopien. Keine Roblox-Physik oder Performance getestet. Studio-Import und Hauptspieltest bleiben offen.

Paket reproduzieren: `python3 tools/build_hotel_package.py`. Prüfung: `python3 tools/check_hotel_contract.py > hotel-test.lua`, danach `lua hotel-test.lua` (Lua 5.4).
