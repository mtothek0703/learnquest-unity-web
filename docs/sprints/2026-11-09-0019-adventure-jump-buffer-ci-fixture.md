# LearnQuest Adventure – 2026-11-09 00:19 CET – A4 jump-buffer CI fixture repair

## Konto, Basis und Pflichtdokumente
GitHub Primary `mtothek0703` / `michael_kohler1@yahoo.de`, Repository `mtothek0703/learnquest-unity-web`, bestehender DRAFT PR #157 / Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19` geprüft. Direkte main-Abfrage `46bfea3ecbfa4db8cc755df8d7fab201706d8059`; PR-Metadaten base_sha `b9010294fea1728212bea50d413c465d55706dd2`, Head vor Änderung `a361b9cfe00445008cc6b6ea1b61db6243115150`. Alle vier Pflichtdateien auf main gelesen: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md. Kein Rebase/Merge wegen unterschiedlicher Basisangaben.

## Befund und Änderung
Godot PR validation [42529247870](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/42529247870) fehlgeschlagen: `ADVENTURE BRIDGE TEST FAILED: on-foot early jump must be buffered briefly`. Die Test-Fixture teleportierte den Spieler vom Boden nach oben, wartete nur einen Physics-Frame und verließ sich auf einen bereits aktualisierten `is_on_floor()`-Zustand. Dieser kann nach dem Teleport noch den vorherigen Bodenkontakt abbilden; dann verbraucht die Coyote-/Jump-Logik den Puffer sofort. Im Test wird der Kollisionszustand nach dem Teleport jetzt explizit über `move_and_slide()` aktualisiert, Coyote-Zeit auf null gesetzt und die Luftposition geprüft, bevor der Puffer getestet wird. Die eigentliche Walking-Gameplay-Logik bleibt unverändert.

## Akzeptanz und echte Tests
- Der Test muss mit eindeutigem airborne-Startzustand den 0,14s-Jump-Buffer prüfen.
- Checkpoint löscht den Puffer; die nachfolgenden Coyote-, Kampf-, Mission-, Fokus- und Runner-Regressionen dürfen nicht ausfallen.
- Tatsächlich ausgeführt: GitHub-Konto/Repository/PR/Main/Pflichtdateien gelesen, Actions-Job-Log ausgewertet, Test-Quelltext geprüft, Test-Fix auf PR-Branch committed (`a2cee8c9d715f9196c527c236e959184e6e62a2d`).
- Noch **nicht** erfolgreich bestätigt: CI für neuen Commit, Godot-Import/Headless-Test/Webexport, 16:9-/19.5:9-Renderbilder, iPhone-Safari-Test.

PR #157 bleibt DRAFT. Kein Merge, keine neue Skyway-Version, keine Änderung am Runner oder den historischen Archiven. Als nächstes den neuen CI-Head prüfen; bei grünem Test die reale Render- und Charakterintegration angehen.
