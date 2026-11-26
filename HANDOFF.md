# Baga & Friends — HANDOFF

**Repo:** https://github.com/jxav22/baga-and-friends  
**Engine:** Godot 4.3, typed GDScript, Compatibility renderer  
**Updated:** 2026-11-27 (Pacific/Auckland)

## How to run

```bash
godot --path . --main-pack  # or
godot --path .
```

Main scene: `res://scenes/Boot.tscn` → `MainRoom`.

## Shared contracts

See `internal/parallel-contracts.md` in project store. Autoloads:

| Autoload | Role |
|----------|------|
| `GameState` | coins, needs, cosmetics equipped/owned, tutorial_done; `award_coins`, `spend_coins` |
| `SaveManager` | `user://save.json` |
| `CosmeticCatalog` | 12 cosmetics |
| `Inventory` | `owns`, `purchase`, `equip`, `unequip`, `get_equipped` |
| `AudioManager` | SFX + mute |
| `SceneRouter` | `go_room`, `go_shop`, `go_dress_up`, `go_minigame(id)` |

## Ownership slices

| Branch | Status |
|--------|--------|
| coordinator scaffolding | in progress |
| `worker/baga-room` | MainRoom + Baga care |
| `worker/chungus-shop` | Shop + DressUp |
| `worker/cashew-catch` | Cashew Catch |
| `worker/tea-time` | Tea Time |
| `worker/memory-garden` | Memory Garden |
| `worker/chuggadi-tutorial` | Tutorial overlay |
| `worker/shared-polish` | theme/sfx/palette |

## Starting economy

- Starting coins: **25** (enough for cheapest item at 15–16)
- Needs: forgiving decay, floor soft, no death

## Save

`user://save.json` — coins, owned, equipped, hunger/energy/happiness, tutorial_done, muted.

## Known gaps

Tracked as slices land; keep this section current on each merge.
