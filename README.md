# Baga & Friends

![Baga & Friends illustrated cover featuring Baga, Chungus and Chuggadi](docs/images/baga-and-friends-hero.avif)

# 🎮 [Play in browser](https://jxav22.github.io/baga-and-friends/)

> **One-time setup:** GitHub Pages must be enabled once by a repo admin —  
> **Settings → Pages → Build and deployment → Source: GitHub Actions**  
> (or Source: Deploy from branch → `gh-pages` / `/`).  
> Then re-run the [Build & Deploy Web](https://github.com/jxav22/baga-and-friends/actions/workflows/deploy-web.yml) workflow.  
> Until then the play link may 404; CI **build + itch ZIP already succeed**.

Cosy offline virtual pet built in **Godot 4.3** (Compatibility renderer, single-threaded Web export).

Care for devastated Baga, play three minigames, buy cosmetics from Chungus, and follow a short Chuggadi tutorial.

## Play

- **Web (GitHub Pages):** https://jxav22.github.io/baga-and-friends/
- **Fallback branch:** `gh-pages` already hosts the latest HTML5 build (enable Pages from that branch if preferred)
- Desktop: `godot --path .` (Godot 4.3+)

## itch.io HTML5 ZIP

Automated on every `main` push:

1. Open the latest [Actions run](https://github.com/jxav22/baga-and-friends/actions/workflows/deploy-web.yml)
2. Download the **`baga-and-friends-itch-web`** artifact (`baga-and-friends-web-itch.zip`)
3. Upload that ZIP to itch.io as an **HTML5** game (embed in browser)

Local rebuild:

```bash
godot --headless --path . --export-release "Web" export/web/index.html
./scripts/package_itch_web.sh
# → dist/baga-and-friends-web-itch.zip
```

## Docs

- `HANDOFF.md` — status, deploy notes, how to run
- Project brief lives with the Cursor project store

## License

All rights reserved unless otherwise noted.
