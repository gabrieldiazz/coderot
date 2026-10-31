# CODE ROT — project guidance

## Vision
CODE ROT is an original Roblox multiplayer, round-based survival horror game for
1–6 players, including solo. Familiar early-2010s Roblox malfunctions gradually
become the horror. The antagonist is code rot itself, not a generic monster.
Preserve the three pillars: nostalgia, recognizable broken-game behavior, and
horror. Escalate gradually from comedy to suspense to danger. Prioritize fun,
replayability, social moments, maintainability, and mobile performance.

## Prototype scope
Build incrementally; inspect existing code before changing architecture. Do not
implement the entire game at once. Explain each small slice and its validation.
The first vertical slice uses one original Disaster Island map for three rounds,
a deteriorating lobby, and a final server-collapse escape. Target roughly 10–15
minutes per match, with a roughly 120-second finale, subject to playtesting.
Use placeholder geometry and assets. Do not copy other experiences' maps, names,
or copyrighted assets.

MVP includes Global Rot, Personal Rot, about 8–10 directed corruption events,
one optional corrupted interaction, basic UI, individual outcomes, and one chain:
Broken Ragdoll → Staring NPC → Hostile Looper. Reuse the same recognizable NPC.
Defer Flood Facility, Forgotten Obby, persistent progression, cosmetics/shop,
anomaly archive, elaborate highlights/lore, secret endings, and advanced recovery.

## Gameplay rules
- Rounds 1–3: death/failure eliminates only for that round; spectate until next
  round. Everyone can return next round and participate in the finale.
- Finale: no respawns. Each player wins only by reaching the real server-validated
  exit alive before the deadline. Multiple winners are allowed.
- Global Rot is shared, 0–100, monotonically increasing within a match; reset
  between matches. Critical Rot starts the finale.
- Personal Rot is separate, server-owned, 0–100, and primarily perceptual. Keep
  exact values private; communicate conditions such as Stable and Critical.
  High Personal Rot must not automatically kill. Local hallucinations must never
  decide damage, authoritative collision, objectives, or escape results.
- Corrupted interactions are optional risk–reward opportunities. Normal objectives
  and escape remain possible without them or early-round rewards.
- Prototype rewards: one capped, optional escape-direction assistance charge.
  Avoid permanent survival advantages or pay-to-win mechanics.
- Events use eligibility, weights, cooldowns, recent event/family history,
  compatibility, hazard budgets, and quiet periods, not blind fixed-interval
  randomness. Important instructions and real HUD countdowns remain trustworthy.

## Repository and workflow
- Preserve the existing Rojo mappings in default.project.json:
  src/server → ServerScriptService.Server;
  src/client → StarterPlayer.StarterPlayerScripts.Client;
  src/shared → ReplicatedStorage.Shared.
- Aftman pins Rojo 7.7.1. Do not replace tooling or add a framework/package manager
  without a concrete need. The extension can run Rojo even when this shell has
  no rojo executable on PATH; locate the executable before claiming CLI checks.
- Development uses Codespaces with Rojo connected to local Roblox Studio through
  desktop VS Code forwarding. Keep that workflow. Do not install the Studio
  plugin in Linux Codespaces.
- Source files are authoritative for code. Studio-only assets may exist and cannot
  be assumed visible from the repo. Do not clear unrelated Workspace objects.
- Current prototype geometry is created at runtime under Workspace.CodeRotRuntime;
  it appears in Play/Test, not Edit mode. HUD is also created at runtime.

## Coding conventions and architecture
Use idiomatic Luau with --!strict in new modules, descriptive names, small focused
functions, and explicit initialization. Prefer simple modules over giant scripts
or premature abstractions. Entry scripts bootstrap services/controllers as they
grow. Shared code holds types/configuration/presentation identifiers; server-only
rules stay on the server. Avoid dependencies unless they materially help.

Logical responsibilities: match/round lifecycle, player states/spawning,
world/minigame lifecycle, corruption values/interactions/rewards, event director
and catalog, rot chains, client presentation, HUD and spectator camera. Introduce
modules when needed rather than creating empty layers.

Server owns progression, deadlines, real hazards, damage, elimination, Personal
and Global Rot, interactions, rewards, and outcomes. Client owns UI, camera,
local sound and non-colliding cosmetic hallucinations. Validate and rate-limit
all client requests: types, player/phase state, distance, object identity,
cooldowns, and permissions. Never accept client-claimed wins or damage.

Replicate coarse state and server-time deadlines; avoid per-frame remotes.
Send personal effects only to their intended client. Bound physics props, NPCs,
connections, and effects. Every event/round must clean up tasks, instances,
connections, and presentation on completion and cancellation. Reset matches
fully. Handle late joins, disconnections, empty servers, character resets, and
all-player elimination deliberately. Keep touch controls and readable mobile UI.

## Development and validation
Implement and validate one milestone at a time:
1. Multiplayer lifecycle skeleton and HUD.
2. Playable Disaster Island and spectating.
3. Global corruption and evolving NPC chain.
4. Director and bounded event catalog.
5. Personal Rot, hallucinations, and terminal interaction.
6. Validated finale, assistance, individual results, clean replay.
7. Six-player/mobile tuning and pacing playtests.

The lifecycle skeleton was confirmed working by the user in Studio. Milestone 2
adds a blockout island, telegraphed debris, cover protection, water elimination,
and client spectating; its Studio acceptance tests are pending. Global Rot and
an initial three-stage NPC chain are implemented but not fully Studio-validated.
Finale escape, Personal Rot and the Event Director remain unimplemented. Inspect current files rather than
treating this status note as permanent truth.

Run git diff --check and available relevant static/build checks. Rojo build checks
assembly, not Roblox runtime correctness. Add focused logic checks for meaningful
state/selection/outcome behavior when those systems are introduced; avoid tests
that only mirror implementation.

In Studio, sync in Edit mode, then Test/F5 for solo and Server & Clients for two,
then six players. Restart tests after structural changes. Validate death/reset,
late join, disconnect, all players eliminated, per-player wins/losses, timeouts,
invalid/spammed requests, private hallucinations, and at least three clean replay
cycles. Use device emulation plus real-phone playtests for touch/performance.
State clearly which checks actually ran; never claim Studio validation from
shell checks. Document limitations and give concrete Studio acceptance steps.

## Art direction and asset provenance
The user rejected arbitrary gold-ball trophies and crude filler scenery. Aim for
an abandoned retro minigame plaza: muted cream/teal paint, brick, faded signs,
slatted benches and a broken information kiosk. Keep geometry deliberate and
recognizable. Do not add unrelated decorations just to fill space. The current
plaza is implemented in the Lobby service; island art remains a separate pass.
Meshy generation is authorized when useful. Keep prompts, task IDs, settings,
credit use and import steps documented alongside assets. Review one prop before
batch generation. API keys stay in local configuration, never gameplay source or
logs. A downloaded FBX/GLB is not a Roblox asset until imported/published through
Studio. The optional kiosk template is Studio-owned in ServerStorage.CodeRotAssets;
command-line builds use the procedural fallback unless that template is exported
and explicitly mapped. Do not claim a generated prop is in-game before import.
