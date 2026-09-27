# Police HQ Phase 5

Gate B wurde nach der Fassadenkorrektur mit „passt“ freigegeben. P5 ist umgesetzt, visuelle Abnahme noch offen.

- Heller Beton, blaue glatte Bänder, dunkles Glas, Metalldächer und Dachgeräte.
- Eigenes blau-goldenes Schildwappen mit hellem Stern als SurfaceGui ohne Bild-Asset-Abhängigkeit. POLICE-Schriftzug bleibt bestehen.
- Vier HVAC-Geräte, Funkpanels, flache Schüssel mit Feed und Stand, Funkdachgeländer.
- Acht warme Wandlichter und vier feste blaue Warnleuchten: insgesamt zwölf PointLights, keine Schatten. Drei zusätzliche leuchtende Vordachlinsen ohne weitere Lichtquellen.
- Statische weiss-rote Schranke, vier Schutzpoller, gelbe Zufahrtsmarkierungen und Richtungspfeil, seitlicher Zaun.
- Erde und abgerundete Strauchgruppen in den bestehenden Pflanztrögen.

343 vorhandene Parts plus 161 Details = 504 Parts inklusive unsichtbarem GroundPivot. Grundstück 176×128 und Maximalhöhe100 bleiben eingehalten. Alle neuen Details liegen unter PoliceDressing. Schilder und Lichtquellen sind Kinder ihrer Trägerparts. Dressing.Apply arbeitet relativ zum Modellpivot und ersetzt nur den bisherigen Dressing-Ordner.

## Verifikation

P4-Fenster-/Fassadenprüfungen erneut ausgeführt; 12 Frontfenster weiterhin 18×10, ohne bauliche Überdeckung. Export aus derselben Datenliste wie der Luau-Code erzeugt. XML erneut gelesen: 504 Parts, 12 PointLights, zwei SurfaceGuis, keine laufenden Scripts. Luau-kompatibles Dressing-Modul mit Lua5.4 syntaktisch geladen. Alle neuen Parts innerhalb Grundstück und Höhenlimit geprüft. Technische Ansichten kontrolliert; runde Parts sind dort nur als Hüllkörper dargestellt, GUI und Lichtwirkung nicht simuliert.

P5-Import und Aussehen in Roblox Studio stehen noch aus. Keine Behauptung eines Engine-/Performance-/Gameplaytests. Gate C bleibt offen; keine HP oder Energieart gesetzt. Eine bewegliche Schranke, Fahrzeuge und NPCs sind nicht enthalten.

## Reproduktion

`python3 tools/build_police_dressing.py --preview`

Erzeugt P4-Basis, P5-Dressing-Modul, statischen P5-rbxmx-Export, Prüfbericht und technische Vorschau. Ohne --preview sind nur Python-Standardbibliotheken nötig.
