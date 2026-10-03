# MC-03 — Elevated Transit Station: Studio review

Approved concept: ../images/03-elevated-transit-station.png. Task: #17.

## Model

Long elevated glass station on three pairs of heavy piers; three pitched snowy roof sections with raised clerestories; cyan platform edges, warm interior strips, benches and ticket machines. Tall glazed side access/lift tower with magenta vertical TRANSIT sign and attached exterior stair. Two open rail portals. Tracks stop at the building boundary: connecting railway and road are not included. No train included. Lift cabin is static architectural dressing, not an operating elevator.

All six signs use maximized SciFi text, following the accepted MC-01 standard. Glazing has no opaque backing block. Station, supports, access tower and stairs are one destruction unit.

## Provisional technical breakdown

- Main deck: 232 x 64 studs, centre Y=43; roof sections at Y=72; highest antenna about 110 studs. Exterior stair extends the overall footprint eastward. Dimensions require city-plan approval.
- 534 visible Parts, budget 750; six SurfaceGui signs; one embedded server runtime; no per-part scripts, external meshes, or installer dependency.
- KaijuHouse tag, EnergyType Electric, provisional MaxHealth 1,000,000 pending balance approval.
- Embedded MegaCityAPI damage/reset and energy notifications, shared with prior buildings. Game-side absorption integration remains separate.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop the old Rojo server; rojo serve mega-city-transit.project.json. Connect on port 34873 in Edit mode. The complete model appears directly in Workspace.MegaCityElevatedTransitStation. No Command Bar or installer. Default project also previews MC-03; explicit harbor/cargo projects remain available.

## Verification and gates

Export parsed: 535 anchored Parts including Origin; unique references and valid PrimaryPart; positive finite dimensions and orthonormal rotations; metadata round-trip and Lua syntax passed. Six signs checked for SciFi and full-label text scaling. Three off-engine geometry views inspected; they do not reproduce Roblox transparency, text, or lighting faithfully.

Gate B: awaiting user visual acceptance in Studio. Gate C: awaiting in-engine damage/reset and stair traversal tests. Do not start MC-04 before acceptance.

## Dachkorrektur und wiederholbares Hochbahnsegment

Die drei Belüftungsbaugruppen sind auf die hintere Dachneigung von 12 Grad ausgerichtet. Ihre Unterseite liegt auf der Dachfläche; Lamellen zeigen nach aussen. Schnee und Lamellen folgen derselben Transformation.

`Workspace.MegaCityElevatedRailStraight80` ist ein eigenständiges Modell, unabhängig von der Zerstörung der Station. Es wird mit der Transit-Vorschau synchronisiert und liegt am freien westlichen Portal. Es enthält Viadukt, Stütze, Gleisbett, Schienen, Schwellen und Cyan-Markierungen. Keine externe Strecke oder Zugsteuerung vorausgesetzt.

### In Studio verlängern

1. Das ganze Modell `MegaCityElevatedRailStraight80` im Explorer auswählen, nicht einzelne Parts.
2. Mit Strg+D duplizieren oder kopieren/einfügen.
3. Im globalen Verschiebemodus das Move-Raster auf 80 Studs stellen und die Kopie einen Schritt entlang -X verschieben.
4. Für jede weitere Verlängerung wiederholen. Höhe und Z-Position beibehalten. Falls Einfügen die Position automatisch versetzt, die Pivot-Position exakt setzen.

Erstes Segment: Pivot (-156, 0, 0), nächstes (-236, 0, 0), danach (-316, 0, 0). Länge 80 Studs. Schienenoberkante bei Y=47.5, exakt wie in der Station. `Origin.SnapStart` und `Origin.SnapEnd` markieren die Enden auf Schienenhöhe. Das Beispiel ist ein gerades Segment; Kurven und Weichen sind nicht enthalten. Eigene Kopien können in einem eigenen Workspace-Ordner gesammelt werden.

Technische Anschluss- und Dachkontaktprüfung bestanden; die optische Prüfung erfolgt in Studio.
