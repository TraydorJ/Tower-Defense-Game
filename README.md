# Verdant Bastion

An original, stylized 3D tower-defense game for Android, built with Godot 4.7.2 and GDScript.

## Current development

The active Godot project is at the repository root:
- `project.godot` — Godot project configuration
- `scenes/main.tscn` — main 3D scene
- `scripts/game.gd` — current playable foundation
- `export_presets.cfg` — Android debug export preset
- `docs/PROJECT_DIRECTION.md` — design direction and milestone plan

Open the repository in Godot 4.7.2 and run the main scene to test locally.

## Cloud checks and Android build

- [Godot validation workflow](.github/workflows/godot-ci.yml) imports the project and runs a headless scene smoke test.
- [Android debug workflow](.github/workflows/android-debug.yml) builds an ARM64 debug APK and uploads it as a GitHub Actions artifact.
- Debug APKs are for device testing only. They are not signed for Google Play release.

## Craft Anything

The separate [Craft Anything fork](https://github.com/TraydorJ/craft-anything) is the requested clean-room study/rebuild workbench. Its upstream documentation describes a native Rust desktop app, CLI and MCP server with a Study → Build → Check → Refine workflow. It is not embedded into this game repository. This cloud workflow uses GitHub for source control and CI; Craft Anything's full agent-driven rebuild workflow requires its supported local coding-agent environment.

## Legacy web prototype

The earlier browser/PWA prototype is preserved in `index.html`, `manifest.webmanifest` and `sw.js`. It is not the active 3D game.

## Design and content

All game code and procedural 3D visuals in this project are original. The game may take broad inspiration from the tower-defense genre, but does not copy proprietary game code, maps, art, audio, names or text.
