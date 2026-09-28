# Gate B — Coast Convention Centre

Issue11, freigegebenes Zielbild26.09.2026. P4 erstellt28.09.2026. Gate B weiterhin Pending.

- Genau zwei offene Hallen mit16Studs-Versatz und bündigem Rückabschluss.
- Hallen96×112×56 und80×96×48, gemeinsames Glasfoyer160×32×36.
-16 geschlossene grosse Dachsegmente, getrennte Rippen/Kanten, links höher als rechts. Keine dritte Halle.
- Vordach112×16×4, V-Stützen, vier gleiche offene Portale.
- Galerie und einfache Treppe, kurzer Verbindungsgang zur zurückgesetzten rechten Halle.
- Grundstück224×224,24Studs rechte Lieferzufahrt,112×24-Hof und drei Tore.
-517 BaseParts inklusive GroundPivot; masshaltiger XML-Export ohne Scripts. Builder durch Lua5.4-Hierarchietest ausgeführt.

Technische Ansichten: geometry-review.png zeigt Front, Rückseite, beide Seiten, erhöhte Front und Draufsicht. geometry-cutaway.png blendet Dächer/Rippen und obere Frontverglasung nur für die Innenraumkontrolle aus. Reproduktion: `python3 tools/build_convention.py --preview`, zusätzlich `--cutaway` für Schnittansicht.

Bewusste Vereinfachungen gegenüber Rendering: acht Dachsegmente je Halle; niedrige Eingangsschwelle statt gestufter Terrasse. Pflanzinseln als Geometrie, Bepflanzung/Schrift/Licht/Glastransparenz folgen in P5. Keine Studio-Screenshots oder Roblox-Physikprüfung. Gate B erst nach Nutzerabnahme, Gate C später im Hauptspiel.

## P4-v2 — Korrektur nach Studio-Rückmeldung

Seitliche Foyerfenster beginnen hinter den Eckpfeilern. Scheiben des Verbindungsgangs liegen zwischen den Stützen und gegenüber deren Aussenfläche zurückgesetzt. Horizontale und vertikale Frontfensterrahmen schliessen ohne flächige Überlappung an. Äussere Dachrippen liegen hinter der Dachblende; verkürzte Segmentenden mit zurückgesetzten Verbindern vermeiden deckungsgleiche Stirnflächen an den Knicken. Hallenwandenden und Endpilaster sind von Front-/Rückwandflächen getrennt. Hauptmasse unverändert. Erneute visuelle Prüfung in Studio erforderlich.
