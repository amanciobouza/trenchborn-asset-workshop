# Large City Residential Tower — Phase 6

Ein einzelnes Wohnhochhaus nach [Issue #5](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/5): 14 Geschosse, 232 Studs Gesamthöhe, Balkonvorsprünge und zwei Staffelgeschosse. Modell für LC-14; spätere Kopien und Stadtplatzierung folgen nach der Master-Abnahme. Kein Kit.

## In Studio ansehen

Play und bisherigen Rojo-Server stoppen. Im bestehenden Repository:

```sh
git fetch origin
git switch --track origin/largecity-residential-tower-l3
rojo serve default.project.json
```

Studio auf Port34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-residential-tower-l3` und `git pull --ff-only`.

Im Explorer `LargeCity_ResidentialTower_L3` auswählen und F drücken. Output: `Residential Tower P6 ready`.

**Die Vorschau steht bewusst 12 Studs höher**, damit eine übliche Baseplate die unterirdische Rampe nicht füllt. Das Gebäude bleibt lokal 232 Studs hoch. Es wird kein vorhandenes Gelände gelöscht oder verändert. Diese Vorschauposition ist keine endgültige Stadtposition.

Eigenständiges P6-Quellpaket: `dist/LargeCityResidentialPackage.rbxmx` als Folder in Workspace importieren, dann in der Studio-Command-Bar ausführen:

```lua
require(workspace.LargeCityResidentialPackage.LargeCityResidentialInstaller).Install(workspace)
```

Das Paket startet nichts automatisch. Bei vorhandener Bodenplatte für die Vorschau `{GroundCFrame=CFrame.new(0,12,0)}` als zweiten Parameter verwenden. Details zur Geländeöffnung und zum Paket stehen in `docs/residential/GAMEPLAY.md`. P4/P5-Direktexporte bleiben als visuelle Archive bestehen.

## Laufende Updates ohne Rojo-Neustart

Die Projektdatei bindet jetzt die Quellordner ein. Neue Module und Preview-Scripts in diesen Ordnern werden automatisch synchronisiert. Die Roblox-Pfade bleiben dieselben.

Nach normalen Änderungen einschliesslich neuer Module: **Play stoppen → `git pull --ff-only` → Sync abwarten → Play starten**. Der bestehende Rojo-Server und die Studio-Verbindung bleiben bestehen. Play wird neu gestartet, weil der Gebäudegenerator beim Serverstart läuft.

Für diese einmalige Umstellung nach dem Pull Rojo neu starten und Studio neu verbinden. Ältere Gebäudebranches besitzen teilweise noch andere Projektdateien; die Umstellung hier gilt zunächst für den Residential-Branch. Neue Gebäudebranches sollen dieselbe `default.project.json` übernehmen.

Details: `docs/ROJO_WORKFLOW.md`.

## Aktueller Stand

Geometrie und Dressing wurden vom Nutzer freigegeben. P5 ergänzt Beton-/Sandtöne, Glasgeländer, bepflanzte Balkone und Terrassen, drei kleine Bäume, Dachlüftungen, Torlamellen, gelbe Rampenränder und warme Beleuchtung.

P6 integriert den gesamten Bau als eine Zerstörungsgruppe. 1'222 Parts inklusive GroundPivot, acht PointLights ohne Schatten. **Freigegeben:64’000 HP, Electric-Energie, ein gemeinsamer Einsturz.** Der echte Schadens-/Einsturztest im Hauptspiel bleibt offen; Gate C ist Pending.

[Freigegebenes Zielbild](https://raw.githubusercontent.com/amanciobouza/trenchborn-asset-workshop/1218e2efde244fbbaa7a3596d041678b63fac6db/docs/assets/large-city/residential-tower/residential-tower-approved-target-2026-09-26.jpg). Die explizit freigegebenen Geschosszahlen und Baumasse sind massgeblich, nicht die perspektivischen Bildpixel.

## Reproduzieren

```sh
python3 tools/build_residential_dressing.py
python3 tools/build_residential_dressing.py --preview
python3 tools/build_residential_package.py
```

Nur die technische Vorschau braucht numpy/Pillow; sonst Python-Standardbibliothek. Beide Exporte verwenden dieselbe Partliste. Prüfungen und offene Studio-Abnahme stehen in `docs/residential/dressing-checks.json` und `docs/residential/DRESSING.md`.
