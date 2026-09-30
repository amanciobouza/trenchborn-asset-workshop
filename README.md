# Large City — vollständige Stadtvorschau

21 Gebäudetypen auf **54 bebauten Parzellen**: 21 Master-Plätze, 33 Kopien. LC-17 bleibt eine Grünreserve. Enthält alle zehn bestehenden und alle elf neu erstellten Gebäudetypen in ihrer bisherigen Grösse.

## In Roblox Studio ansehen

Play stoppen, im Repository-Terminal:

```sh
git fetch origin
git switch --track origin/largecity-city-plan-assembly
```

Rojo weiterlaufen lassen, vollständigen Sync abwarten, Play starten. `default.project.json` bleibt identisch zu den letzten Einzelgebäude-Branches. Auf diesem Branch künftig `git pull --ff-only` verwenden.

Die Vorschau erscheint unter **Workspace → LargeCity_AssembledPreview**. `Buildings` enthält pro Parzelle ein eigenes Modell mit LC-ID im Namen. `PlanMarkers` enthält die Beschriftungen; `Roads` das Strassennetz und die Zugänge. Ein Spawn liegt im Zentrum. In Studio das Stadtmodell auswählen und mit **F** einrahmen, um die ganze Stadt zu sehen. Der Output meldet nach dem Aufbau `Ready: 54 buildings`.

Norden = Roblox −Z = **City**. Süden = Roblox +Z = **Mega City**. Plan-X bleibt Roblox-X, Plan-Z wird negiert. Eingänge zeigen entsprechend N/E/S/W auf die im Plan definierten Zugänge. Die Vorschau liegt auf Y=12, damit Tiefgaragen oberhalb einer üblichen Studio-Baseplate bleiben. Endgültige Terrainhöhe und Weltposition sind noch offen.

## Inhalt und Grenzen

- Alle Quellen sind auf konkrete Commits festgelegt: `docs/city/source-lock.json`.
- Ein Master wird pro Gebäudetyp aufgebaut, danach werden unabhängige Modelle kopiert und als Ganzes gedreht/platziert. Keine Skalierung und keine erneute Dressing-Anwendung nach der Platzierung.
- Stadtplan: `docs/city/city-plan.json`, abgeleitet aus Plan v2.1. Version v5 rückt die Parzellen deutlich zusammen. Gebäudetypen, Ausrichtungen und Stadtteil-/Strassentopologie bleiben erhalten; die Gebäude werden nicht skaliert. Boulevards sind 24 Studs, Nebenstrassen 16 Studs breit. Alte Grundstücksreserven sind auf die gemessene Geometrie mit Rand reduziert. Die vorherige Anordnung ist als `city-plan-v3.json` archiviert.
- Power Utility enthält den vorhandenen Builder und das freigegebene Dressing. Auf seinem Quellbranch fehlt ein eigenständiger Installer; die Stadtvorschau verwendet diese beiden Module direkt.
- Ein korrigierter Quellverweis im Courthouse-Installer: `LargeCourthouse…` → `LargeCityCourthouse…`. Nur die zusammengeführte Fassung ist hier korrigiert; der Einzelbranch bleibt unverändert.
- Bodenplatten haben Aussparungen für alle Grundstücke. Die Tiefgaragen der Residential Towers werden nicht überdeckt. Ältere Gebäude erhalten einen Vorplatz innerhalb ihrer reservierten Parzelle. Strassenkreuzungen bestehen aus überlappungsfreien Flächen.
- Diese Architekturvorschau entfernt `KaijuHouse`-Tags vor dem Einfügen in Workspace. HP/Energie- und Zerstörungsmetadaten der Quellen bleiben erhalten, aber es wird kein Kampf-, Belohnungs- oder Einsturzsystem gestartet. Das Stadion-Pong bleibt ausgeschaltet.
- Gate C bleibt offen. Hauptspiel-Einbindung, Einsturz, Terrain, Strassendetails, finale Bahnanbindung und Performance sind noch zu prüfen. Die Stadt enthält rund **54.600 sichtbare Gebäude-Parts und 352 Lichter**, zusätzlich Boden, Wege und Beschriftungen; keine Aussage zur mobilen Bildrate.

Falls ein alter `WorkshopBootstrap` auf `MarshalRoadblockSpecification` wartet, diesen alten Script im isolierten Vorschauprojekt deaktivieren (`Enabled=false`). Er gehört nicht zu diesem Branch. Unbekannte Studio-Objekte werden nicht automatisch gelöscht. Einen bereits vorhandenen Stadtaufbau überschreibt die Vorschau nicht; eine neue Play-Session verwenden.

## Nachvollziehbare Prüfungen

Benötigt Python 3 und `liblua5.4`. Die Produktion bleibt Luau; nur der lokale Test übersetzt einfache Luau-Zuweisungen für Lua 5.4.

```sh
python3 tools/build_city_plan.py
python3 tools/check_city.py
python3 tools/run_lua.py tests/generated_city_test.lua > docs/city/placement-test.txt
python3 tools/validate_city_layout.py
```

Geprüft mit den tatsächlichen Buildern/Dressings/Installern: 54 vollständige Platzierungen, 21 unterschiedliche Master, unabhängige Kopien, konkrete Modulreferenzen, alle vier Himmelsrichtungen, Höhe/Koordinatentransformation, Ablehnung doppelten Aufbaus und atomarer Abbruch bei fehlenden Abhängigkeiten. Numerische Vektor-/CFrame-Rechnung ergibt keine Gebäudeüberschneidungen, keine Überschneidungen mit den Hauptstrassen und keine überschrittenen Parzellenhüllen. Berichte: `docs/city/placement-report.json` und `placement-test.txt`.

Diese Tests ersetzen keine Roblox-Rendering-, Physik-, Paketimport- oder Performanceprüfung.

Die Verdichtung lässt sich mit `python3 tools/compact_city_plan.py` aus dem archivierten v3-Plan und Messbericht reproduzieren (zusätzlich SciPy erforderlich). Danach Plan generieren und Platzierungsprüfung ausführen.

V5 verdichtet erneut: Mindestabstand zwischen reservierten Grundstücken 4 Studs, zwischen Grundstück und Strasse 2 Studs. Die Optimierung minimiert zusätzlich die Stadtausdehnung. Diese Werte beziehen sich auf Parzellen; Abstand zu Fassaden hängt vom vorhandenen Gebäudevorplatz ab.
