# LearnQuest Adventure – 09.11.2026, 10:16 CET

## Ziel und Änderung
Im bestehenden DRAFT PR #157 drehen sich noch nicht eingesammelte Neon-City-Kristalle jetzt im tatsächlichen 3D-Areal. Bereits eingesammelte (unsichtbare) Kristalle werden nicht weiter animiert. Der neue visuelle Hinweis macht Sammelobjekte im Gehmodus besser erkennbar; keine Änderungen am Runner, an Quiz, XP, vier Welten, Power-ups, Touch-Gesten oder Archiv.

## Akzeptanzkriterien
- Jeder sichtbare Crystal-Pickup besitzt ein benanntes 3D-Visual und rotiert im laufenden Adventure-Physiktick.
- Unsichtbare/gesammelte Kristalle werden nicht rotiert.
- Runner und historische Releases bleiben unverändert.
- Godot-Import und Headless-Adventure-Bridge-Test müssen vor Merge erfolgreich sein; visuelle 16:9-/19.5:9-Bilder und iPhone-Safari-QA bleiben separat erforderlich.

## Prüfung und Evidenz
- Primary GitHub mtothek0703 / michael_kohler1@yahoo.de, Repository und vorhandener Branch vor Änderung geprüft.
- Alle vier Pflichtdokumente auf main gelesen; zuletzt direkt ermittelter main `46bfea3ecbfa4db8cc755df8d7fab201706d8059`, PR-Metadaten meldeten abweichende base_sha `b9010294fea1728212bea50d413c465d55706dd2`. Kein Rebase/Merge.
- Vorheriger PR-Head `89ded66017120914fee0e51b532967c31f9b544e`: GitHub Godot PR validation #42586427712 = success.
- Gameplay-Commit `0a74b8c49cfcb72629cd64f584a963cdf29a5951`; Regressionstest `22e45878f7a4c4268b5c74d32946a21fc137a69b`; Typkorrektur `53fc6aa3c18ab925522343337e713b03df884790`.
- Tatsächlich ausgeführt: Quellcode- und PR-/Workflow-Prüfung via GitHub; neuer Test im bestehenden `res://adventure/adventure_bridge_test.gd` ergänzt. **Kein lokaler Godot-Import/Headless-Test/Webexport und kein neuer erfolgreicher CI-Lauf zum neuen Head belegt.**
- DRAFT belassen. Keine neue skyway-vN/ URL; kein Release oder iPhone-FPS-Nachweis.

## Nächster Schritt
Neue PR-CI auswerten und ggf. korrigieren; anschließend reale 16:9-/19.5:9-Renderbilder des importierten Gehcharakters, Schilds und der Kristalle sowie mobile Bedienflächen prüfen.