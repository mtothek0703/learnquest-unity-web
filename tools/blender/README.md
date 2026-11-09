# LearnQuest 3D – Blender Cloud prototype

This folder is a standalone **proof of concept**, not a live Blender API or a game release.

## Purpose

Create a procedural, original stylized portal with headless Blender and export:

- `learnquest_portal.glb` – importable in Godot 4
- `learnquest_portal.blend` – editable native Blender project
- `portal_preview.png` – visual inspection render
- `manifest.json` – asset statistics and Blender version

## Run with GitHub only (no PC installation)

1. Open [Actions](https://github.com/mtothek0703/learnquest-unity-web/actions).
2. Select **Blender Cloud – LearnQuest 3D portal asset**.
3. Choose **Run workflow** on the default branch after the workflow has been merged.
4. Wait until the job ends green.
5. Open the run and download the artifact **learnquest-blender-portal**. It is kept for **1 day** to limit storage consumption.

The workflow uses `ubuntu-latest` and installs Blender on the **temporary GitHub runner**, never on the user's device. It uses CPU software rendering, no paid GPU and no secret/API key. All files are generated on the runner and are uploaded as run artifacts; it does not commit or deploy to the game.

The proof of concept can be verified on a feature branch by the `push` trigger. The manual **Run workflow** button only becomes generally available after the workflow exists on the default branch.

## Boundaries / security

- This does **not** expose a publicly reachable REST API or always-on Blender instance.
- Generated code runs in the repository workflow only; don't execute untrusted input.
- Existing Godot files and archived Unity/Pages releases remain untouched.
- `.glb` must be visually inspected and performance-tested in Godot before a game release.
- GitHub-hosted standard runners are free for this public repo; small artifact storage is still subject to account limits.
- This example does **not** require account tokens or service-role credentials.
