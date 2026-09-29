# Tropical High-Rise — P5 / Issue #13

Ein eigenes tropisches Hochhaus, kein Kit. Überarbeitete helle Zielbildfassung / Gate A sowie P3 freigegeben; P4 am29.09.2026 vom Nutzer freigegeben; P5 zur visuellen Abnahme.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-tropical-high-rise-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. `default.project.json` ist bytegleich zum Signal Tower. Wenn noch kein Server läuft: `rojo serve default.project.json` und Studio verbinden. Spätere Updates: `git pull --ff-only` bei gestopptem Play.

Workspace-Modell: `LargeCity_TropicalHighRise_P5`, BodenpivotY0 in Grundstücksmitte, Front lokal-Z. Kein anderes Hochhaus wird ersetzt; keine Gameplay-Tags in der P4-Vorschau.

## Masse

| Abschnitt | Masse B×T×H | Höhen | Geschosse |
| --- | --- | --- | ---: |
| Sockel |112×96×36|0–36|2|
| Unterer Turm |88×72×128|36–164|8|
| Mittlerer Turm |72×56×112|164–276|7|
| Oberer Turm |56×40×80|276–356|5|
| Offene Krone |48×32×24|356–380|kein Geschoss|

22 Geschosse,380Studs Gesamthöhe, Grundstück144×128. Alle Turmabschnitte zentriert. Die beiden Haupt-Rücksprünge sind8Studs breit, mit3Studs tiefen Pflanztrögen am äusseren Rand und4.5Studs innerem Streifen vor der nächsten Fassade. Sockeldach zusätzlich12Studs Rücksprung. Pflanztröge und Geländer stehen auf den vorhandenen Dachflächen; keine zusätzliche Geschosshöhe.

Helle5.5Studs-Pfeiler, blaugrüne Scheiben mit eigenen Rahmenöffnungen, geschossweise getrennte Platten/Fassaden. Vordach48×16×3, Unterkante16. Offener mittlerer Eingang, niedrige1Stud-Bodenschwelle. Vereinfachter Lobbykern, keine voll eingerichteten Büros oder Zugangssysteme zu Terrassen. Krone offen mit wenigen Betonstützen und zurückhaltendem Bronze-/Metallrahmen, ohne Antenne oder Dachhaube.

## Stadtplan-Abgleich

Im neueren Stadtplan v2.1 ist ModellN11 Tropical High-Rise bereits als Master auf LC-21 „Crown Financial“ zugeordnet: PlanmitteX240/Z-420, FrontNord,144×128. Das löst die im älteren Issue noch offene Planreferenz auf. Vorschau bleibt am lokalen Ursprung. Keine bestehenden Summit-/Office-Modelle, Strassen oder Nachbarplots verändert. Terrainhöhe, Weltrotation, Skyline und endgültige Platzierung bleiben bei der Stadtintegration zu prüfen.

Signal Tower400 ist vom gleichen Bodenbezug20Studs höher. Unterschiedliche Terrainhöhen sind noch nicht berücksichtigt.

## Export und Abnahme

`python3 tools/build_highrise.py --preview` erzeugt Luau-Builder, statisches `dist/LargeCityTropicalHighRise_P4.rbxmx`, Massbericht und sechs technische Ansichten. Pillow/NumPy für Preview. XML alternativ direkt in Studio importieren; enthält keine automatisch laufenden Scripts.

2153 BaseParts inklusive GroundPivot. Geprüft:22Geschosse mit2/8/7/5-Verteilung, Dimensionen/Zentrierung,380Höhe,8Stud-Rücksprünge, offener Eingang, Parzellengrenzen und XML-Teilzahl. Builder in Lua5.4-Hierarchietest ausgeführt. Keine Roblox-Rendering-/Physik-/Performanceprüfung.

P5 ergänzt transparente blaugrüne Verglasung, bepflanzte Tröge an Sockel und beiden Hauptterrassen, einzelne Palmen, Dachbegrünung, vier Türkis-Akzente an der offenen Krone sowie Bänke und warme Beleuchtung. P4-XML bleibt das statische Geometriearchiv; P5 wird über die Rojo-Vorschau erzeugt. HP/Energie/Zerstörung vor P6 abstimmen. Gate B freigegeben; P5-Abnahme und Gate C offen.

Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/blob/489d33fc98a1a9c71c31aaf2e50bf0ae4dcae090/docs/assets/large-city/tropical-high-rise/approved-target-2026-09-27.jpg

Issue: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/13

P5 umfasst2353 BaseParts und24 schattenlose PointLights. Strukturprüfung mit tatsächlichem Builder/Dressing im Lua5.4-Testdouble bestanden, wiederholtes Apply ohne Duplikate. Glas- und Lichtwirkung sowie Performance in Studio noch zu prüfen.

### P5-v2 / Fehlerbehebung

Color3-Parameterfehler der Lichter behoben; vollständiges Dressing mit12 Palmen,18 bepflanzten Trögen und24 Lichtern. `python3 tools/check_highrise_dressing.py` erzeugt den Lua5.4-Test mit Color3-/Zahlenprüfung. Preview meldet `Tropical High-Rise P5-v2 ready`.

Falls ein alter `ServerScriptService.TrenchbornAssetWorkshop.WorkshopBootstrap` auf `MarshalRoadblockSpecification` wartet: Dieser Script gehört nicht zu diesem isolierten Gebäude-Branch. Im Gebäude-Vorschauprojekt den alten Bootstrap deaktivieren (`Enabled=false`). Unbekannte Studio-Instanzen bleiben durch die bestehende Rojo-Konfiguration erhalten; keine unbekannten Scripts automatisch löschen.
