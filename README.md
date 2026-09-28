# Central Station — P5 / Issue #9

Kopfbahnhof für LC-11, ein Gebäude, kein Kit. Gate A/P3 freigegeben. Benutzer hat am27.09.2026 bestätigt, dass kein bestehendes Schienensystem existiert, und die Festlegung der Gleisgeometrie beauftragt. P4/Gate B vom Benutzer am28.09.2026 freigegeben; P5 zur Studio-Abnahme.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-central-station-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist unverändert vom Courthouse-Branch übernommen. Wenn noch kein Server läuft: `rojo serve default.project.json`, dann Studio verbinden. Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace-Modell: `LargeCity_CentralStation_P5`. Pivot = Grundstücksmitte auf Vorplatzhöhe Y0, Front lokal -Z. Spätere Stadtplatzierung separat.

## Baukörper und Wege

Grundstück208×272, Empfangsfront176. Mittelbau80×48×56, Seitenflügel je48×48×36 mit zwei18Studs-Geschossen. Drei offene Portale je16Studs breit. Vordach96×16×3. Uhrplatzhalter12Studs Durchmesser. Statische Analoganzeige10:10 und CENTRAL STATION-Schrift ergänzt.

Empfangsbau Z=-96..-48. Eine innere Rampe von Y0.5 zu Y3 verbindet den Eingang mit dem überdachten Querbahnsteig Z=-48..-32. Zwei Seitenbahnsteige je20×144×3: X=-44..-24 und24..44, Z=-32..112. Hallendach112×160×64, Z=-32..128, neun segmentierte Querträger und acht Dachfelder. Höchste Aussenkante inklusive Trägerdicke exakt64. P5 nutzt blau-graues Glas mit0.45Transparenz für Hallendach, Hallenwände und Fenster.

## Verbindliche Schienenschnittstelle dieses Assets

Alle Koordinaten relativ zum Grundstückspivot; Anschlussrichtung hinten +Z.

| Parameter | Wert in Studs |
| --- | --- |
| Lichte Spurweite zwischen inneren Schienenflächen | 8 |
| Schienenbreite | 0.5 |
| Abstand der beiden Schienenmitten je Gleis | 8.5 |
| Gleismittenabstand | 32 |
| Gleismitten X | -16 und +16 |
| Schienenoberkante Y | 1.5 |
| Bahnsteigoberkante Y | 3 |
| Anschlussmitten hinten | (-16,1.5,136), (16,1.5,136) |
| Einzelne Schienenmitten X | -20.25, -11.75, 11.75, 20.25 |
| Schienenverlauf Z | -24 bis136 |

Prellböcke stehen am vorderen Gleisende hinter dem Querbahnsteig. Keine Gleise durch Empfangsgebäude/Vorplatz. Keine Züge oder Verkehrslogik enthalten. Spätere Strecken und Fahrzeuge müssen an diese Schnittstelle angepasst werden.

## Prüfungen / Export

`python3 tools/build_station.py --preview` erzeugt Luau, XML, Massbericht und sechs technische Ansichten (Pillow/NumPy für Preview). Geprüft: Parzellengrenzen, Höhenlimit64, drei freie Portale, zwei Gleise und Spurweite, zwei Seitenbahnsteige sowie XML-Teilzahl. Bilder sind technische Renderings, keine Studio-Screenshots. Bewegung, Glaswirkung, Performance und Kollaps hier nicht getestet.

`dist/LargeCityCentralStation_P4.rbxmx` ist alternativ zur Rojo-Vorschau importierbar; keine automatisch laufenden Scripts. P5-Abnahme offen. HP/Energie sowie Zerstörungsverhalten von Gleisen und Bahnsteigen werden vor P6 geklärt; Gate C bleibt offen.

Referenz: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/9

P5 ergänzt zwei gelbe Bahnsteigkanten, sechs Bänke auf den Bahnsteigen und zwei auf dem Vorplatz,14warme PointLights mit montierten Halterungen/Masten, Sträucher und zwei Palmen. Kein Eingriff in globale Beleuchtung. Das statische P4-XML bleibt ein Geometriearchiv; P5 läuft über die Rojo-Vorschau.
