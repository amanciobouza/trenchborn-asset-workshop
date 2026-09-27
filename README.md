# Large City Police HQ — Phase 5

Eigenständiges Polizeihauptquartier nach [Issue #4](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/4). Geometrie vom Nutzer freigegeben; Phase-5-Dressing zur visuellen Abnahme. Ein Gebäude, kein Kit. Vorgesehen für LC-35, die endgültige Platzierung folgt gemeinsam mit den anderen Gebäuden.

## In Roblox Studio ansehen

Play stoppen und im bestehenden Repository ausführen:

```sh
git fetch origin
git switch --track origin/largecity-police-hq-l3
rojo serve default.project.json
```

Einen vorher laufenden Rojo-Server zuerst stoppen. Studio mit Port 34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-police-hq-l3` und `git pull --ff-only`. Der Output meldet `Police HQ P5 ready`. Das Modell heisst `LargeCity_PoliceHQ_P5` und erscheint am Ursprung. Im Explorer auswählen und mit F fokussieren.

Alternativ `dist/LargeCityPoliceHQ_P5.rbxmx` direkt in Workspace importieren. Dieser Export enthält keine laufenden Scripts und ist ohne Rojo sichtbar. Nicht gleichzeitig mit dem Preview installieren.

## Abnahme

Drei Hauptgeschosse, Mittelportal, Fahrzeugzugang, Funkaufbau, Vorplatz, Treppe und Rampe sind gebaut. Hauptkörper 128 × 72 × 60, Portal 32 × 8 × 68, Vordach 40 × 12 × 3, Fahrzeugzugang 32 × 24 × 24, Funkraum 32 × 24 × 16, Grundstück 176 × 128 Studs; Antennenspitze Y=100. Reihenfolge B × T × H.

Polizeiwappen, Schüssel, Dachgeräte, Beleuchtung, Schranke, Poller und Begrünung sind ergänzt. Bitte Materialien, Wappen und Lichtwirkung in Studio beurteilen. Die Schranke bleibt statisch. Insgesamt 585 Parts und zwölf PointLights ohne Schatten.

P5 besitzt noch keine Gameplay-Tags oder HP. Das gemeinsame Spielsystem wird erst in P6 angebunden; HP und Energieart sind offen. Die jüngste Vereinfachung der Feuerwache dient als Vorlage: ein Gebäude als Ganzes, keine separaten Bauteil-HP.

## Reproduzieren

```sh
python3 tools/build_police_dressing.py
python3 tools/build_police_dressing.py --preview
```

Der zweite Aufruf erzeugt sechs technische Ansichten mit numpy und Pillow. `docs/police/dressing-checks.json` dokumentiert Prüfungen und Grenzen. Die Vorschau stellt Exportgeometrie dar, keine Aufnahme aus Roblox Studio.

**Update von P4:** Play stoppen, `git pull --ff-only`, Rojo-Server neu starten und Studio auf Port 34872 neu verbinden. Das neue Dressing-Modul benötigt die aktualisierte Projektzuordnung.
