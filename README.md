# Large City Police HQ — Phase 4

Eigenständiges Polizeihauptquartier nach [Issue #4](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/4). Geometrie zur visuellen Abnahme; Gate B offen. Ein Gebäude, kein Kit. Vorgesehen für LC-35, die endgültige Platzierung folgt gemeinsam mit den anderen Gebäuden.

## In Roblox Studio ansehen

Play stoppen und im bestehenden Repository ausführen:

```sh
git fetch origin
git switch --track origin/largecity-police-hq-l3
rojo serve default.project.json
```

Einen vorher laufenden Rojo-Server zuerst stoppen. Studio mit Port 34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-police-hq-l3` und `git pull --ff-only`. Der Output meldet `Police HQ P4 ready`. Das Modell heisst `LargeCity_PoliceHQ_P4` und erscheint am Ursprung. Im Explorer auswählen und mit F fokussieren.

Alternativ `dist/LargeCityPoliceHQ_P4.rbxmx` direkt in Workspace importieren. Dieser Export enthält keine laufenden Scripts und ist ohne Rojo sichtbar. Nicht gleichzeitig mit dem Preview installieren.

## Abnahme

Drei Hauptgeschosse, Mittelportal, Fahrzeugzugang, Funkaufbau, Vorplatz, Treppe und Rampe sind gebaut. Hauptkörper 128 × 72 × 60, Portal 32 × 8 × 68, Vordach 40 × 12 × 3, Fahrzeugzugang 32 × 24 × 24, Funkraum 32 × 24 × 16, Grundstück 176 × 128 Studs; Antennenspitze Y=100. Reihenfolge B × T × H.

Bitte zuerst Proportionen und Silhouette beurteilen. Wappen, Schüssel, detaillierte Dachtechnik, Beleuchtung, Schranke und Begrünung folgen in P5. Der POLICE-Schriftzug ist bereits im Studio-Modell vorhanden.

P4 besitzt keine Gameplay-Tags oder HP. Das gemeinsame Spielsystem wird erst in P6 angebunden; HP und Energieart sind offen. Die jüngste Vereinfachung der Feuerwache dient als Vorlage: ein Gebäude als Ganzes, keine separaten Bauteil-HP.

## Reproduzieren

```sh
python3 tools/build_police.py
python3 tools/build_police.py --preview
```

Der zweite Aufruf erzeugt sechs technische Ansichten mit numpy und Pillow. `docs/police/geometry-checks.json` dokumentiert Prüfungen und Grenzen. Die Vorschau stellt Exportgeometrie dar, keine Aufnahme aus Roblox Studio.
