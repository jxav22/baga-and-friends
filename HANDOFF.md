# Baga & Friends — HANDOFF

**Repo:** https://github.com/jxav22/baga-and-friends  
**Engine:** Godot 4.3, typed GDScript, Compatibility renderer  
**Updated:** 2026-11-27 ~05:10 Pacific/Auckland

## How to run

```bash
godot --path .
# first-time / CI:
godot --headless --import --path .
```

Boot → MainRoom. Offline, no APIs.

## What shipped (playable MVP loop)

| Area | Status |
|------|--------|
| Layered Baga (body/hair/face/outfit/cosmetics) | Done |
| MainRoom care: Feed / Pet / Rest + needs HUD | Done |
| Chuggadi skippable tutorial + Tips replay | Done |
| Chungus Shop (12 cosmetics, buy/equip) | Done |
| Dress Up equip/unequip + live preview | Done |
| Cashew Catch (30s, coins) | Done |
| Tea Time (timing pours, coins) | Done |
| Memory Garden (6 pairs, coins) | Done |
| Save `user://save.json` | Done |
| Mute + SFX | Done |
| Theme / palette | Done |

## Contracts

Autoloads match `parallel-contracts.md`:

- `GameState.award_coins` / `spend_coins` / needs / cosmetics / tutorial
- `Inventory.owns` / `purchase` / `equip` / `unequip` / `get_equipped`
- `SceneRouter.go_room` / `go_shop` / `go_dress_up` / `go_minigame("cashew"|"tea"|"memory")`

## Parallel slices (merged to main)

| Branch | Role |
|--------|------|
| `worker/baga-room` | MainRoom + Baga care/anims |
| `worker/chungus-shop` | Shop + DressUp |
| `worker/cashew-catch` | Cashew Catch |
| `worker/tea-time` | Tea Time |
| `worker/memory-garden` | Memory Garden |
| `worker/chuggadi-tutorial` | Tutorial overlay |
| `worker/shared-polish` | Theme, palette, shared docs |

Worktrees live locally under `trees/` (gitignored).

## Economy

- Starting coins: **25** (cheap items from 15–16)
- Needs: soft decay, floor ~15–20, no death/punishment

## Known gaps / polish backlog

- Art is hand-authored raster layers (not SVG vectors); readable Baga/Chungus/Chuggadi, not placeholders
- No ambient music loop yet
- Web export verified: `godot --export-release Web export/web/index.html` succeeds
- Nested legacy paths under `scenes/baga/`, `art/`, `audio/` still present as duplicates of `assets/` + flat `scenes/`

## Verify

```bash
godot --headless --import --path .
godot --headless --path . --quit-after 5
for s in Boot MainRoom ChungusShop DressUp CashewCatch TeaTime MemoryGarden Chuggadi; do
  godot --headless --path . --scene res://scenes/$s.tscn --quit-after 2
done
```
