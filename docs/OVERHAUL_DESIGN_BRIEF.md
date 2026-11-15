# Verdant Bastion — Overhaul Design Brief

## Product goal
Rebuild the current playable foundation into a premium-feeling, touch-first Android tower-defense game that captures the strategic appeal of open-path / maze-building tower defense games such as Fieldrunners 2, while using wholly original world design, maps, enemies, tower silhouettes, names, UI, effects, audio and progression.

This is a gameplay and presentation overhaul, not a new project scaffold. Preserve the Godot 4.7.2 project, Android ARM64 export path, existing repository history, and the known-good `godot-3d-foundation` branch.

## Core player fantasy
The player is the commander of a frontier bastion, shaping defensive lanes in a living miniature battlefield. They decide where enemies travel, which lanes to pressure, when to invest in economy and upgrades, and when to unleash limited tactical powers.

## Core loop
1. Read the incoming wave and the map's entry/exit routes.
2. Place and upgrade towers to shape enemy movement and create overlapping fields of fire without completely blocking valid routes.
3. Start or accelerate the wave; towers acquire targets, apply distinct damage/control roles, and produce readable combat feedback.
4. Earn resources, survive leaks, respond to enemy counters and boss mechanics, then reconfigure the defense between waves.
5. Unlock strategic options and progress through increasingly complex original battlefields.

## Design pillars
- **Player-shaped routes:** towers and obstacles influence navigation; enemies always retain a valid route to an exit. Route previews and placement validation must be clear before committing a tower.
- **Meaningful tower roles:** each tower solves a different tactical problem; no tower is a strictly dominant upgrade.
- **Readable enemy counters:** armor, shields, swarms, speed, flight and boss abilities are communicated visually and through concise UI cues.
- **Mobile-first clarity:** large touch targets, legible range and route overlays, safe-area-aware HUD, landscape-first battlefield framing, pause/resume and speed controls.
- **Diorama spectacle:** original stylized 3D environments, strong silhouettes, projectile trails, impact feedback, restrained screen shake and accessibility controls for effects.
- **Progression with choices:** branch upgrades, map unlocks, persistent profile progress and challenge modifiers; avoid grind-only progression.

## Target and technical constraints
- Platform: Android first; desktop editor/testing remains supported.
- Engine: Godot 4.7.2, GDScript, Compatibility renderer.
- Presentation: original stylized 3D diorama with top-down / slightly angled camera.
- Input: touch-first, mouse parity for development.
- Preserve ARM64 debug APK workflow and headless Godot smoke tests.
- Do not change `main` or production as part of the overhaul. Work only on `verdant-bastion-overhaul` until the user approves integration.
- Do not introduce paid services, proprietary assets, copied game content or new external dependencies without approval.

## Proposed first playable overhaul slice
1. Grid-based battlefield with authored terrain, at least two entry/exit objectives, and player-shaped routing.
2. Safe placement validation: reject a placement if it blocks every route; show the affected route preview.
3. Five distinct original tower roles: rapid single-target, splash artillery, slowing control, chain-energy, and long-range precision.
4. Five enemy roles: basic, runner, armored brute, shielded support, and flying raider; add a telegraphed elite/boss after the core loop is stable.
5. Wave director with authored wave compositions, spawn pacing, rewards, wave-clear state and difficulty scaling.
6. Tower targeting policies, meaningful upgrade branches, sell/refund rules and selection/range UI.
7. Tactical abilities with cooldown/resource trade-offs, introduced only after core balance is stable.
8. Persistent campaign/profile progression after the match loop is reliable.

## Architecture direction
Move away from the current all-in-one `scripts/game.gd` as features are implemented. Introduce focused scenes/scripts and data resources for:
- battlefield grid, terrain and route/pathfinding;
- placement validation and build economy;
- towers, targeting, projectiles and status effects;
- enemy archetypes, health/armor/shields and movement;
- wave definitions and wave director;
- match state, rewards and progression/save data;
- HUD, placement preview, selection panel and accessibility settings.

Keep interfaces small and deterministic. Prefer typed GDScript and data-driven definitions. Avoid premature framework complexity.

## Delivery phases and acceptance gates
### Phase 0 — baseline and design
- Confirm branch head, project settings, scene/script ownership, tests and latest CI.
- Record current behavior and save/build constraints.
- Complete a compact game design and technical plan before replacing the prototype loop.

### Phase 1 — route-building vertical slice
- Grid navigation and route validation work on touch and mouse.
- Players can place/remove defensive structures to shape routes.
- No legal placement can trap an enemy without a path to an exit.
- Automated tests cover path reachability, placement rejection and route updates.
- A playable map can be completed from wave start to victory/defeat.

### Phase 2 — combat depth
- Tower roles have distinct range, damage, cadence, targeting and status behavior.
- Enemy counters are readable and interact correctly with damage types.
- Automated tests cover targeting, armor/shield calculations, status duration and reward accounting.

### Phase 3 — content and presentation
- Multiple original maps/biomes, authored wave sets, elite encounters and boss mechanics.
- Original tower/enemy models, animation, VFX, SFX and refined HUD.
- Performance profiling on representative Android hardware.

### Phase 4 — progression and release readiness
- Upgrade branches, persistent unlocks, campaign flow, save migration and settings.
- Device testing, accessibility, memory/performance review, APK/AAB validation and release checklist.

## Verification rules
- Run Godot import, headless scene smoke test and gameplay regression tests for every gameplay change.
- Build an Android ARM64 debug APK from the overhaul branch after each meaningful vertical-slice milestone.
- Test actual touch interactions on a real device when available; emulator/headless checks do not substitute for device testing.
- Report exact commit, Actions run, APK artifact and SHA-256 when available.
- Never claim fun, balance, smoothness or device compatibility without appropriate playtest evidence.

## Work split
- **Design Game Studio:** game loop, mechanics, tower/enemy role design, level layouts, art direction, asset provenance, mobile interaction design and playtest criteria.
- **Software & AI Copilot:** repository mapping, Godot architecture, typed GDScript implementation, regression tests, code/security review, CI/APK workflows and evidence-based release checks.
- **Integration/QA:** reconcile both sides against the same acceptance criteria; no simulated independent agents or claims of parallel work unless real agent execution is available.
