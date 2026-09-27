# Emberline Response HQ - LC-45

Einzelne Fire Station für Large City. **Phase 6: Integrationsstand für den Hauptspieltest. Gate C offen.**
Dieser Branch ersetzt das alte Drei-Tore-/34-Stud-Konzept durch [Issue #3](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/3).
Kein Kit, keine Varianten, keine zweite Feuerwache auf LC-17.

## Aktueller Stand: Phase 6

P4-Geometrie und P5-Dressing sind vom Nutzer bestätigt. **32'000 HP, Thermal und KaijuHouse** sind integriert. Gate C / Hauptspieltest bleibt offen.

### Mit Git / Rojo

Play stoppen, `git pull --ff-only`, den Rojo-Server vollständig neu starten (`rojo serve default.project.json`) und Studio auf Port 34872 neu verbinden. Nach Synchronisierung Play starten. Der Workshop baut `LargeCity_EmberlineResponseHQ_L3` und prüft sechs Zerstörungsgruppen auf separaten Kopien. Ein leeres Workshop-Projekt besitzt noch keine Hauptspiel-Angriffe.

### Ohne Rojo

`dist/LargeCityEmberlinePackage.rbxmx` als Folder in Workspace importieren und in der Command-Bar ausführen:

```lua
require(workspace.LargeCityEmberlinePackage.LargeCityEmberlineInstaller).Install(workspace)
```

Das Paket ist ein Quellmodul-Paket mit Installer. Die früheren P4/P5-Dateien bleiben historische Direktmodelle. Sie tragen noch keine P6-Integration.

Siehe [Spielintegration, Gruppen, Tests und Gate C](docs/emberline/GAMEPLAY.md).

## Reproduzierbar bauen

```sh
python3 tools/build_emberline.py
# Optional: sechs technische Ansichten, benötigt numpy und Pillow
python3 tools/build_emberline.py --preview
python3 tools/build_emberline_package.py
```

Der Generator schreibt das statische `.rbxmx`, einen gleich aufgebauten Luau-Builder und den Prüfbericht. Phase-5-Details stehen in `tools/emberline_dressing.py`. Änderungen erfolgen an diesen Quellen; danach Ausgaben neu erzeugen und gemeinsam committen.

`default.project.json` verbindet den isolierten Emberline-Workshop mit Rojo. Beim Starten des Play-Modus erzeugt `EmberlinePreview` das Modell und wendet Dressing und Integration an. Nach einem Update mit neuen Modulen bitte Stop, Rojo-Server neu starten, synchronisieren und erneut Play. Es werden keine anderen Gebäude oder Guardian-Module geladen. `package.project.json` definiert das Quellmodul-Paket; historische direkte Geometriemodelle und das aktuelle Installer-Paket liegen in `dist/`.

```lua
local builder = require(game.ReplicatedStorage.TrenchbornAssetWorkshop.LargeCityEmberlineGoldenMaster)
local building = builder.Build(workspace, {GroundCFrame = CFrame.new(0, 0, 0)})
require(game.ReplicatedStorage.TrenchbornAssetWorkshop.LargeCityEmberlineDressing).Apply(building)
require(game.ReplicatedStorage.TrenchbornAssetWorkshop.LargeCityEmberlineInstaller).Attach(building)
```

## Review

![Sechs technische Ansichten](docs/emberline/dressing-review.png)

Die Ansichten werden aus denselben Parts wie der Export berechnet, ausserhalb Roblox Studio. Sie enthalten keine Engine-Beleuchtung, keine Schattenberechnung und keine SurfaceGui-Schrift oder Symbole. Das Namensschild wird im Roblox-Modell dargestellt.

Siehe [Review und Bauentscheidungen](docs/emberline/REVIEW.md) und [P5-Dressing](docs/emberline/DRESSING.md) und [automatische Prüfungen](docs/emberline/dressing-checks.json).

**Gate B und Dressing vom Nutzer freigegeben.** Gate C bleibt offen. Der Installer übernimmt die Metadaten und Zerstörungsgruppen nach dem vorhandenen Gebäude-Vertrag. Es gibt keine Fahrzeuge, NPCs oder Feuerwehrlogik im Paket. Der vollständige Schadens-/Energie-/Einsturztest benötigt das Hauptspiel.

Die spätere Stadtposition ist LC-45. Der Plan v2.1 hat **City im Norden und Mega City im Süden**. Eine Stadtplatzierung ist noch nicht ausgeführt.
