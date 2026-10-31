# Development log

## Milestone 3 — initial corruption slice

Added server-owned Global Rot with monotonic round/intermission ramps, early-end
advancement, finale value 100, and match reset. HUD displays shared Rot; client
brightness scales gently with it. Lobby decorations skew and decorative sign
text degrades. Real instructions remain readable.

Added a procedural block visitor: harmless collapse animation in stage one,
player-facing stillness in stage two, and pursuit bursts in stage three/finale.
Damage is server-owned: four-stud range, line of sight, 20 damage, two-second
per-player cooldown. Lobby appearances never attack. Stage tasks and models are
removed at each transition. Old-character death callbacks are guarded.

### Tradeoffs and remaining work

This is an initial slice, not a fully validated milestone. The visitor uses
bounded direct movement with obstacle raycasts and stops when blocked. Pathfinding
and visual walking animation remain to implement; it may get stuck at shelter
posts. The first stage simulates ragdolling with a controlled tilt, not physics.
No Meshy credits were spent: procedural geometry suits this prototype.
Personal Rot, weighted director, escape validation, and rewards remain deferred.

### Validation

Run git diff --check and Rojo build for assembly. Studio validation is pending.
In Studio: shorten match timers temporarily; observe Rot never decreasing through
three rounds, early elimination, intermissions, and finale. Verify reset next match.
Compare both clients' HUD values. Check the visitor is harmless in rounds one/two,
only attacks active players in round three, respects cover and damage cooldown,
and stops targeting disconnected/eliminated players. Repeat three matches and
check there is exactly one visitor and no leftover tasks or world effects.
Verify earlier milestone debris/spectator acceptance checks before declaring
this milestone complete. Test lighting and instructions on a phone-sized screen.

## Presentation corrections after Studio feedback

The initial visitor tilted continuously and debris visibly passed through cover.
Replaced the tilt with a timed stumble, floor pause, and recovery; added a simple
face. NPC parts initialize at their intended coordinates and do not block queries.
Debris now sweeps its full volume downward against solid geometry and animates
only to first impact, including roof edges; the rock briefly rests before cleanup.
Damage retains a separate server cover check.

Expanded the procedural plaza with brick boundaries, walkway, spawn emblem,
benches and trophy plinths. Added island shoreline rocks, shelter path and dock.
No Meshy generation or credit use. Unidentified white blocks reported in Studio
could not be traced definitively from source alone; no unrelated Studio objects
were removed.

Validation: whitespace/assembly checks; Studio visual acceptance pending. Check
roof center and edge impacts, exposed hits, NPC stumble/recovery, readable lobby
layout and spectator cameras. Confirm rock effects clean up between rounds.

## Retro plaza art pass

User feedback: arbitrary trophies and primitive scenery did not establish a
convincing location. Removed all gold balls/plinths and their corruption code.
A new Lobby module owns presentation separately from island construction.
The replacement is an abandoned minigame park entrance: muted cream/teal palette,
concrete paving, brick columns/capped walls, inward-facing slatted benches,
overgrown planters, warm lamps, park signage and an offline CRT directory kiosk.
The middle stays open for spawning and movement. Decorative notice text and board
alignment degrade with Rot and return to baseline for the next match.

The kiosk supports an optional imported ServerStorage.CodeRotAssets.InformationKiosk
Model. The game clones and scales it, anchors its parts, disables collision, and
removes embedded scripts. No live HTTP requests or Meshy secrets run in Roblox.
The procedural kiosk remains visible without any import. This pass does not claim
to finish island art, character animation, pathfinding, or milestone 3 gameplay.

Meshy provenance and import instructions live in assets/meshy/kiosk. Exact task
IDs, prompts, credit snapshots and returned consumed-credit values are recorded
in manifest.json. Generation uses the authorized API key from local configuration;
that key is neither logged nor copied to game source. Review the generated preview
before refinement. Downloaded models still require Studio import before appearing.

Validation: Rojo reported successful assembly. Studio visual/runtime validation
is pending. Restart Play and verify no trophies, clear spawn space, signs facing
the courtyard, accessible bench/planter placement, gradual notice deterioration,
and clean lobby reset after a match. Test both missing-template fallback and the
imported-model path. Confirm the optional prop never changes collision or damage.

Kiosk generation completed and both thumbnails were inspected. Preview task:
01a19374-9080-7770-a3e2-475529e67155 (20 credits); texture task:
01a19376-f925-72b6-8c38-3a3a48ca6736 (10 credits). Balance 1,100 → 1,070.
Both meshes contain 3,601 triangles, verified from GLB indices. Unpacked the
textured GLB losslessly to glTF+BIN and packaged an import ZIP with FBX, base
color, thumbnail and provenance. The textured screen is brighter than requested;
its final look must be evaluated under Studio lighting. No asset was uploaded to
Roblox or automatically inserted into the user's Studio place by this session.
