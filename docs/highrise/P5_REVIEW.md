# P5 – Tropical High-Rise

P4/Gate B am29.09.2026 freigegeben. P5 zur visuellen Prüfung.

Transparente blaugrüne Glasfelder, warmer heller Beton, dunkle Rahmen und sparsame Bronze. Alle bestehenden Pflanztröge begrünt: Sockeldach, beide8Stud-Hauptterrassen, obere Dachzone und Vorplatz.12 kleine Palmen verteilt auf diese Bereiche; keine Balkone pro Geschoss. Innenliegende Wege zwischen Trögen und nächster Fassade bleiben auf Bodenhöhe frei.

Vier Türkis-Streifen berühren die vorhandenen inneren Kronenpfosten. Keine Zusatzhöhe über380.24 schattenlose PointLights:4 Krone,2 Vordach,8 Lobby,6 Terrassen,4 Vorplatz. Zwei Bänke mit Lehnen zum Gebäude und Sitzrichtung Vorplatz(-Z).

2353 BaseParts,24 Lights. Lua5.4-Hierarchietest führt echte Builder-/Dressing-Module aus; alle Leuchten haben einen Part als Besitzer, wiederholte Anwendung ohne Duplikate. Neue Parts tragen DressingOwner als Zuordnung zum tragenden Bereich. Testdouble simuliert keine Roblox-Transforms, Physik oder Lichtwirkung.

In Studio prüfen: Zusammengehörigkeit zur hellen tropischen Stadt, Glaswirkung, Terrassenpflanzen, offene Krone und Beleuchtung. HP/Energie/Zerstörung vor P6 abstimmen; Gate C Pending.

## P5-v2 – Studio-Fehler korrigiert29.09.2026

Die bisherige Lichtfunktion erwartete Color3, erhielt aus den Aufrufen jedoch die Reichweite. Dadurch brach Apply beim ersten Kronenlicht ab; Pflanzen und warme Leuchten wurden nie erzeugt. Die Farbe wird jetzt direkt vom Leuchtkörper übernommen. Ein typprüfender Test reproduziert den alten Color3-Fehler und prüft die vollständige korrigierte Ausstattung:12 Palmen,18 Tröge,4 cyanfarbene und20 warme Lichter. Wiederholte Anwendung geprüft. Der frühere reine Hierarchietest hatte diesen Property-Typfehler nicht erfasst.

Preview baut zunächst ohne Workspace-Parent und entfernt das unvollständige Modell bei Fehlern. Erfolgszeile: Tropical High-Rise P5-v2 ready. Roblox-Lichtwirkung bleibt visuell zu prüfen.
