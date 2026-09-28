# Ocean Galleria — P6 / Issue #10

Ein Einkaufszentrum für LC-07, kein Kit. Gate A/P3 freigegeben; P4/Gate B am28.09.2026 vom Benutzer freigegeben; P5 und P6-Werte am28.09.2026 vom Benutzer freigegeben.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-ocean-galleria-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json unverändert vom Bahnhof. Wenn noch kein Server läuft: `rojo serve default.project.json`, dann Studio verbinden. Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace-Modell: `LargeCity_OceanGalleria_L3`. Grundstückspivot Y0, Front lokal -Z.

## Masse / Aufbau

Grundstück224×160; Gebäude192×96. Zwei Flügel je64×96×54 mit drei18Studs-Geschossen. Zentralatrium64×96×72, Dachansatz54, Scheitel inklusive Trägerdicke72. Sieben Querträger, sechs Glasdachfelder. Vordach80×16×4. Zwei Dachaggregate je24×16×8 auf Y54. Geschlossene Fassadenanschlüsse an X±32.

Atriumboden Y1; umlaufende Galerieplatten auf Y18 und36, je10Studs breit, mit grossem Innenraum. Die oberen Galerien dienen der sichtbaren Innenwirkung; Treppen/Einkaufsmechanik sind nicht zugesagt. Freies20Studs-Hauptportal. P5 nutzt transparente Glasflächen und einfache Ladenaufbauten auf allen drei Ebenen.

Rückwärtige Anlieferung64×24 bei X±32/Z48..72. Zwei16×14Studs-Liefertore an den Flügeln, Mitte X±44, mit kurzen Anschlussflächen. Seitlich bleibt ein16Studs-Streifen zwischen Gebäude und Grundstücksrand als Zugang zur Anlieferung. Vorplatz, Einfahrt und Zufahrten später in Studio prüfen.

## LC-07-Abgleich

Der aktuelle Stadtplan v2 führt LC-07 bereits mit224×160 und72Studs Höhe, Plotmitte X=-860/Z=-380, FrontWest (gedrehter Platzbedarf160×224). Die älteren Issue-Koordinaten -315/-105 und Höhe38 sind nicht übernommen. Das Modell bleibt für diese Bauphase am lokalen Ursprung. Keine Strassen oder Nachbarplots geändert; Terrainhöhe und tatsächliche Platzierung/Zufahrt bleiben bei Stadtintegration zu prüfen.

## Nachweise

`python3 tools/build_galleria.py --preview` erzeugt Luau, XML, Massbericht und sechs technische Ansichten (Pillow/NumPy für Preview). Geprüft: Parzellengrenzen, Höhe72, dreigeschossige Flügel, zwei Liefertore, freier Eingang und XML-Teilzahl. Lua-Modul geprüft. Keine Roblox-Runtime oder Performanceprüfung. P5 abgenommen; Gate C offen.

`dist/LargeCityOceanGalleria_P4.rbxmx` alternativ zur Rojo-Vorschau als statisches Modell importieren, ohne automatisch laufende Scripts. Bilder unter docs/galleria sind technische Renderings, keine Studio-Screenshots.

P5 enthält OCEAN GALLERIA-Schrift, Materialien, zwölf Schaufensterszenen,14warme PointLights, zwei Vorplatzbänke, zwei Palmen und Innenpflanzen. Das statische P4-XML bleibt Geometriearchiv; P5 wird über die Rojo-Vorschau erzeugt. P6: 64.000 HP, Electric, drei Zerstörungsbereiche (linker Flügel / Atrium / rechter Flügel).

Referenz: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/10

## P6 / Import

`dist/LargeCityOceanGalleriaPackage.rbxmx` in ReplicatedStorage importieren; enthält vier Module ohne automatisch laufende Scripts. In der Studio Command Bar:

```lua
local package = game.ReplicatedStorage:WaitForChild("LargeCityOceanGalleriaPackage")
local model = require(package.LargeCityOceanGalleriaInstaller).Install(workspace, {
    GroundCFrame = CFrame.new(0, 0, 0),
})
```

`KaijuHouse` liegt nur auf dem Gesamtmodell; MaxHealth=64000, EnergyType=Electric. Keine separaten HP-Pools oder zusätzlichen Energieauszahlungen. Die drei Ordner unter DestructionGroups sind D1_LeftWing (515 Parts), D2_Atrium (506), D3_RightWing (515). Links/rechts aus Sicht vor dem Haupteingang, lokal X negativ/positiv. Die Nummerierung legt keine zeitliche Reihenfolge fest.

Atrium besitzt Glasdach, Galerien, Eingang/Vordach, Schriftzug sowie gemeinsame Grundstücksplatte und mittleren Lieferhof. Seitenflügel besitzen ihre Schaufenster, Dachaggregate, Liefertore und seitliche Vorplatzausstattung. Alle14Lichter und der Schriftzug behalten einen Part als Besitzer. Der unsichtbare GroundPivot bleibt ausserhalb der Gruppen.

Der Installer liefert Metadaten und Gruppierung für das gemeinsame Zerstörungssystem. Er implementiert weder Schaden noch Einsturztrigger oder Animation. Gruppensteuerung, HP/Energieauszahlung, tatsächlicher Einsturz, Kollision und Paketimport sind im Hauptspiel zu prüfen; Gate C bleibt Pending, FinalInstallerReady=false.

Prüfung: `python3 tools/build_galleria_package.py`; Hierarchietest erzeugen mit `python3 tools/check_galleria_contract.py > /tmp/galleria-contract.lua`, danach mit Lua5.4 ausführen. Der Test prüft echte Builder-/Dressing-/Installer-Logik mit Instance-Testdouble, nicht Roblox-Rendering oder Physik.
