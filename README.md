# Courthouse — P4 / Issue #8

Ein Gerichtsgebäude für LC-34, kein Kit. Gate A und P3 freigegeben; P4/Gate B wartet auf visuelle Studio-Abnahme.

## Studio

Play stoppen:

```sh
git fetch origin
git switch --track origin/largecity-courthouse-l3
```

Rojo weiterlaufen lassen, Sync abwarten, Play starten. default.project.json ist unverändert vom Hotel-Branch übernommen. Falls kein Server läuft: `rojo serve default.project.json`, dann Studio verbinden. Spätere Updates: Play stoppen → `git pull --ff-only` → Sync → Play.

Workspace: `LargeCity_Courthouse_P4`. Grundstückspivot Y0, Front lokal -Z. Endgültige Stadtplatzierung folgt später.

## Geometrie

Grundstück 192×144; Vorplatz Y0, Plateau Y8. Mittelbau 64×80×72 bis Y80, Seitenflügel je48×72×60 bis Y68. Drei Geschosse. Alle Dachgesimse sind in den Höhen enthalten. Vorhalle 64×20×48 bis Y56. Genau sechs runde Säulen mit maximal6Studs Durchmesser und40Studs Gesamthöhe: Basis3 + Schaft34 + Kapitell3. Schaftdurchmesser5.

Freitreppe 72×24×8 mit16 Stufen à0.5 Höhe und1.5 Tiefe. Seitliche Rampe rechts:48Studs Lauf,8Studs lichte Breite, Steigung1:6. Verlauf von X84/Y0 zu X36/Y8, Z=-38..-30. Ein4Studs langes Podest schliesst lückenlos an die Vorhalle bei X32 an. Geländer folgen in P5 ausserhalb der lichten Breite. Spielbarkeit von Rampe, Treppe und Säulenzwischenräumen muss in Studio geprüft werden.

Heller Stein, dunkle Fenster und Rahmen als Grundfarben. Waage-Symbol, COURTHOUSE-Schriftzug, Geländer, Licht, Bänke, tropische Pflanzen und blaue Fahnen folgen in P5. Keine eingerichteten Gerichtssäle. HP/Energie werden vor P6 abgestimmt; später eine gemeinsame Ganzgebäude-Zerstörungsgruppe.

## Export / Nachweise

`dist/LargeCityCourthouse_P4.rbxmx`: statisches Geometriemodell, keine automatisch laufenden Scripts. Alternativ zur Rojo-Vorschau importieren.

`python3 tools/build_courthouse.py --preview` reproduziert Lua, XML, Massbericht und sechs technische Ansichten. Vorschau benötigt Pillow/NumPy. Ansichten sind keine Studio-Screenshots. Prüfungen: Parzellengrenzen, sechs Säulen, Höhenbezüge, Stufen, Rampenfreiraum und Anschluss, XML-Teilzahl. Lua-5.4-Modulprüfung bestanden. Roblox-Runtime, Bewegung, Performance und Kollaps bleiben ungeprüft; Gate B und Gate C offen.

Spezifikation/Zielbild: https://github.com/amanciobouza/trenchborn-asset-workshop/issues/8
