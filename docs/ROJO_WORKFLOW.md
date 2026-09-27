# Einheitlicher Rojo-Workflow für neue Gebäudebranches

`default.project.json` bleibt künftig gebäudeunabhängig: Name LargeCityBuildingWorkshop, Port34872, zwei Ordnerzuordnungen.

| Quellordner | Roblox-Ziel |
| --- | --- |
| src/ReplicatedStorage/TrenchbornAssetWorkshop | ReplicatedStorage.TrenchbornAssetWorkshop |
| src/ServerScriptService | ServerScriptService |

Module erhalten weiterhin Namen wie LargeCityResidentialGoldenMaster; `.server.lua` erzeugt den jeweiligen Preview-Scriptnamen. Keine neue einzelne `$path`-Zeile für Dressing, Installer oder Specification nötig. Das optionale package.project.json bindet ebenfalls den Modulordner ein.

## Alltag

Play stoppen, `git pull --ff-only`, Sync abwarten, Play starten. Rojo weiterlaufen lassen. Ein erneuter Play-Start führt den Generator mit der neuen Quelle aus. Die Serververbindung muss bei normalen Quelländerungen nicht erneut aufgebaut werden.

Einmalig für den Wechsel von der bisherigen Einzeldateizuordnung zur Ordnerzuordnung: nach Pull Rojo stoppen und `rojo serve default.project.json` neu starten, dann Studio verbinden. Bei älteren Branches mit anderer Projektdatei bzw. anderem Port bleiben die jeweiligen Konfigurationsunterschiede zu beachten.

## Neue Gebäudebranches

Diese default.project.json unverändert übernehmen. Der jeweilige Branch muss isolierte Quellordner besitzen: nur Module dieses Gebäudes und genau dessen Preview-Script. Keine historischen Guardian- oder fremden Gebäudebootstraps in den synchronisierten Ordner legen. Werkzeuge, Tests und Exportdateien bleiben ausserhalb von src. ServerScriptService erhält `$ignoreUnknownInstances=true`, damit nicht von Rojo verwaltete Studio-Scripts nicht durch die Ordnerzuordnung entfernt werden.

Es werden keine Workspace-Modelle oder Geländeobjekte über diese Projektdatei verwaltet. Die vorhandene Roblox-Hierarchie von ResidentialPreview und LargeCityResidentialGoldenMaster bleibt erhalten.

Referenz: https://rojo.space/docs/v7/project-format/ und https://rojo.space/docs/v7/sync-details/

Validiert: JSON-Parsing, existierende Ordnerziele und erhaltene Dateinamen/Roblox-Pfade. Keine lokale Roblox-Studio-/Rojo-Livesitzung verfügbar; der Live-Sync ist hier nicht praktisch ausgeführt worden.
