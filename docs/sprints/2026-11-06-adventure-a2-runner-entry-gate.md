# 2026-11-06 11:15 – Adventure A2: fail-closed Runner-Einstieg

## Basis und Kontoschutz
Primary `mtothek0703` (`michael_kohler1@yahoo.de`), Repository `mtothek0703/learnquest-unity-web`, main `0e01246620d33a9afcbb617152748adac4402993` vor Änderung verifiziert. `LEARNQUEST_SPRINTS.md`, `NEUE LEARNQUEST_RELEASE_POLICY.md`, `LEARNQUEST_RELEASE_POLICY.md`, `docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md` auf main gelesen.

## Änderung
`godot/world.gd` enthält einen standardmäßig abgeschalteten Eintritts-Guard `can_enter_neon_adventure()`. Er erlaubt einen künftigen Eintritt ausschließlich aus einer aktiven Neon-City-Rennphase ohne offenes Quiz; der aktuelle Runner ruft ihn nicht auf. Das ist ein kleiner integrierter Vorbereitungsschritt, **kein** bereits spielbarer Übergang. Die drei Pflichtfragen, Bosskämpfe, vier Welten, Power-ups, Runner-Gesten, XP und Archiv bleiben unberührt.

## Akzeptanzkriterien
- Bei ausgeschaltetem Feature ist der Eintritt unabhängig vom Zustand verboten.
- Training und Resultat sind kein zulässiger Eintrittspunkt.
- Keine Änderung an bestehender Runner-Logik oder Versionsnummer.
- Nach erfolgreicher Godot-Abnahme: Race-Pause-Brücke und begehbare Arena tatsächlich verbinden.

## Tests und Ergebnis
- GitHub-Dateiänderung erfolgreich committed; reiner Code-Review des Guards.
- Godot-Regression `godot/adventure/runner_entry_gate_test.gd` erstellt, **nicht ausgeführt** (Godot-4.4.1-Laufzeit hier nicht nachgewiesen).
- Godot-Import, Headless-Gameplay, Webexport, 16:9-/19,5:9-Renderbilder, iPhone-Safari, CI, Archivschutz und Pages **nicht abgenommen**.
- Kein Merge, keine neue Skyway-Version. PR bleibt DRAFT.
