# Courthouse P5 zur Studio-Abnahme

P4 inklusive korrigierter Anschlüsse zwischen Mittelbau und Flügeln durch Benutzer freigegeben. P5 noch offen.

Ergänzt: heller Beton-/Steinlook, dunkles Metall, Glas, geometrisches Waage-Symbol, eine COURTHOUSE-Schriftfläche, Rampen- und Treppengeländer, fünf warme PointLights, zwei Bänke zum Vorplatz, vier blaue Fahnen, Sträucher und zwei kompakte Palmen. Keine globalen Lighting-Änderungen oder externen Assets.

Rampenpfosten liegen bei Z=-38.3 und -29.7 mit0.4Studs Stärke; die lichte Breite Z=-38..-30 bleibt frei. Dekoration ist verankert und nicht kollidierend. Grundgeometrie bleibt erhalten.

Validierung: tatsächliche Builder-/Dressing-Module in Lua5.4-Hierarchiemock ausgeführt:1157BaseParts, fünf Lichter, eine Schriftfläche mit exakt COURTHOUSE; erneute Anwendung erzeugt keine Duplikate. Der Mock simuliert weder CFrame-Geometrie noch Roblox-Rendering/Physik. Rampenbegehung, Schrift, Symbol und Lichtwirkung müssen in Studio geprüft werden. Gate C im Hauptspiel bleibt offen.

Das P4-XML bleibt ein Geometriearchiv. P5 über die Rojo-Vorschau starten. Importpaket und Gameplay-Werte folgen in P6.
