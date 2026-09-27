# Large City Residential Tower — Phase 5

Ein einzelnes Wohnhochhaus nach [Issue #5](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/5): 14 Geschosse, 232 Studs Gesamthöhe, Balkonvorsprünge und zwei Staffelgeschosse. Modell für LC-14; spätere Kopien und Stadtplatzierung folgen nach der Master-Abnahme. Kein Kit.

## In Studio ansehen

Play und bisherigen Rojo-Server stoppen. Im bestehenden Repository:

```sh
git fetch origin
git switch --track origin/largecity-residential-tower-l3
rojo serve default.project.json
```

Studio auf Port34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-residential-tower-l3` und `git pull --ff-only`.

Im Explorer `LargeCity_ResidentialTower_P5` auswählen und F drücken. Output: `Residential Tower P5 ready`.

**Die Vorschau steht bewusst 12 Studs höher**, damit eine übliche Baseplate die unterirdische Rampe nicht füllt. Das Gebäude bleibt lokal 232 Studs hoch. Es wird kein vorhandenes Gelände gelöscht oder verändert. Diese Vorschauposition ist keine endgültige Stadtposition.

Alternativ `dist/LargeCityResidentialTower_P5.rbxmx` in Workspace importieren. Der direkte Export enthält keine laufenden Scripts; Bodenbezug lokalY0. Bei vorhandener Bodenplatte das gesamte Modell für die Ansicht anheben oder in einem leeren Bereich platzieren.

## Laufende Updates ohne Rojo-Neustart

Die Projektdatei bindet jetzt die Quellordner ein. Neue Module und Preview-Scripts in diesen Ordnern werden automatisch synchronisiert. Die Roblox-Pfade bleiben dieselben.

Nach normalen Änderungen einschliesslich neuer Module: **Play stoppen → `git pull --ff-only` → Sync abwarten → Play starten**. Der bestehende Rojo-Server und die Studio-Verbindung bleiben bestehen. Play wird neu gestartet, weil der Gebäudegenerator beim Serverstart läuft.

Für diese einmalige Umstellung nach dem Pull Rojo neu starten und Studio neu verbinden. Ältere Gebäudebranches besitzen teilweise noch andere Projektdateien; die Umstellung hier gilt zunächst für den Residential-Branch. Neue Gebäudebranches sollen dieselbe `default.project.json` übernehmen.

Details: `docs/ROJO_WORKFLOW.md`.

## Zur Abnahme

Die Geometrie wurde vom Nutzer freigegeben. P5 ergänzt Beton-/Sandtöne, Glasgeländer, bepflanzte Balkone und Terrassen, drei kleine Bäume, Dachlüftungen, Torlamellen, gelbe Rampenränder und warme Beleuchtung.

Bitte Glaswirkung, Begrünung, Eingang und Rampe in Studio prüfen. 1'222 Parts inklusive GroundPivot, acht PointLights ohne Schatten. HP/Energieart und Gameplay-Integration bleiben für P6 offen.

[Freigegebenes Zielbild](https://raw.githubusercontent.com/amanciobouza/trenchborn-asset-workshop/1218e2efde244fbbaa7a3596d041678b63fac6db/docs/assets/large-city/residential-tower/residential-tower-approved-target-2026-09-26.jpg). Die explizit freigegebenen Geschosszahlen und Baumasse sind massgeblich, nicht die perspektivischen Bildpixel.

## Reproduzieren

```sh
python3 tools/build_residential_dressing.py
python3 tools/build_residential_dressing.py --preview
```

Nur die technische Vorschau braucht numpy/Pillow; sonst Python-Standardbibliothek. Beide Exporte verwenden dieselbe Partliste. Prüfungen und offene Studio-Abnahme stehen in `docs/residential/dressing-checks.json` und `docs/residential/DRESSING.md`.
