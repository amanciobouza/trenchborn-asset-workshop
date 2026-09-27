# Emberline - Phase 4 / Revision v1

## Umgesetzt

- Vier getrennte geschlossene rote Fahrzeugtore mit dunklem Fensterband.
- Fahrzeughalle 96 x 64 x 40 Studs.
- Zweigeschossiger Verwaltungs-Hauptkörper 48 x 64 x 40 Studs, Fensterbänder, Eingang und rotes Vordach.
- Seitlicher Turm 24 x 32 x 96 Studs mit sechs tatsächlich offenen Übungsebenen und gelben Geländern.
- Grundstück 176 x 112, Vorplatz 176 x 40 mit vier getrennten Ausfahrtsmarkierungen.
- Linker Technikstreifen, Dachabschlüsse, Antenne und Fassadenschrift `EMBERLINE RESPONSE HQ`.
- Getrennte Modellgruppen für Halle, Verwaltung, Turm, Turmebenen, Tore, Vorplatz, Technik und Schild.
- Standalone-XML-Modell und reproduzierbarer Luau-Builder aus gemeinsamer Bauquelle.

## Konkretisierte Bauentscheidungen

Alle Masse hier B x T x H; Roblox Vector3 verwendet dagegen X / Y / Z.

| Bereich | X | Z | Y |
| --- | --- | --- | --- |
| Halle | -84 bis 12 | -12 bis 52 | 0 bis 40 |
| Verwaltungs-Hauptkörper | 12 bis 60 | -12 bis 52 | 0 bis 40 |
| Turm | 60 bis 84 | -12 bis 20 | 0 bis 96 |
| Vorplatz | -88 bis 88 | -56 bis -16 | Oberfläche 0,08 |

Die Grundplatte liegt unter Bodenhöhe, von Y=-1 bis 0. Das Vordach ragt vor die Verwaltung in den eigenen Vorplatz. Die sechs Turmbuchten haben einen 14-Stud-Rhythmus. Der Dachabschluss liegt bei 93, die Antennenspitze bei 96 Studs: kleine Aufbauten bleiben damit innerhalb der Gesamt-Turmhöhe.

Die drei Hauptbreiten ergeben zusammen 168 Studs. Im 176-Stud-Grundstück bleiben nur je 4 Studs seitlich. Der linke Technikbereich ist deshalb ein schmaler Schrank-/Zaunstreifen; ein grösserer Technik-Hof wie im perspektivischen Zielbild passt nicht zusätzlich neben die freigegebenen Baumasse. Diesen Punkt bei Gate B besonders beurteilen.

## Prüfergebnis und Grenzen

Die automatischen Prüfungen bestätigen positive Partgrössen, eindeutige Namen, Grundstücksgrenzen, Hallen- und Turmabmessungen, vier Tore, sechs Ebenen, XML-Lesbarkeit und übereinstimmende Partanzahl. Alle Part-Oberkanten liegen bei höchstens 96 Studs. 236 Parts einschliesslich unsichtbarem Pivot. Ein Performancebudget ist damit nicht als freigegeben behauptet.

Die technischen Ansichten zeigen die massgeblichen Baukörper und das Verhältnis 40 zu 96 Studs. Die Vorlage bleibt die [freigegebene hohe Turmfassung](https://github.com/amanciobouza/trenchborn-asset-workshop/blob/c022617aa7ea928ccc15c967a2e6c9acc521ee8b/docs/assets/large-city/fire-station/emberline-approved-target-2026-09-26.jpg). Der Stand ist eine erste Geometrie zur Abnahme, keine Behauptung vollständiger Bildgleichheit.

Strukturelle Eckverbindungen und Wand-/Deckenanschlüsse überlappen konstruktiv. Der geschlossene Eingangsrahmen sitzt vor der Fensterfront. Ein vollständiger Kollisions- und Z-Fighting-Test in der Engine steht aus.

- [ ] Import in ein leeres Roblox-Studio-Projekt und Pivot prüfen.
- [ ] Front, Rückseite, beide Seiten und Dreiviertelansicht gegen das freigegebene Zielbild prüfen.
- [ ] Sechs Turmbuchten, Eingangsproportionen und linken Technikstreifen abnehmen.
- [ ] Oberfläche, Fugen, Durchdringungen und Kollisionen in Studio kontrollieren.
- [ ] Gate B ausdrücklich freigeben oder Korrekturen festhalten.

P5 ergänzt Materialausarbeitung, Feuerwehrsymbole, Beleuchtung, Warnleuchten, Poller, Dachtechnik und kleine Pflanztröge. P6 legt freigegebene HP/Energie und die tatsächliche Zerstörungsintegration fest. Gate B und Gate C bleiben offen.

Technische Enum-Referenzen für den Export: [Material](https://create.roblox.com/docs/reference/engine/enums/Material), [Font](https://create.roblox.com/docs/reference/engine/enums/Font), [NormalId](https://create.roblox.com/docs/reference/engine/enums/NormalId).
