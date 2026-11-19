# LearnQuest 3D – 2026-11-06 13:19 CET – A2 Arena/HUD-Integration

## Sicherheitsbasis
Primary GitHub: mtothek0703 / michael_kohler1@yahoo.de (link Primary), Repository mtothek0703/learnquest-unity-web, main 0e01246620d33a9afcbb617152748adac4402993. Vor Änderung alle vier Pflichtdateien auf main gelesen: LEARNQUEST_SPRINTS.md, NEUE LEARNQUEST_RELEASE_POLICY.md, LEARNQUEST_RELEASE_POLICY.md, docs/plans/LEARNQUEST_ADVENTURE_MODE_ROADMAP.md. PR #146 DRAFT, Feature-Branch feature/adventure-a1-walk-arena-20261105-2111 vor Änderung 37 ahead / 0 behind main. Dieser Sprint integriert bewusst in den bestehenden A1-Arena-Branch statt eine weitere voneinander getrennte, nicht ausführbare Komponente anzulegen.

## Konkrete Änderung
Die bereits vorhandene A2-Mission und die tatsächliche A1-Arena sind nun mit einer sichtbaren MissionHUD-Control verbunden. Ein szenenlokaler Controller bindet bei _ready() die vorhandene Mission. Der Bildschirm zeigt die Zahl der Kristalle und Schalter sowie die Freigabe des Ausgangsportals; alle Änderungen erfolgen über die bereits bestehenden Missionssignale. Der Touch-Layer ignoriert Eingaben im HUD. Keine Änderungen an world.gd, Runner-Gesten, Quiz, XP, vier Welten, Bossen, vier Power-ups, Skyway-Archiven oder Unity.

## Akzeptanzkriterien
1. Die echte Arena lädt mit MissionHUD und bindet das Mission-Node automatisch.
2. Start 0/3 Kristalle und 0/2 Schalter; Ausgang gesperrt.
3. Drei Kristalle allein reichen nicht; nach zwei Schaltern wird Portal bereit angezeigt.
4. Mission-Reset sperrt den Ausgang wieder.
5. Keine Runner-Regressionsänderung; weiterhin kein Race-to-Walk-Übergang.

## Ausgeführte Prüfungen und Ergebnis
- GitHub-Repository, Primary-Konto, main SHA, Branch-Vergleich und Pflichtdokumente gelesen: erfolgreich.
- Quelltext von Arena, Mission und HUD auf den entsprechenden PR-Branches eingesehen; tatsächliche Szenenverknüpfung committed.
- Regression hinzugefügt: `godot --headless --path godot --script res://adventure/adventure_hud_integration_test.gd`.
- **Nicht ausgeführt**: Godot 4.4.1 Import, Headless-Test, Webexport, 16:9-/19.5:9-Renderbilder, iPhone-Safari, Actions-CI, Archivschutz und Pages (Godot-Laufzeit lokal nicht vorhanden). Code ist nicht als lauffähig abgenommen.
- Kein Merge, keine neue skyway-vN/ URL.

## PR / Commits
DRAFT PR #146: https://github.com/mtothek0703/learnquest-unity-web/pull/146
HUD 0f712af; Arena-Controller a8f5aee; Szenenverknüpfung 3bf4dcc; Integrations-Regression 957826e.

## Nächster Schritt
Godot-Import und Integrations-Regression tatsächlich in Actions ausführen und gegebenenfalls reparieren. Danach Runner-Entry-Gate, Race-Pause und A1-Arena in einer einzigen Session verbinden, ohne Quiz-/Bosszustand zurückzusetzen. Der experimentelle 65-Bone-PR #111 bleibt unabhängig DRAFT.
