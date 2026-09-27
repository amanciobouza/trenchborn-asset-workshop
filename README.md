# Emberline Response HQ - LC-45

Einzelne Fire Station für Large City. **Phase 4, erster Modellstand zur Abnahme.**
Dieser Branch ersetzt das alte Drei-Tore-/34-Stud-Konzept durch [Issue #3](https://github.com/amanciobouza/trenchborn-asset-workshop/issues/3).
Kein Kit, keine Varianten, keine zweite Feuerwache auf LC-17.

## Modell öffnen

1. `dist/LargeCityEmberlineResponseHQ_P4.rbxmx` herunterladen.
2. In einem leeren Roblox-Studio-Projekt als Modell in `Workspace` einfügen.
3. Das Modell `LargeCity_EmberlineResponseHQ_P4` auswählen und fokussieren.
4. Front ist lokal **-Z**. Der unsichtbare `GroundPivot` liegt im Grundstückszentrum auf Bodenhöhe.

Das Paket enthält echte, verankerte Parts, Baugruppen und das Fassadenschild. Es benötigt keine Scripts, externen Meshes, Bilder oder andere Gebäude. Der Import wurde hier **noch nicht in Roblox Studio ausgeführt**. XML- und Geometrieprüfungen ersetzen diesen Test nicht.

## Reproduzierbar bauen

```sh
python3 tools/build_emberline.py
# Optional: sechs technische Ansichten, benötigt numpy und Pillow
python3 tools/build_emberline.py --preview
```

Der Generator schreibt das statische `.rbxmx`, einen gleich aufgebauten Luau-Builder und den Prüfbericht. Änderungen erfolgen am Generator; danach Ausgaben neu erzeugen und gemeinsam committen.

Alternativ verbindet `default.project.json` den isolierten Emberline-Workshop mit Rojo. Beim Starten des Play-Modus erzeugt `EmberlinePreview` das Modell einmal. Es werden keine anderen Gebäude oder Guardian-Module geladen. `package.project.json` ist nur das optionale Quellmodul-Paket; das direkt sichtbare Gebäudemodell liegt in `dist/`.

```lua
local builder = require(game.ReplicatedStorage.TrenchbornAssetWorkshop.LargeCityEmberlineGoldenMaster)
local building = builder.Build(workspace, {GroundCFrame = CFrame.new(0, 0, 0)})
```

## Review

![Sechs technische Ansichten](docs/emberline/geometry-review.png)

Die Ansichten werden aus denselben Parts wie der Export berechnet, ausserhalb Roblox Studio. Sie enthalten keine Engine-Beleuchtung, keine Schattenberechnung und keine SurfaceGui-Schrift. Das Namensschild wird im Roblox-Modell dargestellt.

Siehe [Review und Bauentscheidungen](docs/emberline/REVIEW.md) und [automatische Prüfungen](docs/emberline/geometry-checks.json).

**Gate B offen.** P5-Dressing, P6-Spielintegration und Gate C folgen nach der Modellabnahme. `KaijuHouse`, `MaxHealth` und `EnergyType` sind absichtlich noch nicht gesetzt: die Werte sind nicht freigegeben. Es gibt keine Fahrzeuge, NPCs oder Feuerwehrlogik im Export.

Die spätere Stadtposition ist LC-45. Der Plan v2.1 hat **City im Norden und Mega City im Süden**. Eine Stadtplatzierung ist noch nicht ausgeführt.
