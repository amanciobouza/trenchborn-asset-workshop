# Large City Police HQ — Phase 6

Eigenständiges Polizeihauptquartier nach [Issue #4](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/4). Geometrie und Dressing vom Nutzer freigegeben. Gameplay-Metadaten und gemeinsame Zerstörungsgruppe integriert; Hauptspieltest / Gate C offen. Ein Gebäude, kein Kit. Vorgesehen für LC-35, die endgültige Platzierung folgt gemeinsam mit den anderen Gebäuden.

## In Roblox Studio ansehen

Play stoppen und im bestehenden Repository ausführen:

```sh
git fetch origin
git switch --track origin/largecity-police-hq-l3
rojo serve default.project.json
```

Einen vorher laufenden Rojo-Server zuerst stoppen. Studio mit Port 34872 neu verbinden, synchronisieren und Play starten. Bei bereits lokal vorhandenem Branch genügt `git switch largecity-police-hq-l3` und `git pull --ff-only`. Der Output meldet `Police HQ P6 ready`. Das Modell heisst `LargeCity_PoliceHQ_L3` und erscheint am Ursprung. Im Explorer auswählen und mit F fokussieren.

Eigenständiges P6-Quellpaket: `dist/LargeCityPolicePackage.rbxmx` als Folder in Workspace importieren, dann in der Studio-Command-Bar ausführen:

```lua
require(workspace.LargeCityPolicePackage.LargeCityPoliceInstaller).Install(workspace)
```

Das Paket enthält vier ModuleScripts und startet nichts automatisch. Der alte direkte P5-Export bleibt als visuelles Archiv verfügbar; er hat keine Gameplay-Integration.

## Abnahme

Drei Hauptgeschosse, Mittelportal, Fahrzeugzugang, Funkaufbau, Vorplatz, Treppe und Rampe sind gebaut. Hauptkörper 128 × 72 × 60, Portal 32 × 8 × 68, Vordach 40 × 12 × 3, Fahrzeugzugang 32 × 24 × 24, Funkraum 32 × 24 × 16, Grundstück 176 × 128 Studs; Antennenspitze Y=100. Reihenfolge B × T × H.

Polizeiwappen, Schüssel, Dachgeräte, Beleuchtung, Schranke, Poller und Begrünung sind ergänzt. Dressing nach Schüsselkorrektur vom Nutzer bestätigt. Die Schranke bleibt statisch. Insgesamt 585 Parts und zwölf PointLights ohne Schatten.

**Freigegeben: 32'000 HP, Electric-Energie, ein gemeinsamer Einsturz.** Alle sichtbaren Parts gehören zu einer Zerstörungsgruppe. Der Installer setzt den KaijuHouse-Tag und Metadaten für das gemeinsame Hauptspielsystem. Der tatsächliche Schadens-/Einsturztest bleibt offen, Gate C ist Pending. Details und Prüfumfang: `docs/police/GAMEPLAY.md`.

## Reproduzieren

```sh
python3 tools/build_police_dressing.py
python3 tools/build_police_dressing.py --preview
python3 tools/build_police_package.py
```

Der Aufruf mit --preview erzeugt sechs technische Ansichten mit numpy und Pillow. `docs/police/dressing-checks.json` dokumentiert Prüfungen und Grenzen. Die Vorschau stellt Exportgeometrie dar, keine Aufnahme aus Roblox Studio.

**Update von P5:** Play stoppen, `git pull --ff-only`, Rojo-Server neu starten und Studio auf Port 34872 neu verbinden. Das neue Installer-Modul benötigt die aktualisierte Projektzuordnung.
