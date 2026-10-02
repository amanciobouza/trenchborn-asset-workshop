# MC-01 Harbor Gate Terminal — erster Modellstand zur Abnahme

Nur dieses Gebäude wird jetzt umgesetzt. MC-02 bis MC-21 warten auf die jeweilige vorherige Nutzerabnahme.

## Stand und technische Entscheidungen

- 216 sichtbare Roblox-Parts, keine Mesh- oder Blender-Abhängigkeit.
- Meerfront zeigt lokal nach -Z, Stadteingang nach +Z; Ursprung auf Bodenhöhe.
- Sockel 168 × 94 Studs. Bauhöhe ca. 110 Studs inklusive Antenne; Treppen ragen an der Stadtseite über den Sockel hinaus.
- Massstab als erster, **noch nicht im Stadtplan abgenommener** Vorschlag; `Scale` im Installer anpassbar.
- `EnergyType = Electric`, `MaxHealth = 1_000_000` als vorläufiger, überschreibbarer Balancewert.
- Materialflächen, geneigte Glasfront, zwei Dachausleger, seitlicher Kontrollturm, Neonbeschriftung, Treppen, Abfahrtsanzeige, Lüfter und Rohre.
- Kein Kai, Meer oder Küstenweg im Modell. Das sind spätere Bestandteile der Stadtumgebung.
- Gate A bestätigt. Gate B (visuell) und Gate C (Spieltest) **offen**. Kein Anspruch auf finale Abnahme oder exakte Übereinstimmung jeder Bildansicht.

## In Roblox Studio ansehen

### Einzeldatei ohne Rojo

`packages/mega-city/01-harbor-gate-terminal.rbxmx` herunterladen. In Studio im Explorer `Workspace` auswählen und über **Insert from File / Aus Datei einfügen** importieren. Das Modell ist sofort im Edit-Modus sichtbar. Im Play-Modus startet sein enthaltenes Server-Script die Gameplay-Schnittstelle.

### Bestehendes Rojo-Projekt

Die vier neuen Module und ein Bootstrap-Script liegen im vorhandenen `src/ReplicatedStorage/TrenchbornAssetWorkshop` und werden vom bestehenden `default.project.json` erfasst. Es wird nichts automatisch in eine bestehende Szene eingesetzt. Nach Sync in der Studio-Command-Bar ausführen:

```lua
local folder = game.ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local model, api = require(folder:WaitForChild("MegaCityHarborGateInstaller")).Install(workspace, {
    GroundCFrame = CFrame.new(0, 0, 0),
    Scale = 1,
})
game:GetService("Selection"):Set({model})
```

Für eine leere separate Testszene: `rojo serve mega-city-harbor.project.json` (Port 34873); diese Projektdatei synchronisiert ausschliesslich die Harbor-Module samt Bootstrap. Wiederholtes Installieren erzeugt bewusst weitere Kopien; die vorherige Testkopie bei Bedarf manuell löschen.

## Gameplay-Vertrag

Modell trägt Tag `KaijuHouse`, Attribute `AssetId`, `EnergyType`, `MaxHealth`, `Health`, `Destroyed`. `MegaCityAPI` enthält serverseitige Bindables:

```lua
local model = workspace:WaitForChild("MegaCityHarborGateTerminal")
local api = model:WaitForChild("MegaCityAPI")
api.EnergyReleased.Event:Connect(function(amount, energyType, source)
    print("Energie bereitstellen", amount, energyType, source)
    -- Hier an die Energie-/Absorptionslogik des Hauptspiels anbinden.
end)
api.ApplyDamage:Invoke(model:GetAttribute("MaxHealth"))
-- Nach dem Kollaps separat ausführen:
-- api.Reset:Invoke()
```

Das gesamte Modell sinkt und kippt gemeinsam, ohne einzelne physikalische Trümmer; danach wird es unsichtbar und nicht kollidierbar. Reset stellt Ausgangsposition und alle Teile wieder her. Keine Remotes oder neuen Client-Schadensrechte. Energie wird **als Event gemeldet**, nicht automatisch einem Spieler gutgeschrieben: floor(MaxHealth^0.75 × 1.2), 40 % sofort und Rest über 15 Ticks à 2 s. Reset/Entfernen bricht ausstehende Ticks ab.

Importdatei initialisiert API im Play-Modus. Installer initialisiert auf einem laufenden Server direkt und gibt `model, api` zurück. Im Edit-Modus gibt er `model, nil` zurück und speichert einen Bootstrap im Modell; dieser initialisiert beim nächsten Play die API. Diese Rojo-Variante benötigt die synchronisierten Module weiterhin. Die `.rbxmx`-Datei ist dagegen vollständig eigenständig.

## Prüfung

`python tools/build_harbor_gate.py` erzeugt Module und `.rbxmx` aus derselben Geometriequelle. `python tools/validate_harbor_gate.py` prüft Export, Part-Budget, orthonormale Transformationen, Referenzen, Attribute und Lua-Syntax (Linux liblua5.4 erforderlich).

Lokale Checks bestanden; Geometrie zusätzlich in zwei Ansichten ausserhalb der Engine inspiziert. Roblox Studio steht in dieser Arbeitsumgebung nicht zur Verfügung. Deshalb ausstehend:

- [ ] Meer- und Stadtseite sowie Dachansicht mit dem Konzept vergleichen.
- [ ] Massstab neben dem grössten Kaiju prüfen.
- [ ] Glas, Schriftlesbarkeit, Neon und Schnee in der tatsächlichen Spielbeleuchtung prüfen.
- [ ] Schaden → einmaliger gemeinsamer Kollaps → Reset in Studio testen.
- [ ] Energie-Events an Hauptspiel anbinden und Kamera/Kollision prüfen.
- [ ] Nutzerabnahme MC-01, erst danach MC-02 beginnen.
