#!/usr/bin/env python3
"""Pack approved source art into stable Godot texture contracts (Pillow 12.2).

No generation or network calls. Candidates are immutable; reviewed refinements live
in art/production. Run --check in CI to detect stale outputs or accidental copies.
"""
from __future__ import annotations

import argparse
import io
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
CANDIDATES = ROOT / "art/replacements"
PRODUCTION = ROOT / "art/production"
LAYERS = ("body", "skirt", "shirt", "shoes", "head", "hair", "face")
CANVAS = (256, 320)
# Visible bounds in the common Baga coordinate system, never individual centering.
WEARABLES = {
    "hat_beanie": (86, 1, 178, 98),
    "hat_chef": (71, 1, 185, 97),
    "hat_cowboy": (55, 1, 207, 91),
    "hat_flower_crown": (58, 12, 198, 84),
    "accessory_bow": (115, 168, 151, 196),
    "accessory_spectacles": (65, 89, 195, 136),
    "outfit_raincoat": (57, 166, 207, 260),
    "feet_duck_slippers": (83, 257, 189, 317),
}
DECOR = {
    "room_rug": (320, 120), "room_plant": (120, 160),
    "room_cushion": (140, 90), "room_chungus_pic": (100, 120),
}


def read(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def trim(image: Image.Image, threshold: int = 0) -> Image.Image:
    alpha = image.getchannel("A")
    bounds = alpha.point(lambda a: 255 if a > threshold else 0).getbbox()
    if bounds is None:
        raise ValueError("Empty source image")
    return image.crop(bounds)


def fit(image: Image.Image, size: tuple[int, int], margin: int = 0) -> Image.Image:
    """Uniform scale with transparent padding; never stretch a standalone item."""
    content = ImageOps.contain(image, (size[0] - margin * 2, size[1] - margin * 2), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size)
    canvas.alpha_composite(content, ((size[0] - content.width) // 2, (size[1] - content.height) // 2))
    return canvas


def place(image: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    canvas = Image.new("RGBA", CANVAS)
    packed = fit(image, (box[2] - box[0], box[3] - box[1]))
    canvas.alpha_composite(packed, box[:2])
    return canvas


def mask(image: Image.Image) -> Image.Image:
    return image.getchannel("A").point(lambda a: 255 if a > 0 else 0)


def prepare_layers() -> dict[str, Image.Image]:
    target = read(CANDIDATES / "baga/preview.png")
    sources = {name: read(CANDIDATES / f"baga/{name}.png") for name in LAYERS}
    result = {}
    # Restore hidden torso from the approved underpainting, confined to clothing
    # coverage. Visible hands/legs and the outside silhouette always use the target.
    body = read(PRODUCTION / "baga/body_underlay.png").resize(CANVAS, Image.Resampling.LANCZOS)
    clothing = ImageChops.lighter(mask(sources["shirt"]), mask(sources["skirt"]))
    body.putalpha(ImageChops.multiply(body.getchannel("A"), clothing.filter(ImageFilter.MinFilter(5))))
    for name in LAYERS:
        # A two-pixel overlap copies the SAME target pixels under adjacent pieces,
        # eliminating partition seams without moving or independently resizing art.
        coverage = mask(sources[name]).filter(ImageFilter.MaxFilter(5))
        if name == "head":
            # The target supplies the complete face backing beneath the Face layer.
            # Retain registration and fill its missing centre, not a flattened rig.
            coverage = ImageChops.lighter(coverage, mask(sources["face"]))
        piece = target.copy()
        piece.putalpha(ImageChops.multiply(target.getchannel("A"), coverage))
        if name == "body":
            body.alpha_composite(piece)
            piece = body
        # Avoid storing unrelated RGB pixels in transparent portions of each layer.
        clean = Image.new("RGBA", CANVAS)
        clean.paste(piece, mask=mask(piece))
        piece = clean
        result[name] = piece
    preview = Image.new("RGBA", CANVAS)
    for name in LAYERS:
        preview.alpha_composite(result[name])
    result["preview"] = preview
    return result


def build() -> dict[str, Image.Image]:
    output = {f"assets/baga/{name}.png": image for name, image in prepare_layers().items()}
    for name, size in (("chungus", (280, 240)), ("chuggadi", (180, 180))):
        output[f"assets/{name}/{name}.png"] = fit(read(CANDIDATES / f"{name}/{name}.png"), size, 4)
    for name, box in WEARABLES.items():
        source = read(CANDIDATES / f"cosmetics/{name}.png")
        if name == "outfit_raincoat":
            source = read(PRODUCTION / "cosmetics/outfit_raincoat.png")
            # Discard very faint export matte outside the painted silhouette.
            source.putalpha(source.getchannel("A").point(lambda a: 0 if a < 128 else min(255, (a - 128) * 2)))
        source = trim(source)
        output[f"assets/cosmetics/{name}.png"] = place(source, box)
        # Icon uses the unregistered object, not a shrunk 256x320 overlay.
        output[f"assets/cosmetics/{name}_icon.png"] = fit(source, (96, 96), 5)
    for name, size in DECOR.items():
        source = trim(read(CANDIDATES / f"cosmetics/{name}.png"))
        output[f"assets/cosmetics/{name}.png"] = fit(source, size, 2)
        output[f"assets/cosmetics/{name}_icon.png"] = fit(source, (96, 96), 5)
    room = read(PRODUCTION / "room/main_room.png")
    output["assets/room/main_room.png"] = ImageOps.fit(room, (1280, 720), Image.Resampling.LANCZOS)
    for name, size in {
        "cashew": (48, 48), "teacup": (80, 80), "card_back": (96, 96),
        **{f"mem_{name}": (80, 80) for name in ("leaf", "seed", "berry", "cloud", "star", "shell")},
    }.items():
        output[f"assets/shared/{name}.png"] = fit(trim(read(CANDIDATES / f"ui/{name}.png")), size, 4)
    output["assets/minigames/cashew/cashew.png"] = output["assets/shared/cashew.png"]
    # coin/panel are intentionally unused; do not add dead UI merely to consume art.
    return output


def audit(output: dict[str, Image.Image]) -> list[dict]:
    rows = []
    for path in sorted(CANDIDATES.rglob("*.png")):
        rel = path.relative_to(CANDIDATES).as_posix()
        image = read(path)
        destination = "assets/" + rel.replace("ui/", "shared/")
        status = "integrated"
        if rel in ("ui/coin.png", "ui/panel.png"):
            status = "unused: no active consumer; existing theme supplies scalable panels"
        elif rel.endswith("_icon.png"):
            status = "reference: rebuilt from corresponding object for consistent margins"
        elif rel in ("baga/preview.png", "room/main_room.png", "cosmetics/outfit_raincoat.png"):
            status = "source: recomposed layers or reviewed production refinement"
        rows.append({
            "candidate": rel, "size": list(image.size), "mode": Image.open(path).mode,
            "alpha_range": list(image.getchannel("A").getextrema()),
            "visible_bounds": list(image.getbbox()), "status": status,
            "runtime": destination if destination in output else None,
            "runtime_size": list(output[destination].size) if destination in output else None,
            "anchor_box": list(WEARABLES[path.stem]) if path.stem in WEARABLES else None,
        })
    if len(rows) != 46:
        raise ValueError(f"Expected 46 candidates, found {len(rows)}")
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="verify committed outputs without writing")
    args = parser.parse_args()
    output = build()
    files = {}
    for path, image in output.items():
        buffer = io.BytesIO()
        image.save(buffer, format="PNG", optimize=True)
        files[path] = buffer.getvalue()
    files["art/production/manifest.json"] = (json.dumps(audit(output), indent=2) + "\n").encode()
    stale = []
    for path, data in files.items():
        target = ROOT / path
        if args.check:
            if path.endswith(".png") and target.exists():
                current = read(target)
                expected = output[path]
                equal = current.size == expected.size and current.tobytes() == expected.tobytes()
            else:
                equal = target.exists() and target.read_bytes() == data
            if not equal:
                stale.append(path)
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    if stale:
        raise SystemExit("Stale art; run python scripts/prepare_art.py:\n" + "\n".join(stale))
    print(f"ART {'CHECK' if args.check else 'BUILD'} PASS: {len(output)} runtime PNGs, 46 candidates accounted for")


if __name__ == "__main__":
    main()
