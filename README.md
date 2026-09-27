# City Hotel — P5 / Issue #7

Ein Stadthotel für LC-16: zwölf Geschosse, warmer heller Stein, regelmässige Zimmerfenster und vorspringender Mittelteil. Gate A/P3 freigegeben; P4/Gate B vom Benutzer freigegeben; P5-Dressing wartet auf visuelle Studio-Abnahme. Bestehendes Stadium Hotel und Waterfront Resort sind separate Assets.

## Studio-Vorschau

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-city-hotel-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist unverändert vom Office-Branch übernommen. Bei noch nicht laufendem Server: `rojo serve default.project.json`, dann Studio verbinden. Spätere Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace-Modell: `LargeCity_CityHotel_P5`. Bodenpivot ist Grundstücksmitte Y=0, Front lokal -Z. Gebäudemitte liegt lokal bei Z=12, um Platz für die Vorfahrt zu schaffen. Die endgültige Stadtplatzierung folgt später.

## Masse und Ausführung

Sockel 128×80×36, zwei Geschosse à18. Zimmerbau 120×72×160, zehn Geschosse à16. Mittelteil 24 breit und 6 vorspringend, je Geschoss segmentiert. Dachgesims 128×80×8 bis Y204; Mittelabschluss maximal Y208. Vordach 72×28×6, Unterkante Y20. Grundstück 176×144.

Vier Säulen begrenzen die Vorfahrt; der durchgehende Fahrstreifen Z=-52 bis -32 bleibt von Y0 bis Y20 frei. Pflanzeninseln liegen ausserhalb dieses Streifens. Separater Lieferzugang links. Reale Fensteröffnungen mit zwei Scheiben pro Fenster, voneinander getrennten Rahmen und Mittelpfosten. Zimmer bleiben unmöbliert.

P5 ergänzt fünf vertikale HOTEL-Buchstaben, warme Gesimsstreifen, zwölf PointLights, transparente Sockelverglasung, einfache Lobby-/Restaurant-Einrichtung auf beiden Sockelebenen, vier Palmen und bepflanzte Inseln. Die Leuchten am Vordach liegen oberhalb Y20. Die globale Beleuchtung bleibt unverändert. HP und Energie werden vor P6 abgestimmt; ein gemeinsames Gebäude für die spätere Zerstörung.

## Export und Prüfungen

`dist/LargeCityHotel_P4.rbxmx` ist das statische P4-Modell ohne automatisch laufende Scripts. Alternativ zur Rojo-Vorschau importieren, nicht gleichzeitig am selben Ort.

`python3 tools/build_hotel.py --preview` reproduziert Luau, XML, Massbericht und sechs technische Ansichten (Preview benötigt Pillow/NumPy). Nachweise in docs/hotel. Die Bilder sind technische Renderings ausserhalb Studio. Geprüft werden Hauptmasse, Höhen, Fenster-/Wandvolumen, Parzellengrenzen und freie Vorfahrt sowie XML-Teilzahl. Roblox-Laufzeit, Performance und Kollaps noch nicht getestet. P5-Abnahme und später Gate C bleiben offen. Das statische P4-XML bleibt ein Geometriearchiv; die aktuelle P5-Version wird über die Rojo-Vorschau erzeugt.

Verbindliche Spezifikation und Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/7
