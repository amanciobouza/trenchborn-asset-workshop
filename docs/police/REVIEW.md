# Police HQ P4 Review

Verbindliche Referenz: https://raw.githubusercontent.com/amanciobouza/trenchborn-asset-workshop/1c2dcd970b3334adcb5e99f146679eef3162f80d/docs/assets/large-city/police-station/police-station-approved-target-2026-09-26.jpg

Issue #4 / Gate A und P3 freigegeben. Main und sämtliche Branch-Namen wurden geprüft: kein vorhandener Police-HQ-Implementierungsbranch oder Police-Modul in main. Neues isoliertes Preview in `largecity-police-hq-l3`; main bleibt unverändert. Vorhandene GoldenMaster-/Rojo-/XML-Konventionen übernommen.

## Konkrete technische Aufteilung

- Front lokal -Z; Pivot Grundstücksmitte bei Y=0; Grundstück X±88, Z±64. Platte von Y=-1 bis 0.
- Hauptkörper X[-76,52], Z[-16,56], Y[0,60], drei Geschosse je20.
- Portal X[-28,4], Z[-24,-16], Y[0,68]; Vordach separat 40×12×3, Oberkante28.
- Fahrzeugvorbau X[52,84], Z[-16,8], Y[0,24]. Freie Zufahrt davor.
- Funkraum X[-4,28], Z[18,42], Y[60,76]. Mast bis100. Lüftungsgitter tritt vor die Wand.
- Eingang beiY4, acht Stufen je0.5 hoch. Seitliche Rampe über40 Studs (1:10); geschlossene Aussenhülle ohne zugesagtes Interieur.
- Die fünf Geometriebereiche sind Organisationsgruppen, keine eigenständig zerstörbaren Gebäude. Keine separaten HP.

## Prüfung

Generator kontrolliert positive Abmessungen, eindeutige Namen, Grundstücksgrenzen inklusive geneigter Rampe, Höhenlimit, exakte Haupt-/Vorbauhülle, XML-Lesbarkeit und Partanzahl. Technische Front-, Rück-, Seiten-, Aufsicht und erhöhte Ansicht aus derselben Partliste wurden geprüft. Keine Studio-, Physik- oder Laufzeitabnahme behauptet.

Absichtliche Anschlüsse: tragende Pfeiler schneiden Deckenränder; Portal überlagert die geschlossene Hauptfassade; Vordach verbindet Portal und Eingang. Fenster sind eigene Flächen zwischen Pfeilern. Geschossdecken liegen innen, damit Aussenkanten nicht mit blauen Bändern flimmern.

Gate B bleibt Pending bis zur visuellen Rückmeldung. P5 ergänzt Wappen, Funkdetails, Materialwirkung, Licht, Schranke und Vegetation. Zielbild zeigt reichhaltigere Dekoration als dieser P4-Stand. Stadtplatzierung, Hauptspiel-Schaden und Standalone-Studio-Import noch offen.
