# Repository Guidelines

## Project Structure & Module Organization

Baga & Friends uses Godot 4.3, typed GDScript, and the Compatibility renderer.

- `project.godot` starts `scenes/Boot.tscn`. `autoload/` manages state, saves, inventory, audio, and navigation.
- `scenes/` holds scenes; `scripts/{baga,minigames,shop,tutorial}/` contains gameplay. Check `autoload/SceneRouter.gd` and scene resource references before editing similarly named nested scenes.
- Runtime textures and sounds live in `assets/`; themes live in `themes/`. `art/` contains artwork, including draft candidates in `art/replacements/`; read its README before integration.
- Smoke checks use `scenes/SmokeTest.tscn` and `scripts/smoke_test.gd`. Deployment lives in `.github/workflows/deploy-web.yml`; status notes live in `HANDOFF.md`.

## Build, Test, and Development Commands

Run from the repository root with Godot 4.3 on `PATH`. Install matching export templates for Web builds.

- `godot --editor --path .`: open the editor.
- `godot --path .`: run the game.
- `godot --headless --import --path .`: import resources after checkout.
- `godot --headless --path . --scene res://scenes/SmokeTest.tscn`: run smoke checks.
- `godot --headless --path . --export-release "Web" export/web/index.html`: export Web; create `export/web/` first.
- `bash scripts/package_itch_web.sh`: package the export into `dist/baga-and-friends-web-itch.zip`; requires Bash and `zip`.

## Coding Style & Naming Conventions

Use tabs in GDScript, typed parameters and return values, and `:=` for inferred locals. Follow `PascalCase.gd`/`.tscn` for gameplay scripts and scenes, `snake_case` for functions, variables, and signals, `_` prefixes for internal helpers, and `UPPER_SNAKE_CASE` for constants. Python uses four spaces. No formatter or linter is configured; match surrounding code. Route shared state and navigation through existing autoload APIs.

## Testing Guidelines

The custom Godot smoke scene is the automated check; no unit-test framework or coverage threshold is configured. Extend `scripts/smoke_test.gd` and its scene list when adding gameplay. Require `SMOKE PASS` and inspect output for errors. The test modifies `user://save.json`.

Manually verify affected gameplay, tutorial interactions, shop/equipment, and save/load behavior. Check visual changes in the browser export. Keep Compatibility rendering and single-threaded Web export settings intact.

## Commit & Pull Request Guidelines

History favors short, action-led subjects, such as `Add complete replacement sprite artwork pack`; scoped subjects such as `docs: ...` also occur. Keep commits focused.

PRs should describe changes, link relevant issues, list validation performed, and include screenshots for visual changes. Keep generated `.godot/`, `export/`, and `dist/` files untracked.
