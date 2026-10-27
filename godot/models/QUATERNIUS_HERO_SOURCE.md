# V124 CC0 character integration — PROVISIONAL, not released

The upstream **Quaternius Universal Base Characters Standard** pack is CC0 1.0:
https://quaternius.com/packs/universalbasecharacters.html

For the small mobile-web proof of concept, the exact **Superhero Male** source
mesh, skeleton and bind poses were repackaged by ProgramAsWeights:
https://github.com/programasweights/avatar/blob/e225eee89835d121876b15bf4c887dc20d357950/ASSETS.md

The 741,320-byte GLB is pinned to upstream commit
\`e225eee89835d121876b15bf4c887dc20d357950\`, Git blob SHA-1
\`b3fd79533fdb9fcedd077744f7e120920eb6cc97\`. It is downloaded by
\`python3 .github/scripts/fetch_quaternius_hero.py\` and hash-checked **before**
Godot import. Its source is Quaternius CC0; the upstream wrapper project is MIT.
The asset's packaging removed textures and uses a simple jade material; **this
is not yet a finished high-quality flight-suit character**. No paid Source pack
or proprietary textures are required.

\`godot/rider_external_character.gd\` uses the imported 50+ bone skeleton and
the actual GPU skin (without replacing bind matrices). A new opt-in switch
\`prefer_cc0_rigged_hero\` keeps all existing V123 rider regressions intact.
The old rider, hoverboard and touch/physics controller are retained as a safe
fallback. No external asset is shipped in the repository until final approval.

**Release hold:** inspect the eight actual rendered V123/V124 comparison PNGs
at 1280×720 and 1170×540, confirm fit/face/clothing/orientation, improve
materials/outfit and confirm actual iPhone landscape FPS. Only then consider
enabling the new hero by default and releasing under a new immutable URL.
Automated skeleton checks do not certify visual quality or device performance.
