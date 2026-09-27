# Large City Office Tower — P5

Isolierte Geometrie-Vorschau für Issue #6, Layout LC-19. Gate A und P3 freigegeben; P4/Gate B am 27.09.2026 vom Benutzer freigegeben. P5-Dressing wartet auf Studio-Abnahme; P6 folgt danach. Gate C im Hauptspiel bleibt offen.

## Studio

Play stoppen. Vom Residential-Branch wechseln:

```sh
git fetch origin
git switch --track origin/largecity-office-tower-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. Die default.project.json ist bytegleich mit dem aktuellen Residential-Branch. Falls noch kein Server läuft: `rojo serve default.project.json`, Studio verbinden. Bei späteren Updates: Play stoppen → `git pull --ff-only` → Sync abwarten → Play.

In Workspace erscheint `LargeCity_OfficeTower_P5`. Vorderseite ist lokal -Z, Bodenpivot Y=0. Die Stadtplatzierung erfolgt später. Die Vorschau erzeugt genau dieses Gebäude.

Alternativ `dist/LargeCityOfficeTower_P4.rbxmx` als statisches Modell importieren, ohne parallel die Vorschau zu starten.

## Umfang

18 Geschosse: 2 Podiumgeschosse à 18 Studs, 16 Bürogeschosse à 16 Studs. Podium 104×88×36, Turmkörper 72×64×256, Krone 72×64×32. Dachkante 324, Rippen maximal 328 Studs. Zwei Fassadenrippen je 4 Studs breit und 3 Studs vorstehend, geschossweise segmentiert. Parzelle 144×128. Eingang mit zurückgesetzter Lobby und Vordach 40×12×3; seitliche Anlieferung. Dachtechnik liegt innerhalb der Krone.

P5 ergänzt dunklen Schiefersockel, blaues Architekturglas, Metallrahmen, fünf stilisierte Palmen, zwei Holzbänke und acht warme Lichtquellen. Keine Änderungen an globaler Beleuchtung. Das statische XML bleibt der archivierte P4-Stand; die aktuelle P5-Version wird via Rojo aus GoldenMaster und Dressing erzeugt. HP und Energie sind noch nicht festgelegt. Das Gebäude soll später als Ganzes zusammenbrechen.

## Reproduktion und Prüfung

`python3 tools/build_office.py` erzeugt Luau, XML und Massprüfbericht. Mit `--preview` zusätzlich sechs technische Ansichten (Pillow und NumPy erforderlich).

Mass-/Volumenprüfungen, XML-Roundtrip und Lua-5.4-Syntaxprüfung bestanden: 989 BaseParts inklusive unsichtbarem Pivot. Siehe `docs/office/geometry-checks.json` und `docs/office/geometry-review.png`. Diese Ansichten sind technische Renderings, keine Studio-Screenshots. Roblox-Runtime, Kollaps, Kampf und Performance noch nicht getestet.

Referenz: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/6
