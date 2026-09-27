# Large City Office Tower — P6

Isolierte Geometrie-Vorschau für Issue #6, Layout LC-19. Gate A und P3 freigegeben; P4/Gate B am 27.09.2026 vom Benutzer freigegeben. P5-Dressing und P6-Werte vom Benutzer freigegeben. P6-Metadaten und Importpaket umgesetzt. Gate C im Hauptspiel bleibt offen.

## Studio

Play stoppen. Vom Residential-Branch wechseln:

```sh
git fetch origin
git switch --track origin/largecity-office-tower-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. Die default.project.json ist bytegleich mit dem aktuellen Residential-Branch. Falls noch kein Server läuft: `rojo serve default.project.json`, Studio verbinden. Bei späteren Updates: Play stoppen → `git pull --ff-only` → Sync abwarten → Play.

In Workspace erscheint `LargeCity_OfficeTower_L3`. Vorderseite ist lokal -Z, Bodenpivot Y=0. Die Stadtplatzierung erfolgt später. Die Vorschau erzeugt genau dieses Gebäude.

Alternativ `dist/LargeCityOfficeTower_P4.rbxmx` als statisches Modell importieren, ohne parallel die Vorschau zu starten.

## Umfang

18 Geschosse: 2 Podiumgeschosse à 18 Studs, 16 Bürogeschosse à 16 Studs. Podium 104×88×36, Turmkörper 72×64×256, Krone 72×64×32. Dachkante 324, Rippen maximal 328 Studs. Zwei Fassadenrippen je 4 Studs breit und 3 Studs vorstehend, geschossweise segmentiert. Parzelle 144×128. Eingang mit zurückgesetzter Lobby und Vordach 40×12×3; seitliche Anlieferung. Dachtechnik liegt innerhalb der Krone.

P5 ergänzt hellen cremefarbenen Betonsockel, blaues Architekturglas, weissliche Metallrahmen und eine helle Dachkrone, fünf stilisierte Palmen, zwei Holzbänke und acht warme Lichtquellen. Keine Änderungen an globaler Beleuchtung. Das statische XML bleibt der archivierte P4-Stand; die aktuelle P6-Version wird via Rojo durch den Installer erzeugt. 64’000 HP, Electric, KaijuHouse-Tag und eine gemeinsame Zerstörungsgruppe D1_WholeBuilding. Der eigentliche Kollaps wird vom gemeinsamen Hauptspiel-System ausgeführt.

## Reproduktion und Prüfung

`python3 tools/build_office.py` erzeugt Luau, XML und Massprüfbericht. Mit `--preview` zusätzlich sechs technische Ansichten (Pillow und NumPy erforderlich).

Mass-/Volumenprüfungen, XML-Roundtrip und Lua-5.4-Syntaxprüfung bestanden: 989 BaseParts inklusive unsichtbarem Pivot. Siehe `docs/office/geometry-checks.json` und `docs/office/geometry-review.png`. Diese Ansichten sind technische Renderings, keine Studio-Screenshots. Roblox-Runtime, Kollaps, Kampf und Performance noch nicht getestet.

Referenz: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/6

## Import in ein anderes Studio-Projekt

`dist/LargeCityOfficePackage.rbxmx` importieren. Das Paket enthält vier ModuleScripts und startet nichts automatisch. In der Command Bar ausführen:

```lua
require(workspace.LargeCityOfficePackage.LargeCityOfficeInstaller).Install(workspace)
```

Optional `Install(workspace, {GroundCFrame=CFrame.new(x,y,z)})` für die Platzierung. Bodenpivot Y=0, Front lokal -Z. Bestehende gleichnamige Gebäude werden nicht überschrieben. Installation setzt MaxHealth=64000 und EnergyType="Electric" und fügt erst nach vollständiger Zuordnung den KaijuHouse-Tag hinzu. Kein eigener Schadens-, Energieauszahlungs- oder Kollapsloop.

P6-Vertragsprüfung: 1’102 BaseParts inklusive Pivot, 1’101 Teile in D1_WholeBuilding, acht zugeordnete Lichter; wiederholtes Attach erhält Health; unbekannte Geometrie wird vor Umbau abgewiesen. Getestet mit Lua-5.4-Hierarchiemock aus den tatsächlichen Builder-/Dressing-Modulen, ohne Roblox-Physik. Paket-XML enthält vier vollständig zurückgelesene Module. Studio-Import und Hauptspieltest sind noch offen (Gate C).

Reproduktion: `python3 tools/build_office_package.py`. Vertragsprüfung: `python3 tools/check_office_contract.py > office-test.lua`, danach `lua office-test.lua` mit Lua 5.4.
