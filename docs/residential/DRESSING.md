# Residential Tower — Phase 5

Gate B wurde vom Nutzer am27.09.2026 bestätigt. P5-Dressing ist zur visuellen Abnahme vorbereitet.

## Ergänzungen

- Heller Beton und sandfarbene Akzente, dunkle Fenster, Metallgeländer und Dachtechnik.
- Glasfüllungen zwischen den bestehenden Balkon-/Terrassenholmen. Transparenz0.48, keine geänderten Fenstergrössen oder Vorsprünge.
- Zehn abwechselnd platzierte Balkonpflanztröge, vier Pflanztröge auf dem Sockeldach sowie acht auf den Staffelterrassen. Wege und Ecken bleiben frei.
- Erde, Sträucher und drei kleine Bäume in den vorhandenen Bodentrögen. Baumkronen sind gleichmässig runde native Parts, keine externen Meshes.
- Zwei warme Wandleuchten, zwei Vordachlichter und vier dezente Rampenlichter. Insgesamt acht PointLights ohne Schatten; keine Lichter auf jedem Wohngeschoss.
- Gelbe Rampenränder mit gleicher Neigung wie die Fahrbahn, Torlamellen und Lüftungsgitter am Technikaufbau. Keine Toranimation.

914 bestehende Parts +308 Details =1222 Parts inklusive GroundPivot. Grundstück128×112, Balkonvorsprung6 und Höhe232 bleiben bestehen. Das Preview bleibt um12Studs angehoben; die Geländeöffnung für die spätere Garagenrampe ist weiterhin erforderlich.

## Aufbau und Prüfung

`LargeCityResidentialDressing.Apply(model)` ergänzt Details relativ zum Modellpivot und ersetzt bei erneutem Aufruf nur `ResidentialDressing`. Untergruppen verwenden die Namen ihrer tragenden Geschosse/Teilbereiche. Lichter bleiben direkte Kinder ihrer Leuchtenteile. Die P4-Positionen, Grösse und Rotationen werden nicht verändert; nur Materialien werden gesetzt.

Die neue ModuleScript-Datei wird über die bestehende Rojo-Ordnerzuordnung eingebunden. `default.project.json` bleibt unverändert. Preview wartet maximal10Sekunden auf das Modul und gibt bei ausstehendem Sync eine verständliche Meldung aus.

Automatisch geprüft: P4-Geometrieprüfungen erneut bestanden, positive Grössen, eindeutige Dressing-Namen, neue Parts inklusive Rotation innerhalb der Grundstücks-/Höhengrenzen, XML-Roundtrip mit1222Parts und acht schattenlosen Lichtquellen, Glasfüllungen einheitlich2.6Studs hoch/0.48transparent, keine autorun Scripts oder Remote-Assets. Luau-kompatibles Dressing-Modul syntaktisch in Lua5.4 geladen. Technische sechsseitige Geometrievorschau kontrolliert.

Die Vorschau ausserhalb Studio zeichnet Glas deckend und Rundungen als Hüllkörper. Materialwirkung, transparente Überlagerungen, Beleuchtung und Performance sind erst im Studio-Review zu bestätigen. Es wurde keine Engine-/Physik-/Mobile-Abnahme behauptet. HP/Energieart und Gate C bleiben offen.

## Reproduktion

```sh
python3 tools/build_residential_dressing.py --preview
```

Ohne --preview genügen Python-Standardbibliotheken; für die technische Vorschau numpy/Pillow. Aus einer gemeinsamen Definition entstehen Dressing-Luau, statischer `dist/LargeCityResidentialTower_P5.rbxmx`, Prüfbericht und Vorschau. Die P4-Basis bleibt reproduzierbar.
