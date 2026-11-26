# Baga & Friends — HANDOFF

**Repo:** https://github.com/jxav22/baga-and-friends  
**Engine:** Godot 4.3, typed GDScript, Compatibility renderer  
**Updated:** 2026-11-27 Pacific/Auckland (publish sprint)

## Playable URL

**https://jxav22.github.io/baga-and-friends/**

Deployed by `.github/workflows/deploy-web.yml` on every push to `main`.

## How to run locally

```bash
godot --path .
godot --headless --import --path .
godot --headless --path . --scene res://scenes/SmokeTest.tscn
godot --headless --path . --export-release "Web" export/web/index.html
./scripts/package_itch_web.sh
```

Web preset: Compatibility + `html/single_threaded_mode=true` (`web_nothreads_release`).

## itch.io ZIP

- **Primary:** Actions artifact `baga-and-friends-itch-web` → `baga-and-friends-web-itch.zip`
- Local (gitignored): `dist/baga-and-friends-web-itch.zip`

## What shipped

| Area | Status |
|------|--------|
| Layered Baga + MainRoom care | Done |
| Chuggadi tutorial | Done |
| Chungus Shop + Dress Up (12 cosmetics) | Done |
| Three minigames + coins | Done |
| Save `user://save.json` | Done |
| Web export + Pages workflow | Done |
| itch ZIP artifact | Done |

## Manual Pages activation (if site 404)

1. Repo **Settings → Pages**
2. **Build and deployment → Source:** GitHub Actions
3. Re-run **Build & Deploy Web** (or push `main`)
4. Open https://jxav22.github.io/baga-and-friends/

## Known gaps

- No ambient music
- Raster layered art (not SVG)
- Legacy duplicate `art/` / nested scene paths remain
