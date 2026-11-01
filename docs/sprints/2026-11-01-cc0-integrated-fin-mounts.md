# 2026-11-01 — Track B: integrated articulated fin mounts (DRAFT PR #111)

## Mandatory preflight
Read both `LEARNQUEST_SPRINTS.md` and `LEARNQUEST_RELEASE_POLICY.md` on `main` in this run. Verified Primary account `mtothek0703`, repository ID `1427565370`, and isolated CC0 draft branch. V144 was the last verified stable version when this experiment began. The PR's historical "V124" name reserves **no** release number.

## Actual defect and change
- Downloaded and visually inspected the original 1280x720 CC0 source-body and carve-fin Godot QA frames. The outboard fin leaves looked detached from the board in front/chase view.
- Added two closed, curved, actually modeled mounting spars inside the original articulated fin hinges. Their inner roots overlap the existing hull chine and their outer ends connect to the aerofoil. Each follows the same smooth steering/boost motion as its fin, without new gameplay collisions, extra imported assets, lights or touch changes.
- First render made the supports look like **bright exposed rods**; this was rejected before any stable merge. The second revision reshaped them into dark, low-profile, chord-wide composite fairings.
- Extended the existing hoverboard regression to require two real 3D mounting meshes (650+ vertices), adequate 3D dimensions and inboard-to-outboard continuity. The 65-bone CC0 original rig and gameplay code were untouched.

## Actual tests and image inspection
- [x] [Final Godot PR CI 41313697519](https://github.com/mtothek0703/learnquest-unity-web/actions/runs/41313697519) **completed/success, 52/52 steps**, including import, gameplay, CC0 skinning and board regressions, Web export and actual rendered landscape QA.
- [x] Downloaded 24 final Godot carve-fin frames and compared to the previous branch's 24 original frames, identical 1280x720 right-carve camera. Max RGB-channel delta >25: **1,638 pixels (0.178%) in chase**, **2,582 pixels (0.280%) in three-quarter**. The dark supports are visible, but still read partly as thin side elements.
- [ ] The overall rider remains too toy-like, the silhouette improvement is **not** a full-character visual acceptance. PR #111 remains **DRAFT**, no merge or release.
- [ ] Physical iPhone FPS, all-pose clipping and a full manual touch game round remain unverified.

## Next
Prioritize a major cohesive character/board design pass over repeated tiny detail tweaks; verify the whole figure in both front and chase camera with matching real Godot frames. Track A may publish independent stable features without waiting for this experiment.
