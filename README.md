# Coast Convention Centre — P6 / Issue #11

Ein Kongresszentrum für LC-08, kein Kit. Gate A/P3 sowie P4-v2/Geometrie am28.09.2026 vom Benutzer freigegeben; P5 sowie P6 mit64.000 HP, Electric und drei Zerstörungsbereichen am28.09.2026 freigegeben. Eigenständiger Branch `largecity-coast-convention-centre-l3`.

## Studio

Play stoppen, dann:

```sh
git fetch origin
git switch --track origin/largecity-coast-convention-centre-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. `default.project.json` ist bytegleich zur Galleria: bei bereits laufendem Server kein Neustart. Wenn noch kein Server läuft: `rojo serve default.project.json` und Studio verbinden. Weitere Updates mit `git pull --ff-only` bei gestopptem Play.

Workspace-Modell: `LargeCity_CoastConventionCentre_L3`. Grundstückspivot Y0, Front lokal -Z. P6-Vorschau setzt KaijuHouse und die freigegebenen Gameplay-Metadaten.

## Aufbau und Masse

Grundstück224×224. Gemeinsames Foyer160×32×36 bei X±80/Z-64..-32, zwei18Studs-Ebenen. Links HalleA96×112×56 bei X-88..8/Z-32..80; rechts HalleB80×96×48 bei X8..88/Z-16..80. Die zweite Halle beginnt16Studs weiter hinten; beide enden beiZ80. Ein72×16-Verbindungsgang zwischen Foyer und rechter Halle löst den Versatz auf. Keine dritte Veranstaltungshalle.

Zwei geschlossene Metalldächer, jeweils acht grosse geknickte Segmente als vereinfachte Wellenkurve. Gesamthöhen inklusive Dach56/48. Je fünf Querrippen, dunkle Dachkanten und V-Streben hinter den oberen Glasbändern. Hallen bleiben offen, ohne Messestände. Linkes und rechtes Dach steigen nach rechts an und flachen am höchsten Punkt ab, entsprechend Zielbild.

Vordach112×16×4, UnterkanteY28, mit zwei V-Stützen. Vier gleich breite offene Eingangsportale. FoyergalerieY18..19, hinten8Studs breit, Seitenarme8, vereinfachte Treppe links. BödenY0..0.5; dadurch nur niedrige Schwelle statt erhöhtem Vorplatz mit langer Treppe. Galerie, Treppe und Schwellen in Studio auf Begehbarkeit prüfen.

Anlieferungsfläche112×24 hinter den Hallen (X±56/Z80..104). Drei16×18-Liefertore, MittelpunkteX-44/-12/44. Rechte Lieferzufahrt24Studs breit (X88..112), mit Queranschluss an den Lieferhof. Pflanzinseln liegen ausserhalb dieser Zufahrt und der Eingangswege.

## Stadtplan

Stadtplan v2.1: LC-08, Plot224×224, Höhe56, PlanmitteX=-860/Z=-40, FrontWest. Damit stimmen die neuen Masse bereits mit dem aktuellen Plan überein. Veraltete Issue-Platzhalter(-335/115,H46) wurden nicht übernommen. Plan-Z ist Norden; Weltrotation und Terrainhöhe erst bei Stadtintegration festlegen. Hier bleibt das Modell am lokalen Ursprung; keine Strassen oder Nachbarplots geändert.

## Nachweise und Export

`python3 tools/build_convention.py --preview` erzeugt Builder, statisches `.rbxmx`, Massbericht und sechs technische Ansichten. Preview benötigt NumPy/Pillow. Geprüft: Grundstücksgrenzen, Dachhöhen, Hallenmasse,16Studs-Versatz, bündiger hinterer Abschluss, drei Tore, freie Eingangsportale und XML-Teilzahl. Keine Roblox-Laufzeit/Physikprüfung.

`dist/LargeCityCoastConventionCentre_P4.rbxmx` kann alternativ direkt in Studio importiert werden. Enthält nur das statische Modell, keine automatisch laufenden Scripts. Das statische P4-XML bleibt Geometriearchiv. Die Rojo-Vorschau ergänzt in P5 transparente Glasflächen, Metallmaterialien, den Schriftzug COAST CONVENTION CENTRE direkt auf dem Vordach,21 warme PointLights ohne Schatten, zwei zum Vorplatz gerichtete Bänke, drei Palmen und zurückhaltende Bepflanzung. P6 nutzt insgesamt64.000 HP und Electric. Gate B/P5 freigegeben; Gate C offen.

Verbindliches Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/blob/f34d5e371d0397aaf06561d7c7c0c592d6ef5e88/docs/assets/large-city/coast-convention-centre/approved-target-2026-09-26.jpg

Issue: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/11

## P6 / Importpaket

`dist/LargeCityCoastConventionCentrePackage.rbxmx` in ReplicatedStorage importieren. Vier Module, keine automatisch laufenden Scripts. In der Studio Command Bar:

```lua
local package = game.ReplicatedStorage:WaitForChild("LargeCityCoastConventionCentrePackage")
local model = require(package.LargeCityCoastConventionCentreInstaller).Install(workspace, {
    GroundCFrame = CFrame.new(0, 0, 0),
})
```

Gesamtmodell: Tag `KaijuHouse`, MaxHealth=64000, EnergyType=Electric. Keine separaten HP-Pools oder mehrfachen Energieauszahlungen. Unter DestructionGroups:

| Bereich | Teile | Zuordnung |
| --- | ---: | --- |
| D1_Foyer |205| Foyer, Galerie/Treppe, Verbindungsgang, Vordach/Schrift, Vorplatz/Bepflanzung, gemeinsame Grundstücksplatte und Zufahrtsflächen |
| D2_MainHall |207| Linke grosse Halle, gemeinsame Trennwand, grosses Dach/Rippen, Hallenlampen und zwei linke Liefertore samt Lampen |
| D3_SecondHall |195| Rechte kleinere Halle, kleines Dach/Rippen, Hallenlampen und rechtes Liefertor samt Lampe |

608 BaseParts inklusive unsichtbarem GroundPivot ausserhalb der Gruppen.21 Lichter:14/4/3 je Bereich; Schriftzug im Foyer. Die Nummerierung definiert keine zeitliche Reihenfolge. Der Installer liefert die Gruppierung an das gemeinsame Hauptspiel-System, keinen eigenen Schadens- oder Einsturzcontroller.

Geprüft: Paketquellen entsprechen vier Modulen, Builder/Dressing/Installer im Lua5.4-Hierarchietest, alle607 sichtbaren Parts zugeordnet, Gruppen-Cleanup, erneutes Attach erhält Health, unbekannte Parts werden vor Hierarchieänderung abgelehnt, öffentlicher Install-Aufruf und doppelte Installation geprüft. Test erzeugen mit `python3 tools/check_convention_contract.py > /tmp/convention-contract.lua`; mit Lua5.4 ausführen.

Offen im Hauptspiel: Import, Rendering/Physik, Teilzerstörungssteuerung, Schaden/Energie und Performance. Gate C Pending, FinalInstallerReady=false.
