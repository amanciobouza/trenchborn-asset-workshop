# Kapitel 1 – Sammelobjekte / P5 Dressing

Fünf native, editierbare Geometriemodelle: Frucht, Glutstein, Energiezelle,
Eierschale und Ur-Kaiju-Zahn. Design und technische Aufteilung sind freigegeben.
Gate B (Form) ist freigegeben. P5 umfasst Farben, Materialien, Licht und
Partikel. Die Dressing-Sichtprüfung und Gameplay-Anbindung stehen noch aus.
Kein finaler Installer.

## Git und Rojo

Im bestehenden Repository:

```powershell
git fetch origin
git switch feature/chapter1-collectibles-gate-b
git pull --ff-only
rojo serve collectibles.project.json
```

In Roblox Studio eine leere Baseplate öffnen. Im Rojo-Plugin mit
`localhost:34872` verbinden und die angezeigten Änderungen synchronisieren.
Ein bereits laufender Workshop-Rojo-Server auf diesem Port muss zuerst
beendet werden. Die Modelle sind sofort im Edit-Modus sichtbar, ohne Play.

- `Workspace > Trenchborn_Collectibles_GateB`: fünf Modelle nebeneinander.
- `ReplicatedStorage > TrenchbornCollectibles`: fünf Einzelmodelle am Ursprung.

Die vorhandene `default.project.json` bleibt unverändert. Zum Arbeiten an
diesen Objekten ausdrücklich `collectibles.project.json` verwenden. Dieses
Projekt synchronisiert keine bestehenden Workshop-Bootstrap-Scripts.
Andere Instanzen ausserhalb der beiden Objektgruppen bleiben erhalten.
Das Set in Workspace markieren und **F** drücken. Falls die Baseplate den
unteren Rand verdeckt, die Prüfszene anheben.

## Export und Einbau

Prüf-Place bauen:

```powershell
rojo build collectibles.project.json -o CollectiblesReview.rbxlx
```

Paket mit den fünf Einzelmodellen bauen:

```powershell
rojo build collectibles-package.project.json -o CollectiblesGateB.rbxmx
```

Die einzelnen Dateien in `collectibles/models/` sind auch direkt über
Studio „Insert from File…“ importierbar. Für ein anderes Rojo-Projekt kann
der gesamte Ordner `collectibles/models` kopiert und als `$path` unter
ReplicatedStorage eingebunden werden.

Die Geometrie wird direkt aus den XML-Dateien synchronisiert; kein Download
externer Meshes und keine Codeausführung zum Erzeugen erforderlich.
Änderungen an den generierten XML-Dateien sollten über den Generator
erfolgen. Lokale Studio-Änderungen werden nicht automatisch nach Git
übernommen. Zur manuellen Weiterbearbeitung eine Kopie ausserhalb der
Rojo-verwalteten Gruppen verwenden.

## Reproduzierbare Geometrie

Nur für Änderungen am Generator, nicht für normalen Rojo-Sync:

```powershell
python -m pip install -r collectibles/tools/requirements.txt
python collectibles/tools/build_dressing.py
```

Anschliessend die geänderten Modelle, Prüfszene, Vorschau und den Report
zusammen committen. Der Generator erzeugt deterministische XML-Dateien
und prüft Referenzen, positive Grössen und Rotationsmatrizen.

## Struktur und Gate-B-Prüfung

Jedes Modell hat `Geometry`, einen separaten Ordner `Effects` sowie
`Root` als unsichtbare PrimaryPart am Boden. Darunter liegt
`PickupAttachment`. Attribute: `ItemId`, `CityId`, `Need`, `BuildStage`,
`Version`. Alle Teile sind verankert, ohne physische Kollision und ohne
Touch-Events. Die sichtbare Geometrie ist für Raycasts abfragbar.

Bitte prüfen:

- Vollständige Formen, insbesondere Zahnspitze und Blätter.
- Hohler Innenraum und Bruchrand der Eierschale.
- Sichtbare Fugen am Glutstein und vier Schutzstreben an der Energiezelle.
- Grössen neben dem Kaiju und in einem Haus; gesamtes Einzelmodell skalieren.
- Keine verdrehten oder fehlenden Dreiecksflächen.

`docs/Geometry_Preview.png` ist eine lokale Konstruktionsvorschau, kein
Studio-Screenshot. Massangaben und Teilezahlen: `docs/geometry_report.json`.
Die Modelle haben 212–288 sichtbare Parts und sind für einzelne aktive
Fundstücke vorgesehen. Grössere Mengen benötigen eine Performanceprüfung.

Validiert mit Rojo 7.6.1: Place-Build und Model-Build. Roblox Studio und die
Live-Verbindung wurden hier nicht ausgeführt. Gate B wurde vom Benutzer
freigegeben; die neue P5-Dressing-Sichtprüfung steht noch aus.

Rojo-Referenz: https://rojo.space/docs/v7/sync-details/


## P5 – Farben und Effekte testen

- Frucht: goldorange, grüne Blätter, brauner Holzstiel, dezente Fundpartikel.
- Glutstein: dunkles Gestein, orange Neon-Glut in Fugen, Funken.
- Energiezelle: dunkles Metall, cyanfarbener Kern und Leuchtringe.
- Eierschale: cremefarbene Schale, dünne türkise Aussenmarkierungen.
- Zahn: elfenbeinfarben, dunkle Wurzel, goldene Leuchtadern.

Farben, Neon, Lichter und vorbereitete Partikelemitter sind im Modell
enthalten. Die clientseitige Lichtpulsation läuft erst im Play-Modus.
Zum zuverlässigen Prüfen der Partikel ebenfalls Play starten.
`collectibles.project.json` synchronisiert den Effekt-Controller nach
`StarterPlayer > StarterPlayerScripts > TrenchbornCollectibleEffects`.

Im Play-Modus am jeweiligen Modell das boolesche Attribut `EffectsEnabled`
auf false setzen: Licht, Partikel und Neon werden abgeschaltet. Der Kern
bleibt als dunkler Körper sichtbar. true schaltet die Effekte wieder ein.
Die Einstellung betrifft nur kosmetische Effekte, nicht die Sammellogik.

Das reine .rbxmx-Modellpaket enthält statische Effekte. Für Pulsation und
EffectsEnabled in einem anderen Projekt zusätzlich
`runtime/CollectibleEffects.client.lua` nach StarterPlayerScripts übernehmen.
Der Controller erkennt P5-Modelle im Workspace anhand von BuildStage.

`docs/Dressing_Preview.png` zeigt die serialisierte Geometrie mit Farben;
Studio-Licht, Materialtexturen und Partikel sind in diesem lokalen Render
nicht simuliert. Der alte Gate-B-Datei- und Szenenname bleibt aus
Kompatibilitätsgründen erhalten. BuildStage ist jetzt P5_Dressing.

Neu generieren immer mit build_dressing.py: Dieser führt zuerst den
Geometriegenerator aus und setzt danach das Dressing auf. Ein separater
Aufruf von build_geometry.py stellt bewusst nur den grauen P4-Stand her.
