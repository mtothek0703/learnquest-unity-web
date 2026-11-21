# LearnQuest Adventure A4 – mobile action button insets (07.11.2026, 05 Uhr)

## Ausgangsprüfung
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de; Repository: mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`; main SHA laut PR-Metadaten `b9010294fea1728212bea50d413c465d55706dd2`, PR-Head vor Änderung `89a3e96f09d104c5b8efcdf1cd23772278346302`. Alle vier vorgeschriebenen main-Dokumente gelesen. Vorheriger Godot-PR-CI-Lauf 42332784669 erfolgreich.

## Implementierung
- Im separaten Gehmodus werden SPRUNG, INTERAKTION, ANGRIFF und ABWEHR an der rechten Bildschirmkante mit festen negativen Insets verankert. Das verhindert horizontales Abschneiden bei schmaleren Querformat-Viewports, das die vorherige 77–80%-Ankerung mit 130–160 px breiten Tasten verursachen konnte.
- Geh-Richtungstasten von 110x52 auf 84x44 verkleinert, damit weniger Spielfeld überdeckt wird.
- Runner-Touch-Gesten, Trainingsfragen, vier Welten, alte Skyway-Versionen und Unity-Archiv nicht verändert.
- Headless-Bridge-Test um Strukturprüfung aller vier eigenständigen Aktionsbuttons samt rechten Sicherheitsabständen erweitert.

## Akzeptanzkriterien
1. Vier Geh-Aktionsbuttons bleiben am rechten Viewport-Rand mit mindestens 10 px Sicherheitsabstand.
2. Alle vier bleiben getrennt vom Runner-Eingabesystem.
3. Bestehender Adventure-Bridge-Test inklusive Quiz, Mission, Kampf und Rückkehr bleibt erfolgreich.

## Tatsächlich ausgeführte Tests / Grenzen
- Quellcode- und PR-Metadatenprüfung durchgeführt; vorheriger Godot-CI-Run 42332784669 war grün, betrifft **nicht** die neuen Commits.
- Für die neuen Änderungen wurde kein lokaler Godot-Import, kein Headless-Lauf, kein Webexport, kein echter 16:9-/19.5:9-Render und kein iPhone-Test ausgeführt. Neuer CI-Status muss geprüft werden.
- Noch keine Prüfung der vertikalen Überlappung bei allen Viewportgrößen. DRAFT beibehalten; kein Merge und kein Release.

## Commits und Ergebnis
Gameplay `c08c1325d87cd33bfefa50ee7187487b06d0ef32`; Test `d9a76278258b8afaa48297f53387dfae5870e100`. Ergebnis: Änderung committed, neue CI/visuelle QA offen. Nächster Schritt: CI und 16:9/19.5:9 echte Renderbilder, danach ggf. Touch-Layout feinjustieren.
