# Emberline - Phase 5 / Revision v1

Die P4-Geometrie und der Studio-Import wurden am 27.09.2026 vom Nutzer bestätigt: „ich seh es jetzt. passt“. Gate B ist freigegeben; die Phase-5-Ausgestaltung wartet auf Sichtprüfung in Studio.

## Ergänzt

- Heller Beton, rote lackierte Metallflächen, anthrazitfarbene Dächer, dunkles Glas und metallische Technikdetails.
- Drei stilisierte weisse Flammen auf rotem Schild: Verwaltung, Turmseite und Hallenseite. Die Symbole bestehen aus eigenen SurfaceGui-Formen und brauchen keine hochgeladenen Bilder oder fremden Asset-IDs.
- Vier Dachlüftungsgeräte mit Lamellen und zwei zusätzliche kurze Verwaltungsantennen.
- Sieben gelb-schwarze Schutzpoller vor den Hallenpfeilern und seitlich des Eingangs.
- Zwei kleine bepflanzte Tröge seitlich des Zugangs.
- Acht warme Wand-/Eingangsleuchten sowie vier dezente rote Dachwarnleuchten. Alle zwölf PointLights haben kurze Reichweiten und deaktivierte dynamische Schatten. Keine Blink- oder Frame-Schleifen.
- Fassadenbänder an Seiten und Rückseite. Die vorhandene Schrift bleibt exakt `EMBERLINE RESPONSE HQ`.

## Aufbau und Aktualisierung

`LargeCityEmberlineGoldenMaster` baut weiterhin die freigegebene P4-Geometrie. `LargeCityEmberlineDressing.Apply(model)` ergänzt die P5-Gruppe `EmberlineDressing`, weist Materialien zu und aktualisiert den Status. Erneutes Anwenden ersetzt nur diese verwaltete Detailgruppe. Der aktuelle Modell-Pivot wird bei allen neuen Parts berücksichtigt.

Das Preview-Script verwendet einen vorhandenen P4-/P5-Modellstand oder erzeugt genau ein neues Modell. Danach heisst es `LargeCity_EmberlineResponseHQ_P5`. In Studio zuerst den Play-Modus beenden, nach `git pull --ff-only` Rojo synchronisieren lassen und Play erneut starten. So werden auch die Module neu geladen.

Bei `Infinite yield` bzw. einem fehlenden `LargeCityEmberlineDressing`: den Rojo-Server im Terminal mit Ctrl+C beenden, `git pull --ff-only` und `rojo serve default.project.json` ausführen. In Studio die Verbindung auf Port 34872 neu herstellen und synchronisieren. Vor Play muss `ReplicatedStorage > TrenchbornAssetWorkshop > LargeCityEmberlineDressing` als ModuleScript sichtbar sein. Das Preview-Script wartet höchstens zehn Sekunden pro Abhängigkeit und nennt bei fehlender Synchronisierung die nötigen Schritte; die P4-Geometrie bleibt bei fehlendem Dressing sichtbar.

Der aktuelle Direktimport ist `dist/LargeCityEmberlineResponseHQ_P5.rbxmx`. Der frühere P4-Export bleibt als historischer Vergleich erhalten; beide Dateien sind Entwicklungsstände desselben Gebäudes, keine zusätzlichen Stadtinstanzen.

## Prüfung

- 351 Parts inklusive Pivot, davon 115 ergänzte Details.
- Vier Tore, sechs Turmebenen und 96 Studs Gesamthöhe bleiben erhalten.
- Alle Details liegen innerhalb des Grundstücks 176 x 112.
- Dachgeräte ragen lokal über die 40-Stud-Hallendächer; höchste Anlage bleibt der 96-Stud-Turm.
- Poller stehen vor den Pfeilern und ausserhalb der Torbreiten; Pflanztröge liegen seitlich des Eingangsweges.
- XML-Export und Prüfdaten werden zusammen mit dem Luau-Dressing aus derselben Quelle generiert.

Die technische Vorschau rendert Geometrie und Grundfarben, aber keine Roblox-Materialtexturen, Lichtwirkung, Schrift oder SurfaceGui-Symbole. Sie ersetzt die Prüfung in Studio nicht.

- [ ] P5-Import bzw. Rojo-Aufbau in Studio bestätigen.
- [ ] Symbole und Schrift aus der Spielkamera und auf Mobile beurteilen.
- [ ] Tages-/Nachtwirkung und Performance der Leuchten prüfen.
- [ ] Durchgänge, Poller und Pflanztröge im Spiel kontrollieren.

P6-Spielwerte, `KaijuHouse`, Schadenszustände und die tatsächliche Zerstörungseinbindung bleiben offen. Details und Leuchten sind ihren Parts untergeordnet; ihr korrektes Entfernen durch das Spielsystem muss in P6 getestet werden. Keine vorzeitige Gate-C-Freigabe.
