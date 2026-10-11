# Kapitel 1 – Sammelobjekte / Gate B

Fünf native, editierbare Geometriemodelle: Frucht, Glutstein, Energiezelle,
Eierschale und Ur-Kaiju-Zahn. Design und technische Aufteilung sind freigegeben.
Gate B (Sichtprüfung in Roblox Studio) ist offen. Materialien, VFX und
Sammellogik folgen in späteren Phasen. Kein finaler Installer.

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
python collectibles/tools/build_geometry.py
```

Anschliessend die geänderten Modelle, Prüfszene, Vorschau und den Report
zusammen committen. Der Generator erzeugt deterministische XML-Dateien
und prüft Referenzen, positive Grössen und Rotationsmatrizen.

## Struktur und Gate-B-Prüfung

Jedes Modell hat `Geometry`, den vorerst leeren Ordner `Effects` sowie
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
Die Modelle haben 196–288 sichtbare Parts und sind für einzelne aktive
Fundstücke vorgesehen. Grössere Mengen benötigen eine Performanceprüfung.

Validiert mit Rojo 7.6.1: Place-Build und Model-Build. Roblox Studio und die
Live-Verbindung wurden hier nicht ausgeführt; Gate B bleibt bis zur
Sichtprüfung offen.

Rojo-Referenz: https://rojo.space/docs/v7/sync-details/
