# Residential Tower — P4 Review

Gate A und P3 sind laut Issue5 freigegeben. Gate B wurde vom Nutzer am 27.09.2026 freigegeben.

## Vorprüfung

Main und Branchliste am27.09.2026 geprüft. Der bestehende Branch `largecity-uptown-residences-l3` wurde anhand seiner Spezifikation abgeglichen: LC-53, 92Studs, zwei versetzte obere Flügel mit Gartenschlitz. Das ist das separate Bestandsgebäude Uptown Residences, nicht der in Issue5 freigegebene 232-Stud-Turm. Dessen Dateien bleiben unverändert. Neuer isolierter Branch `largecity-residential-tower-l3` auf main; explizite Rojo-Zuordnung ausschliesslich zum Residential-Preview. Vorhandene GoldenMaster-, XML- und Review-Konventionen übernommen.

## Geometrie

B×T×H in Studs, Front lokal-Z, Grundstückspivot(0,0,0):

| Bauteil | Grösse | Lokale Höhen |
| --- | --- | --- |
| Sockel | 96×80×32 | 0–32, zwei Geschosse |
| Regulärer Turm ohne Balkone | 64×56×160 | 32–192, zehn Geschosse |
| Staffelgeschoss1 | 56×48×16 | 192–208 |
| Staffelgeschoss2 | 48×40×16 | 208–224 |
| Technikblock | 24×16×8 | 224–232 |
| Grundstück | 128×112 | BodenY0, Platte bis-1 |

Turm/Sockel sind auf X=-6,Z=4 zentriert, damit rechts Platz für die Rampe bleibt. Das ist eine technische Detailentscheidung innerhalb des freigegebenen Grundstücks. Die Terrassen entstehen durch die echten Rücksprünge. Reguläre Balkone ragen6Studs über die Turmhülle; links/rechts wechseln die Eckrückläufe geordnet. Drei Fensterfelder pro langer Fassade, getrennte Pfeiler und zurückgesetzte Fensterscheiben. Geschosskanten, Balkone und Terrassenplatten bleiben eigenständige Parts.

P4-Geländer bestehen aus gut sichtbaren Holmen und Pfosten; Füllungen und Pflanzen werden in P5 ergänzt. Keine Innenraumausstattung, Fahrzeuge oder Antennen.

## Garagenrampe / spätere Einbettung

- Offene Rampe X44..62, abZ-48 beiY0, endet beiZ0/Y-8, Steigung1:6.
- Untere ebene Fläche bisZ16, geschlossenes Tor am Ende. Kein unterirdisches Parkhaus.
- Stützwände seitlich bisY-9. Die eigene Grundstücksplatte ist im Rampenbereich tatsächlich ausgespart.
- Für Stadtintegration muss das Gelände im lokalen Bereich X44..62, Z-48..16, Y-9..0 frei sein. Je nach Terrain/Voxelauflösung angrenzende Stützwände berücksichtigen. Dieser Branch schneidet kein fremdes Gelände automatisch.
- In der Workshop-Vorschau liegt der GroundPivot beiWeltY12, damit eine normale Baseplate die Geometrie nicht verdeckt. Der eigentliche Builder nimmt `GroundCFrame` entgegen und korrigiert nicht automatisch nach BoundingBox-Unterkante.

## Prüfungen

Generator prüft14Geschoss-Hüllen, zehn reguläre Wohngeschosse, beide Staffelungen, positive Abmessungen, eindeutige Namen, Grundstücksgrenzen mit voller Rampenrotation, 232Studs Maximalhöhe und getrennte Fenster-/Pfeilervolumen. Vierzig Front-/Rückbalkone besitzen exakt6Studs Ausladung; zusätzliche wechselnde Eckbalkone ebenfalls6Studs. Native XML erneut geparst: 914Parts, kein Script/LocalScript. Lua-Build-Modul syntaktisch unter Lua5.4 geladen. Sechs technische Ansichten aus der identischen Geometrieliste geprüft.

Absichtliche Anschlüsse: Balkonplatten schliessen an die Geschossplatte an; die ersten Balkone liegen auf dem Sockeldach. Terrassen decken nur die freien Dachringe ausserhalb der nächsthöheren Hülle. Fassadenpfeiler, Scheiben und Decken enden an ihren Anschlussflächen. Eingangsvordach und Türgriffe sitzen vor der Lobby.

Die Bilder sind technische Geometrievorschauen, keine Studio-Screenshots. Tatsächliche Darstellung, Rampenkollisionen, Mobile-Lesbarkeit und Performance müssen in Studio geprüft werden. P4-Geometrie ist freigegeben; P5-Abnahme und Gate C sind noch offen. P6 soll dem vereinfachten bisherigen Ablauf folgen: ein Gebäude als Ganzes; HP/Energieart erst später abstimmen.
