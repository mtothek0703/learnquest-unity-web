# LearnQuest Adventure – 2026-11-08 23:14 CET – A4 ledge jump grace

## Ausgangslage und Pflichtprüfung
Primary-Konto mtothek0703 / michael_kohler1@yahoo.de bestätigt; Repository mtothek0703/learnquest-unity-web, main direkt geprüft bei `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; bestehender DRAFT PR #157 auf `feature/adventure-a1-walkable-neon-testbed-20261106-19`, vorheriger Head `cc1d585ded21e6df4d78351b07f211579b94ccb5`. Die vier Pflichtdokumente auf main gelesen. PR-Metadaten zeigen abweichenden base_sha `b901029`, daher kein Rebase/Merge.

## Gameplay-Änderung
`godot/adventure/neon_walk_player.gd`: 0,10 Sekunden Coyote-Time nach Verlassen einer Kante, nur für den separaten Walking-CharacterBody. Das bestehende 0,14-Sekunden-Sprungpuffern bleibt. Eine Sprungauslösung verbraucht die Kanten-Toleranz sofort, sodass kein zweiter Luftsprung entsteht. Checkpoint/Respawn und Safari-Fokuswechsel löschen die Toleranz. Runner, Quiz, vier Welten und alte Builds nicht bearbeitet.

## Akzeptanzkriterien und Tests
- Ein kurz nach der Kante ausgelöster Sprung setzt positive vertikale Geschwindigkeit.
- Die Toleranz wird verbraucht; kein zweiter Luftsprung.
- Checkpoint löscht die Toleranz.
- Bestehende Bridge-, Missions-, Kampf-, Fokus- und Touch-Regressionen bleiben grün.

Neue Assertions in `godot/adventure/adventure_bridge_test.gd`. **Tatsächlich ausgeführt:** Quellcode und bestehende CI-Metadaten auf GitHub gelesen; letzter vorheriger Head `cc1d585` hatte Godot PR validation Lauf `42524636251` erfolgreich. **Nicht ausgeführt/bestätigt für neue Commits:** Godot-Import, Headless-Test, Webexport, reale Renderbilder und iPhone-Safari-QA. CI muss den neuen Head erst prüfen.

## Nachweis und Ergebnis
Gameplay-Commit `8aefdfad9523d129607b34dcea5d53c8a096174c`, Test-Commit `9f081b8b3c776ec6fd26858874b10749fcffc867`. PR #157 bleibt DRAFT, kein Merge/Release. Nächster Schritt: neue CI auswerten, anschließend visuelle 16:9-/19.5:9- und echte iPhone-Tests; lizenzierte Runner-Figur isoliert prüfen.
