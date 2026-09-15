# Stufe 5 installieren – Version 1.0.0

Geometrie, Dressing und Gameplay wurden vom Benutzer im Workshop freigegeben. Die Integration in ein anderes Spiel muss dort geprüft werden.

## Studio-Vorschau

1. `dist/KaijuStageFive.rbxmx` in Studio importieren und den Ordner `TrenchbornKaijuStageFive` nach `ReplicatedStorage` verschieben.
2. Die bisherige Workshop-Vorschau und andere Kaiju-Ausrüstungsskripte deaktivieren, damit nur ein Installer die Figur ausrüstet.
3. `examples/KaijuStageFive.server.lua` als Script in `ServerScriptService` einsetzen.
4. Play starten. Das Beispiel rüstet Stufe 5 nach dem Laden des Avatars aus und erzeugt Übungsgebäude. Es läuft ausschliesslich in Studio und behandelt Respawn sowie Aufräumen.

Steuerung: Bewegung, Shift zum Rennen, F für die Combo, Leertaste für Sprung, E für Fokus, R für Fläche.

## Eigenes Spiel

Den Installer vom Server nach dem Laden des Avatars aufrufen:

```lua
local package = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornKaijuStageFive")
local Installer = require(package:WaitForChild("KaijuStageFiveInstaller"))
local model, controller = Installer.Install(character, {
    Scale = 1,
    InstallInput = true,
    CombatFactory = createYourCombatAdapter,
})
-- Zum Entfernen:
-- Installer.Uninstall(character)
```

`createYourCombatAdapter(model, root, humanoid, rootHeight)` ist die eigene Server-Anbindung. Sie muss `Handle`, `Cancel`, `PrepareFinisher`, `FocusAim`, `SelectFocusTarget` und `AreaImpact` liefern. Mit `TraversalTargets` und `StepImpact` wird die gemeinsame Gebäudekollision automatisch aktiviert. Der beiliegende `KaijuStageOneCombat` und das Studio-Beispiel zeigen den vollständigen Vertrag. Schaden, Ziele, Energie und Cooldowns gehören in die Spielanbindung.

Für eine Vorschau ohne Schaden `PreviewOnly=true` statt `CombatFactory` angeben. Mit `InstallInput=false` kann das Spiel eigene Eingaben an `controller.RequestAttack`, `RequestJump`, `SetAirDirection`, `RequestFocus`, `RequestArea` und `SetRunning` anbinden. `controller.Destroy()` entfernt die Ausrüstung und stellt die gespeicherten Avatar-Einstellungen wieder her.

Das Paket enthält alle 20 benötigten Scripts, darunter die beweglichen Segel, Farbwechsel und Ladewelle. Keine Modulabhängigkeit zum Workshop-Ordner ist erforderlich. `KaijuStageFive.manifest.json` enthält die Version und Prüfsummen. Reproduzierbarer Build: `python tools/build-kaiju-stage5.py`.

Prüfungen: eingebettete Quellen und Abhängigkeiten, Lua-Geometrie-/Laufzeitregressionen, Installer-Lebenszyklus mit Mock-Abhängigkeiten. Der Export selbst wurde hier nicht in Roblox Studio ausgeführt.
