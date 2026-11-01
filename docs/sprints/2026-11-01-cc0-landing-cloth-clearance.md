# 01.11.2026 — CC0 65-bone landing cloth clearance (DRAFT PR #111)

- Both mandatory policies on main reviewed; verified Primary GitHub account and `mtothek0703/learnquest-unity-web`.
- The original CC0 65-bone rider already computes a time-based landing impulse for knees/head. The **two existing four-weight, closed 3D flight-mantle panels** now receive that same impulse through one shader uniform and briefly sweep backward/outward on landing, clearing the animated knees and boots before returning to the tucked neutral silhouette.
- This changes actual weighted vertex positions on the existing mesh in its existing shader pass. No new mesh, collider, asset, draw call, touch gesture or gameplay rule.
- Extended the mantle regression to check both real panels receive the same landing impulse, actual pose contact drives it, and it decays rapidly. Godot/CI and visual before/after still require independent confirmation; no visual quality approval is claimed.
- **VISUAL HOLD:** keep PR #111 DRAFT and never merge this unapproved character into the stable channel. The title does not reserve V124. Stable track A can release independently. Real iPhone FPS, all-pose clipping and full manual touch round remain unverified.
