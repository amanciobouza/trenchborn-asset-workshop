# Ocean Galleria — P4 / Issue #10

Ein Einkaufszentrum für LC-07, kein Kit. Gate A/P3 freigegeben; P4/Gate B zur visuellen Abnahme.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-ocean-galleria-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json unverändert vom Bahnhof. Wenn noch kein Server läuft: `rojo serve default.project.json`, dann Studio verbinden. Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace-Modell: `LargeCity_OceanGalleria_P4`. Grundstückspivot Y0, Front lokal -Z.

## Masse / Aufbau

Grundstück224×160; Gebäude192×96. Zwei Flügel je64×96×54 mit drei18Studs-Geschossen. Zentralatrium64×96×72, Dachansatz54, Scheitel inklusive Trägerdicke72. Sieben Querträger, sechs Glasdachfelder. Vordach80×16×4. Zwei Dachaggregate je24×16×8 auf Y54. Geschlossene Fassadenanschlüsse an X±32.

Atriumboden Y1; umlaufende Galerieplatten auf Y18 und36, je10Studs breit, mit grossem Innenraum. Die oberen Galerien dienen der sichtbaren Innenwirkung; Treppen/Einkaufsmechanik sind nicht zugesagt. Freies20Studs-Hauptportal. Glas bleibt in P4 für die Geometrieprüfung opak; Transparenz und Ladenwirkung folgen in P5.

Rückwärtige Anlieferung64×24 bei X±32/Z48..72. Zwei16×14Studs-Liefertore an den Flügeln, Mitte X±44, mit kurzen Anschlussflächen. Seitlich bleibt ein16Studs-Streifen zwischen Gebäude und Grundstücksrand als Zugang zur Anlieferung. Vorplatz, Einfahrt und Zufahrten später in Studio prüfen.

## LC-07-Abgleich

Der aktuelle Stadtplan v2 führt LC-07 bereits mit224×160 und72Studs Höhe, Plotmitte X=-860/Z=-380, FrontWest (gedrehter Platzbedarf160×224). Die älteren Issue-Koordinaten -315/-105 und Höhe38 sind nicht übernommen. Das Modell bleibt für diese Bauphase am lokalen Ursprung. Keine Strassen oder Nachbarplots geändert; Terrainhöhe und tatsächliche Platzierung/Zufahrt bleiben bei Stadtintegration zu prüfen.

## Nachweise

`python3 tools/build_galleria.py --preview` erzeugt Luau, XML, Massbericht und sechs technische Ansichten (Pillow/NumPy für Preview). Geprüft: Parzellengrenzen, Höhe72, dreigeschossige Flügel, zwei Liefertore, freier Eingang und XML-Teilzahl. Lua-Modul geprüft. Keine Roblox-Runtime oder Performanceprüfung. Gate B/Gate C offen.

`dist/LargeCityOceanGalleria_P4.rbxmx` alternativ zur Rojo-Vorschau als statisches Modell importieren, ohne automatisch laufende Scripts. Bilder unter docs/galleria sind technische Renderings, keine Studio-Screenshots.

P5 ergänzt OCEAN GALLERIA-Schrift, Materialien, Ladenwirkung, Beleuchtung und tropische Vorplatzgestaltung. HP/Energie werden vor P6 abgestimmt.

Referenz: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/10
