# Baga & Friends — HANDOFF

**Repo:** https://github.com/jxav22/baga-and-friends  
**Engine:** Godot 4.3, typed GDScript, Compatibility renderer  
**Updated:** 2026-11-27 Pacific/Auckland (publish sprint)

## Playable URL

**Intended:** https://jxav22.github.io/baga-and-friends/

**Status:** CI **build succeeds** (smoke + Web export + itch ZIP).  
GitHub Pages **deploy** needs a one-time admin enable (API token cannot create the Pages site — 403).  
`gh-pages` branch is kept updated with the HTML5 build as a fallback source.

### Manual Pages activation (required once)

**Option A — GitHub Actions (preferred)**  
1. Open https://github.com/jxav22/baga-and-friends/settings/pages  
2. **Build and deployment → Source:** GitHub Actions  
3. Re-run https://github.com/jxav22/baga-and-friends/actions/workflows/deploy-web.yml  
4. Confirm https://jxav22.github.io/baga-and-friends/

**Option B — Branch**  
1. Same Settings → Pages  
2. Source: **Deploy from a branch** → `gh-pages` / `/ (root)`  
3. Save; wait ~1 minute; open the URL above

## How to run locally

```bash
godot --path .
godot --headless --path . --scene res://scenes/SmokeTest.tscn
godot --headless --path . --export-release "Web" export/web/index.html
./scripts/package_itch_web.sh   # → dist/baga-and-friends-web-itch.zip
```

Web preset: Compatibility + `html/single_threaded_mode=true`.

## itch.io ZIP

- **Primary:** Actions artifact `baga-and-friends-itch-web`  
- Local (gitignored): `dist/baga-and-friends-web-itch.zip`

## Browser verification (local export)

Served `export/web` at `http://127.0.0.1:8765` — loaded WASM, MainRoom, tutorial, Pet/Feed, Chungus Shop round-trip.  
Screenshots: project store `media/publish-verify/`.

## Replacement artwork (issue #1)

The active game now uses the replacement pack, with registered wearables, a clean
room, and card backs. See `docs/ART_INTEGRATION.md` for the complete source mapping,
before/after captures, reproducible build commands and visual limitations.
`scripts/prepare_art.py` is the artwork build entry point; the legacy generator
only writes ignored sketches under `export/legacy-art/`.

Godot 4.3 import, extended smoke and single-threaded Web export pass. Browser
verification covers care/tutorial, purchase/equipment persistence, all three
minigames and 1280×720, 960×540, 640×800 viewports. The tutorial practice panel now
clears care controls. Fixed 16:9 scaling keeps the character aligned with the room.

## Known defects and earlier fixes

- Pages URL 404 until admin enables Pages (steps above)
- Tutorial wait steps previously blocked Pet/Feed (fixed: dimmer passthrough while waiting)
- HUD vs room shelf overlap (fixed: needs/coins moved right)
