# LearnQuest A2 – Mission XP in derselben Runner-Session (06.11.2026, 21 Uhr)

## Basis und Identität
Primary GitHub mtothek0703 (michael_kohler1@yahoo.de), Repository mtothek0703/learnquest-unity-web; bestehender DRAFT PR #157, Branch `feature/adventure-a1-walkable-neon-testbed-20261106-19`. Main beim Check: `3117869390c6f3dff6409bfde1f64c2d184b0853`; Branch 1 Commit hinter main. Vier Pflichtdokumente auf main gelesen. Keine Änderungen an main, historischen Releases, Unity-Archiv, Runner-Gesten oder PR #111.

## Implementierung
- Bei erfolgreich abgeschlossener Mission (drei Kristalle und zwei Schalter) gibt der Übergang zurück zum Runner genau 75 XP auf die **bestehende** Session.
- `_exit_adventure()` verweigert den Ausgang bei unvollständiger Mission und vermeidet Mehrfachvergabe über `adventure_reward_claimed`.
- Neuer Lauf setzt Reward-Gate zurück. Der bisherige Fortschritt bei Energie, Leben und Distanz bleibt erhalten.
- Der bestehende `adventure_bridge_test.gd` prüft gesperrten Ausgang ohne XP, erfolgreiche einmalige Vergabe, wiederholten Exit ohne zweite Vergabe und Reset.

## Akzeptanzkriterien / tatsächliche Prüfungen
- Code- und Teständerungen auf PR-Branch committed: `fd11992372b5bc495cff33ccd7e022cde002f123`, `8dfc0b0d5642bb5c4f94bd84ba342f3caab57e45`, `f1d4d8c1786f316621d3cf24fd68861f338aa627`.
- Vor dieser Änderung war PR-CI für Head `8f72d70893e6f729511837fd90219fc6c5c5762f` erfolgreich (GitHub Actions Run 42277663723). Das ist **kein** Testnachweis für die neuen Commits.
- Neue Godot-CI, Import, Gameplay-Test, Webexport, 16:9/19.5:9 und iPhone-Safari: **noch nicht nachgewiesen**. PR bleibt DRAFT, kein Merge/Release.
- Nächster Schritt: neue PR-CI inklusive Bridge-Test prüfen; bei Fehlern korrigieren, danach A3-Roboterkampf im selben integrierten Slice. Main-Divergenz vor Merge sauber lösen.
