# LearnQuest Sprint – 2026-11-04 14:10 CET

## Verbindliche Grundlagen
LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md und LEARNQUEST_RELEASE_POLICY.md auf main gelesen. GitHub Primary (mtothek0703), Repository mtothek0703/learnquest-unity-web geprüft.

## Spur A – stabil
main zuletzt dokumentiert bei 6077903f; V154 ist die zuletzt belegte stabile Spielversion. Keine neue Gameplay- oder Grafikänderung in main in diesem Durchlauf. Kein Release; keine historische Skyway-URL oder Unity-Archivdatei verändert. Godot-Tests, Webexport, Pages-HTTP und Archiv-Workflow nicht neu ausgeführt, daher kein bestandenes Gate behauptet.

## Spur B – PR #111 DRAFT
Fehler im A/B-Bildvergleich korrigiert: vorher zeigte die Clip-Maske die neue Aufnahme links, obwohl die Beschriftung „Alt“ links und „Neu“ rechts lautet. Jetzt ist links vom Trenner die alte Referenz und rechts die neue Aufnahme sichtbar. Sowohl initiales CSS als auch die dynamische Slider-/Pointer-Maske wurden konsistent auf inset(0 0 0 N%) umgestellt. Hilfetext verdeutlicht die Orientierung.

Implementierung: Commit 603940bc46fe070842a410b390c44fe7ac1ce8a8 auf sprint-v124-quaternius-rigged-hero. Akzeptanzkriterium: Slider 0% zeigt vollständig Neu; 100% vollständig Alt; bei 50% Alt links und Neu rechts. Statische Prüfung der CSS- und JS-Masken sowie erneutes Lesen der Datei über GitHub erfolgreich. Echter Browser-/Touchtest und echte Renderbild-QA nicht ausgeführt; visuelle Freigabe der 65-Bone-Figur fehlt. PR nicht mergen, Versionsnummer nicht reservieren.

## Nächster Schritt
Echte 16:9-/19,5:9-Renderframes der Figur und des Hoverboards vergleichen, Clipping beheben und unabhängig davon eine echte stabile Gameplay-/Weltverbesserung mit Godot-/Export-/Archiv-/Pages-Gates umsetzen.
