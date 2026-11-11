# Verdant Bastion — project direction

## Identity
An original, stylized 3D tower-defense game designed for touch-first Android play. The camera is top-down, the battlefield is a readable miniature diorama, and the art direction favors strong silhouettes, warm natural materials, saturated tower accents, and clear combat feedback.

## First playable milestone
- Procedural 3D battlefield and winding enemy route.
- Touch/mouse placement on fixed build pads.
- Three tower roles: Archer (balanced), Cannon (heavy burst), Frost (slowing support).
- Enemy waves, escalating health/speed, lives, currency and wave-clear rewards.
- Tower selection, upgrade and sell.
- Pause control and mobile-friendly HUD.
- No third-party assets or copied game content.

## Technical direction
- Godot 4.7.2 stable.
- GDScript, procedural meshes, Compatibility renderer for broad mobile support.
- Keep gameplay logic data-driven and split into systems as the project grows.
- Cloud CI must parse/import the project and run a headless smoke test before a change is called validated.
- Android export will be added after the first Godot project validation and export-template/SDK setup are verified.

## Milestones

1. **Foundation — complete:** project opens, scene loads, board renders, touch input, three tower roles, waves, upgrades/selling, pause/restart and cloud Android debug export.
2. **Combat readability — in progress:** selected-tower attack range ring, distinct Cannon/Frost/Archer silhouettes, enemy health bars, impact flashes, tower aiming, and Grunt/Runner/Brute enemy roles.
3. **Battlefield and level design:** authored terrain dressing, map identity, multiple routes and strategic build zones.
4. **Progression and content:** meaningful tower upgrade branches, persistent unlocks, campaign structure, elite enemies and original boss encounters.
5. **Release readiness:** balance pass, Android device/performance testing, accessibility options, signed release build and store preparation.

## Current combat roles
- **Grunt:** baseline enemy with standard health and movement.
- **Runner:** faster, less durable enemy introduced from wave 2.
- **Brute:** slow, high-health enemy introduced from wave 3.
- **Archer:** general-purpose single-target damage.
- **Cannon:** slower, heavy-hit tower with a visible barrel silhouette.
- **Frost:** support tower that applies a movement slow.
