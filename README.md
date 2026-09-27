# Large City Residential Tower — Phase 4

Ein einzelnes Wohnhochhaus nach [Issue #5](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/5): 14 Geschosse, 232 Studs Gesamthöhe, Balkonvorsprünge und zwei Staffelgeschosse. Modell für LC-14; spätere Kopien und Stadtplatzierung folgen nach der Master-Abnahme. Kein Kit.

## In Studio ansehen

Play und bisherigen Rojo-Server stoppen. Im bestehenden Repository:

```sh
git fetch origin
git switch --track origin/largecity-residential-tower-l3
rojo serve default.project.json
```

Studio auf Port34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-residential-tower-l3` und `git pull --ff-only`.

Im Explorer `LargeCity_ResidentialTower_P4` auswählen und F drücken. Output: `Residential Tower P4 ready`.

**Die Vorschau steht bewusst 12 Studs höher**, damit eine übliche Baseplate die unterirdische Rampe nicht füllt. Das Gebäude bleibt lokal 232 Studs hoch. Es wird kein vorhandenes Gelände gelöscht oder verändert. Diese Vorschauposition ist keine endgültige Stadtposition.

Alternativ `dist/LargeCityResidentialTower_P4.rbxmx` in Workspace importieren. Der direkte Export enthält keine laufenden Scripts; Bodenbezug lokalY0. Bei vorhandener Bodenplatte das gesamte Modell für die Ansicht anheben oder in einem leeren Bereich platzieren.

## Zur Abnahme

Bitte zuerst Form und Proportionen prüfen: zweigeschossiger Sockel, zehn reguläre Wohngeschosse, zwei Staffelgeschosse, 6-Stud-Balkone mit wechselnden Eckvorsprüngen, Eingang und seitliche Garagenrampe.

Der Bau hat 914 Parts inklusive GroundPivot. Materialien, Pflanzen, Geländerfüllungen, Rampenmarkierungen, Lüftungsdetails und Beleuchtung folgen nach Gate B in P5. HP und Energieart sind noch offen. Keine Gameplay-Tags oder Schadenslogik in P4.

[Freigegebenes Zielbild](https://raw.githubusercontent.com/amanciobouza/trenchborn-asset-workshop/1218e2efde244fbbaa7a3596d041678b63fac6db/docs/assets/large-city/residential-tower/residential-tower-approved-target-2026-09-26.jpg). Die explizit freigegebenen Geschosszahlen und Baumasse sind massgeblich, nicht die perspektivischen Bildpixel.

## Reproduzieren

```sh
python3 tools/build_residential.py
python3 tools/build_residential.py --preview
```

Nur die technische Vorschau braucht numpy/Pillow; sonst Python-Standardbibliothek. Beide Exporte verwenden dieselbe Partliste. Prüfungen und offene Studio-Abnahme stehen in `docs/residential/geometry-checks.json` und `docs/residential/REVIEW.md`.
