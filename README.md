# Tropical Signal Tower — P5 / Issue #12

Ein Aussichtsturm für LC-41, kein Kit. Gate A/P3 freigegeben; P4-v2 mit verbreitertem Schaft am29.09.2026 vom Nutzer abgenommen. P5 zur visuellen Abnahme. Gesamthöhe400Studs gemäss späterer Präzisierung des Zielbilds.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-tropical-signal-tower-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist bytegleich zum Convention Centre. Wenn noch kein Server läuft: `rojo serve default.project.json` und Studio verbinden. Weitere Updates: `git pull --ff-only` bei gestopptem Play.

Workspace-Modell: `LargeCity_TropicalSignalTower_P5`. Pivot auf GrundstücksmitteY0, Front lokal-Z. Keine Gameplay-Tags oder anderen Gebäude in der Vorschau.

## Masse und Aufbau

| Bereich | Höhenbereich | Masse / Gestaltung |
| --- | --- | --- |
| Sockel |0–32| Rund,80Durchmesser innerhalb80×80; zwei16Studs-Geschosse, Panorama-Fassade und drei offene Eingangsbuchten |
| Schaft |32–336|304hoch,48→22Durchmesser,16Facetten in acht38Studs-Abschnitten; echte durchgehende Verjüngung |
| Kanzel |336–360|72Durchmesser,24hoch inkl. verbreiterter Unterschale336–343, Boden343–344, Glas344–359 und Dach359–360 |
| Plattform |360–368|72Durchmesser, Boden360–362, offenes Geländer bis368; keine Dachhaube |
| Signalaufbau |362–400| Zentraler Sockel beginnt auf Plattform, oberhalb368 bleiben32Studs; Spitze exakt400 |

Türkisring unter der Kanzel beiY342.35 innerhalb ihres Volumens. Dunkler Detailstreifen vor der Schaftoberfläche. Eingangsvordach32×12×2, Unterkante14, zwei Stützen. Grundstück112×112, vier Pflanzinseln ausserhalb des Haupteingangs. Bodenschwelle1Stud; keinen funktionierenden Aufzug oder Zugang zur Plattform zugesagt. P5 ergänzt transparente Panoramafenster, Türkis-Neonring und Spitzlicht, warme Leuchten, vier Palmen und zwei zum Vorplatz gerichtete Bänke.

Schaft-/Unterschalenflächen aus sauber triangulierten WedgeParts, Rundplatten aus nativen Cylindern, übrige Details aus Parts. Abschnitte sind eine interne Gliederung, keine bereits festgelegten Zerstörungsgruppen.

## Stadtplan / Skyline

Aktueller Stadtplan v2.1: LC-41,112×112,H400, PlanmitteX1100/Z460, FrontWest. Alte Issue-Platzhalter510/245,H165 sind überholt. Keine Skalierung auf165, keine Änderung anderer Plots. Modell bleibt am lokalen Ursprung. Terrainhöhe und endgültige Rotation erst bei Stadtintegration.

Vom gleichen lokalen Bodenbezug ist die Spitze72Studs bzw.21.95% höher als der328Studs hohe Office Tower. Die Kanzel beginnt8Studs über dessen Maximum. Das bestätigt den Höhenvergleich, nicht eine freie Sicht bei unterschiedlichem Terrain oder anderen höheren Gebäuden.

## Export / Prüfung

`python3 tools/build_signal.py --preview` erzeugt Luau, statisches `dist/LargeCityTropicalSignalTower_P4.rbxmx`, Massbericht und sechs technische Ansichten inklusive Kanzel-/Sockeldetails. Benötigt NumPy; Preview zusätzlich Pillow. Import des XML alternativ direkt in Studio, ohne automatisch laufende Scripts.1039 BaseParts inklusive GroundPivot.

Geprüft: Grundstücksgrenzen, Gesamthöhe400, Abschnittsbudgets, acht verjüngte Schaftabschnitte, XML-Teilzahl. Builder mit Lua5.4-Hierarchietest ausgeführt. Keine Roblox-Render-/Physik-/Performanceprüfung. Gate B freigegeben; P5-Abnahme, Gate C und HP/Energie/Zerstörung noch offen.

Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/blob/ccaca2cf048f7a696beddb8feed07f8a14803802/docs/assets/large-city/tropical-signal-tower/approved-target-2026-09-27.jpg

Issue: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/12

## Proportionskorrektur vom29.09.2026

Nutzerrückmeldung: Turm wirkt zu dünn, insbesondere unten. Schaft am Fuss von28 auf48Studs Durchmesser verbreitert, oben von18 auf22. An den Höhen32/70/108/146/184/222/260/298/336 sind die Durchmesser48/38/33/30/28/26/24/23/22. Dadurch kräftiger tragender Fuss und nach oben ruhiger auslaufender Schaft. Dunkler Detailstreifen folgt den neuen Flächen; Kanzelunterschale setzt am22Studs-Schaft an. Gesamthöhe400, Sockel80 und Kanzeldurchmesser72 unverändert. Diese Nutzerkorrektur ersetzt die ursprüngliche28→18-Schaftvorgabe. P4-v2 am29.09.2026 freigegeben.

P5 wird über die Rojo-Vorschau erzeugt. Das statische P4-XML bleibt Geometriearchiv.22 schattenlose PointLights; Prüfung in Studio steht aus.
