# Coast Convention Centre — P4 / Issue #11

Ein Kongresszentrum für LC-08, kein Kit. Gate A/P3 freigegeben, P4 zur visuellen Abnahme. Eigenständiger Branch `largecity-coast-convention-centre-l3`.

## Studio

Play stoppen, dann:

```sh
git fetch origin
git switch --track origin/largecity-coast-convention-centre-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. `default.project.json` ist bytegleich zur Galleria: bei bereits laufendem Server kein Neustart. Wenn noch kein Server läuft: `rojo serve default.project.json` und Studio verbinden. Weitere Updates mit `git pull --ff-only` bei gestopptem Play.

Workspace-Modell: `LargeCity_CoastConventionCentre_P4`. Grundstückspivot Y0, Front lokal -Z. Vorschau hat keine Gameplay-Tags und verändert kein anderes Gebäude.

## Aufbau und Masse

Grundstück224×224. Gemeinsames Foyer160×32×36 bei X±80/Z-64..-32, zwei18Studs-Ebenen. Links HalleA96×112×56 bei X-88..8/Z-32..80; rechts HalleB80×96×48 bei X8..88/Z-16..80. Die zweite Halle beginnt16Studs weiter hinten; beide enden beiZ80. Ein72×16-Verbindungsgang zwischen Foyer und rechter Halle löst den Versatz auf. Keine dritte Veranstaltungshalle.

Zwei geschlossene Metalldächer, jeweils acht grosse geknickte Segmente als vereinfachte Wellenkurve. Gesamthöhen inklusive Dach56/48. Je fünf Querrippen, dunkle Dachkanten und V-Streben hinter den oberen Glasbändern. Hallen bleiben offen, ohne Messestände. Linkes und rechtes Dach steigen nach rechts an und flachen am höchsten Punkt ab, entsprechend Zielbild.

Vordach112×16×4, UnterkanteY28, mit zwei V-Stützen. Vier gleich breite offene Eingangsportale. FoyergalerieY18..19, hinten8Studs breit, Seitenarme8, vereinfachte Treppe links. BödenY0..0.5; dadurch nur niedrige Schwelle statt erhöhtem Vorplatz mit langer Treppe. Galerie, Treppe und Schwellen in Studio auf Begehbarkeit prüfen.

Anlieferungsfläche112×24 hinter den Hallen (X±56/Z80..104). Drei16×18-Liefertore, MittelpunkteX-44/-12/44. Rechte Lieferzufahrt24Studs breit (X88..112), mit Queranschluss an den Lieferhof. Pflanzinseln liegen ausserhalb dieser Zufahrt und der Eingangswege.

## Stadtplan

Stadtplan v2.1: LC-08, Plot224×224, Höhe56, PlanmitteX=-860/Z=-40, FrontWest. Damit stimmen die neuen Masse bereits mit dem aktuellen Plan überein. Veraltete Issue-Platzhalter(-335/115,H46) wurden nicht übernommen. Plan-Z ist Norden; Weltrotation und Terrainhöhe erst bei Stadtintegration festlegen. Hier bleibt das Modell am lokalen Ursprung; keine Strassen oder Nachbarplots geändert.

## Nachweise und Export

`python3 tools/build_convention.py --preview` erzeugt Builder, statisches `.rbxmx`, Massbericht und sechs technische Ansichten. Preview benötigt NumPy/Pillow. Geprüft: Grundstücksgrenzen, Dachhöhen, Hallenmasse,16Studs-Versatz, bündiger hinterer Abschluss, drei Tore, freie Eingangsportale und XML-Teilzahl. Keine Roblox-Laufzeit/Physikprüfung.

`dist/LargeCityCoastConventionCentre_P4.rbxmx` kann alternativ direkt in Studio importiert werden. Enthält nur das statische Modell, keine automatisch laufenden Scripts. P4 nutzt Grundfarben; transparente Materialien, Schriftzug COAST CONVENTION CENTRE, Licht, Bänke und Palmen folgen nach Geometriefreigabe in P5. HP/Energie und Zerstörung werden vor P6 abgestimmt. Gate B und Gate C offen.

Verbindliches Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/blob/f34d5e371d0397aaf06561d7c7c0c592d6ef5e88/docs/assets/large-city/coast-convention-centre/approved-target-2026-09-26.jpg

Issue: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/11
