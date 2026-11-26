#!/usr/bin/env python3
"""Generate layered character and UI art for Baga & Friends MVP."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "art"

# Warm muted palette
IVORY = (245, 236, 220, 255)
CREAM = (236, 220, 190, 255)
GOLD = (196, 154, 74, 255)
MUTED_GOLD = (180, 145, 80, 255)
SOFT_BROWN = (122, 86, 58, 255)
DARK_BROWN = (74, 48, 32, 255)
CHARCOAL = (54, 46, 42, 255)
SAGE = (138, 156, 122, 255)
DUSTY_PINK = (196, 142, 148, 255)
PINK_NOSE = (220, 140, 150, 255)
TEAR = (170, 200, 220, 200)
WHITE = (252, 248, 242, 255)
SKIN = (232, 198, 172, 255)
SKIRT = (62, 52, 48, 255)
SHOE_BROWN = (110, 72, 42, 255)
OUTLINE = (42, 34, 30, 255)


def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def oval(d: ImageDraw.ImageDraw, box, fill, outline=OUTLINE, width=3):
    d.ellipse(box, fill=fill, outline=outline, width=width)


def poly(d: ImageDraw.ImageDraw, pts, fill, outline=OUTLINE):
    d.polygon(pts, fill=fill, outline=outline)


def save(img: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    print(f"wrote {path.relative_to(ROOT)}")


def make_baga_layers():
    w, h = 256, 320
    # Body (legs + torso base)
    body = new(w, h)
    d = ImageDraw.Draw(body)
    # Legs
    oval(d, (88, 230, 118, 290), SKIN)
    oval(d, (138, 230, 168, 290), SKIN)
    # Torso soft shape under shirt
    oval(d, (78, 150, 178, 250), SKIN)
    save(body, ART / "baga" / "body.png")

    # Skirt
    skirt = new(w, h)
    d = ImageDraw.Draw(skirt)
    poly(d, [(72, 210), (184, 210), (196, 255), (60, 255)], SKIRT)
    # Pleats
    for x in range(80, 180, 16):
        d.line([(x, 212), (x - 4, 254)], fill=(35, 28, 24, 255), width=2)
    save(skirt, ART / "baga" / "skirt.png")

    # Shirt
    shirt = new(w, h)
    d = ImageDraw.Draw(shirt)
    poly(d, [(70, 145), (186, 145), (200, 230), (56, 230)], CREAM)
    # Sleeves
    oval(d, (40, 155, 85, 205), CREAM)
    oval(d, (171, 155, 216, 205), CREAM)
    # Cashew emblem
    oval(d, (108, 170, 148, 210), MUTED_GOLD, width=2)
    poly(d, [(118, 178), (140, 188), (126, 202), (114, 190)], GOLD)
    d.arc((112, 176, 144, 206), 20, 220, fill=OUTLINE, width=2)
    save(shirt, ART / "baga" / "shirt.png")

    # Shoes
    shoes = new(w, h)
    d = ImageDraw.Draw(shoes)
    oval(d, (78, 275, 120, 302), SHOE_BROWN)
    oval(d, (136, 275, 178, 302), SHOE_BROWN)
    oval(d, (98, 282, 120, 298), WHITE, width=2)
    oval(d, (156, 282, 178, 298), WHITE, width=2)
    save(shoes, ART / "baga" / "shoes.png")

    # Head
    head = new(w, h)
    d = ImageDraw.Draw(head)
    oval(d, (78, 48, 178, 158), SKIN)
    # Ears feline-ish soft
    poly(d, [(82, 78), (70, 38), (104, 62)], SKIN)
    poly(d, [(174, 78), (186, 38), (152, 62)], SKIN)
    # Inner ear
    poly(d, [(84, 72), (78, 48), (98, 64)], DUSTY_PINK, outline=None)
    poly(d, [(172, 72), (178, 48), (158, 64)], DUSTY_PINK, outline=None)
    save(head, ART / "baga" / "head.png")

    # Hair messy dark brown
    hair = new(w, h)
    d = ImageDraw.Draw(hair)
    oval(d, (72, 30, 184, 110), DARK_BROWN)
    # Messy tufts
    for pts in [
        [(90, 40), (78, 10), (108, 35)],
        [(118, 28), (128, 2), (142, 30)],
        [(150, 35), (170, 8), (178, 42)],
        [(70, 70), (55, 55), (82, 85)],
        [(186, 70), (205, 52), (178, 88)],
    ]:
        poly(d, pts, DARK_BROWN)
    # Bangs covering forehead
    poly(d, [(86, 70), (100, 95), (120, 78), (140, 98), (160, 76), (174, 92), (178, 68), (86, 55)], DARK_BROWN)
    save(hair, ART / "baga" / "hair.png")

    # Face: always devastated crying kitten
    face = new(w, h)
    d = ImageDraw.Draw(face)
    # Watery glossy eyes
    oval(d, (98, 88, 124, 118), WHITE, width=2)
    oval(d, (132, 88, 158, 118), WHITE, width=2)
    oval(d, (106, 96, 118, 112), CHARCOAL, width=1)
    oval(d, (140, 96, 152, 112), CHARCOAL, width=1)
    # Gloss highlights
    oval(d, (108, 98, 112, 102), WHITE, width=0)
    oval(d, (142, 98, 146, 102), WHITE, width=0)
    # Soft sad brows
    d.arc((96, 78, 126, 100), 200, 330, fill=SOFT_BROWN, width=3)
    d.arc((130, 78, 160, 100), 210, 340, fill=SOFT_BROWN, width=3)
    # Pink feline nose
    poly(d, [(124, 118), (132, 118), (128, 124)], PINK_NOSE)
    # Whiskers
    d.line([(90, 120), (70, 116)], fill=CHARCOAL, width=2)
    d.line([(90, 126), (68, 128)], fill=CHARCOAL, width=2)
    d.line([(166, 120), (186, 116)], fill=CHARCOAL, width=2)
    d.line([(166, 126), (188, 128)], fill=CHARCOAL, width=2)
    # Devastated wobble mouth
    d.arc((116, 128, 140, 146), 20, 160, fill=CHARCOAL, width=3)
    # Tears
    oval(d, (102, 116, 110, 136), TEAR, width=0)
    oval(d, (146, 116, 154, 138), TEAR, width=0)
    oval(d, (104, 134, 110, 148), TEAR, width=0)
    oval(d, (148, 136, 154, 150), TEAR, width=0)
    # Blush
    oval(d, (90, 118, 104, 128), (*DUSTY_PINK[:3], 90), width=0)
    oval(d, (152, 118, 166, 128), (*DUSTY_PINK[:3], 90), width=0)
    save(face, ART / "baga" / "face.png")

    # Composite preview
    preview = new(w, h)
    for name in ["body", "skirt", "shirt", "shoes", "head", "hair", "face"]:
        layer = Image.open(ART / "baga" / f"{name}.png")
        preview = Image.alpha_composite(preview, layer)
    save(preview, ART / "baga" / "preview.png")


def make_chungus():
    w, h = 280, 240
    img = new(w, h)
    d = ImageDraw.Draw(img)
    # Big fluffy body
    oval(d, (30, 50, 250, 220), WHITE)
    # Dark patches
    oval(d, (50, 90, 110, 160), (72, 64, 58, 255), width=2)
    oval(d, (170, 70, 230, 130), (72, 64, 58, 255), width=2)
    oval(d, (140, 150, 200, 205), (72, 64, 58, 200), width=2)
    # Head bump
    oval(d, (80, 20, 200, 120), WHITE)
    # Ears
    poly(d, [(90, 50), (78, 12), (115, 40)], WHITE)
    poly(d, [(190, 50), (202, 12), (165, 40)], WHITE)
    poly(d, [(92, 46), (86, 24), (108, 40)], DUSTY_PINK, outline=None)
    poly(d, [(188, 46), (194, 24), (172, 40)], DUSTY_PINK, outline=None)
    # Sleepy eyes
    d.arc((105, 60, 135, 85), 200, 340, fill=CHARCOAL, width=4)
    d.arc((145, 60, 175, 85), 200, 340, fill=CHARCOAL, width=4)
    # Nose
    poly(d, [(135, 88), (145, 88), (140, 96)], PINK_NOSE)
    # Mouth tiny
    d.arc((128, 94, 152, 112), 10, 170, fill=CHARCOAL, width=2)
    # Whiskers
    d.line([(100, 95), (60, 88)], fill=CHARCOAL, width=2)
    d.line([(100, 102), (58, 105)], fill=CHARCOAL, width=2)
    d.line([(180, 95), (220, 88)], fill=CHARCOAL, width=2)
    d.line([(180, 102), (222, 105)], fill=CHARCOAL, width=2)
    # Soft paws
    oval(d, (70, 185, 120, 220), WHITE)
    oval(d, (160, 185, 210, 220), WHITE)
    save(img, ART / "chungus" / "chungus.png")


def make_chuggadi():
    w, h = 180, 180
    img = new(w, h)
    d = ImageDraw.Draw(img)
    # Round bird body cream/golden-brown
    oval(d, (30, 40, 150, 160), CREAM)
    oval(d, (45, 70, 135, 155), (210, 170, 110, 255), width=2)
    # Wing
    oval(d, (25, 80, 70, 130), MUTED_GOLD)
    oval(d, (110, 80, 155, 130), MUTED_GOLD)
    # Head
    oval(d, (50, 20, 130, 95), CREAM)
    # Beak
    poly(d, [(85, 70), (110, 78), (85, 86)], GOLD)
    # Eyes cute dots
    oval(d, (68, 48, 82, 64), CHARCOAL, width=1)
    oval(d, (98, 48, 112, 64), CHARCOAL, width=1)
    oval(d, (72, 52, 76, 56), WHITE, width=0)
    oval(d, (102, 52, 106, 56), WHITE, width=0)
    # Tiny crest
    poly(d, [(85, 28), (90, 8), (98, 28)], GOLD)
    # Feet
    d.line([(75, 155), (70, 172)], fill=GOLD, width=3)
    d.line([(105, 155), (110, 172)], fill=GOLD, width=3)
    d.line([(68, 172), (78, 172)], fill=GOLD, width=3)
    d.line([(102, 172), (118, 172)], fill=GOLD, width=3)
    save(img, ART / "chuggadi" / "chuggadi.png")


def make_cosmetics():
    items = {
        "hat_beanie": _beanie,
        "hat_chef": _chef,
        "hat_cowboy": _cowboy,
        "hat_flower_crown": _flower_crown,
        "accessory_bow": _bow,
        "accessory_spectacles": _spectacles,
        "outfit_raincoat": _raincoat,
        "feet_duck_slippers": _duck_slippers,
        "room_rug": _rug,
        "room_plant": _plant,
        "room_cushion": _cushion,
        "room_chungus_pic": _chungus_pic,
    }
    for name, fn in items.items():
        img = fn()
        save(img, ART / "cosmetics" / f"{name}.png")
        # shop icon = scaled
        icon = img.resize((96, 96), Image.Resampling.LANCZOS)
        save(icon, ART / "cosmetics" / f"{name}_icon.png")


def _beanie() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    oval(d, (78, 18, 178, 90), SAGE)
    poly(d, [(78, 55), (178, 55), (178, 72), (78, 72)], SOFT_BROWN)
    oval(d, (120, 8, 136, 24), DUSTY_PINK)
    return img


def _chef() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    oval(d, (95, 5, 160, 55), WHITE)
    oval(d, (85, 30, 170, 70), WHITE)
    poly(d, [(90, 60), (166, 60), (166, 78), (90, 78)], WHITE)
    return img


def _cowboy() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    oval(d, (55, 55, 200, 90), SOFT_BROWN)
    poly(d, [(90, 30), (166, 30), (175, 65), (80, 65)], MUTED_GOLD)
    d.rectangle((88, 48, 168, 58), fill=DARK_BROWN)
    return img


def _flower_crown() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    colors = [DUSTY_PINK, MUTED_GOLD, SAGE, (200, 160, 120, 255), PINK_NOSE]
    positions = [(90, 40), (110, 28), (130, 26), (150, 32), (165, 48), (80, 55)]
    for (x, y), c in zip(positions, colors * 2):
        oval(d, (x, y, x + 22, y + 22), c, width=2)
        oval(d, (x + 7, y + 7, x + 15, y + 15), GOLD, width=0)
    return img


def _bow() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    poly(d, [(70, 150), (105, 165), (70, 180)], DUSTY_PINK)
    poly(d, [(105, 165), (140, 150), (140, 180)], DUSTY_PINK)
    oval(d, (98, 158, 112, 172), MUTED_GOLD)
    return img


def _spectacles() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    oval(d, (94, 90, 126, 120), (0, 0, 0, 0), outline=CHARCOAL, width=3)
    oval(d, (130, 90, 162, 120), (0, 0, 0, 0), outline=CHARCOAL, width=3)
    d.line([(126, 105), (130, 105)], fill=CHARCOAL, width=3)
    d.line([(94, 105), (84, 100)], fill=CHARCOAL, width=2)
    d.line([(162, 105), (172, 100)], fill=CHARCOAL, width=2)
    return img


def _raincoat() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    poly(d, [(68, 145), (188, 145), (205, 245), (50, 245)], SAGE)
    oval(d, (38, 150, 80, 210), SAGE)
    oval(d, (176, 150, 218, 210), SAGE)
    # Hood
    oval(d, (85, 120, 170, 165), (120, 140, 108, 255))
    d.line([(128, 145), (128, 240)], fill=IVORY, width=2)
    return img


def _duck_slippers() -> Image.Image:
    img = new(256, 320)
    d = ImageDraw.Draw(img)
    for ox in (78, 140):
        oval(d, (ox, 275, ox + 45, 305), MUTED_GOLD)
        oval(d, (ox + 28, 280, ox + 48, 295), GOLD)
        oval(d, (ox + 8, 282, ox + 16, 290), CHARCOAL, width=1)
    return img


def _rug() -> Image.Image:
    img = new(320, 120)
    d = ImageDraw.Draw(img)
    oval(d, (10, 20, 310, 100), DUSTY_PINK)
    oval(d, (40, 35, 280, 85), (*IVORY[:3], 180), width=0)
    return img


def _plant() -> Image.Image:
    img = new(120, 160)
    d = ImageDraw.Draw(img)
    poly(d, [(35, 90), (85, 90), (95, 155), (25, 155)], SOFT_BROWN)
    oval(d, (20, 20, 70, 90), SAGE)
    oval(d, (50, 10, 100, 80), (110, 140, 100, 255))
    oval(d, (35, 40, 85, 100), (150, 170, 130, 255))
    return img


def _cushion() -> Image.Image:
    img = new(140, 90)
    d = ImageDraw.Draw(img)
    oval(d, (5, 15, 135, 80), MUTED_GOLD)
    oval(d, (25, 28, 115, 68), GOLD, width=2)
    return img


def _chungus_pic() -> Image.Image:
    img = new(100, 120)
    d = ImageDraw.Draw(img)
    d.rectangle((5, 5, 95, 115), fill=SOFT_BROWN, outline=OUTLINE, width=3)
    d.rectangle((15, 15, 85, 95), fill=IVORY, outline=OUTLINE, width=2)
    # Mini chungus face
    oval(d, (28, 30, 72, 70), WHITE)
    d.arc((35, 42, 48, 55), 200, 340, fill=CHARCOAL, width=2)
    d.arc((52, 42, 65, 55), 200, 340, fill=CHARCOAL, width=2)
    poly(d, [(48, 55), (52, 55), (50, 60)], PINK_NOSE)
    d.text((22, 98), "CHUNGUS", fill=CHARCOAL)
    return img


def make_room_and_ui():
    # Room background
    bg = Image.new("RGBA", (1280, 720), IVORY)
    d = ImageDraw.Draw(bg)
    # Wall
    d.rectangle((0, 0, 1280, 420), fill=(232, 220, 200, 255))
    # Soft window
    d.rectangle((900, 60, 1180, 280), fill=(190, 210, 200, 255), outline=OUTLINE, width=4)
    d.line([(1040, 60), (1040, 280)], fill=OUTLINE, width=3)
    d.line([(900, 170), (1180, 170)], fill=OUTLINE, width=3)
    # Floor
    d.rectangle((0, 420, 1280, 720), fill=(210, 185, 150, 255))
    # Floor boards
    for y in range(440, 720, 36):
        d.line([(0, y), (1280, y)], fill=(190, 165, 130, 255), width=2)
    # Shelf
    d.rectangle((40, 80, 320, 100), fill=SOFT_BROWN)
    d.rectangle((50, 100, 70, 180), fill=DARK_BROWN)
    d.rectangle((290, 100, 310, 180), fill=DARK_BROWN)
    # Soft light wash
    wash = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wash)
    wd.ellipse((700, -40, 1300, 360), fill=(255, 240, 200, 40))
    bg = Image.alpha_composite(bg, wash)
    save(bg, ART / "room" / "main_room.png")

    # Cashew collectible
    cashew = new(48, 48)
    d = ImageDraw.Draw(cashew)
    oval(d, (8, 10, 40, 40), MUTED_GOLD)
    poly(d, [(14, 18), (34, 24), (22, 36), (12, 28)], GOLD)
    save(cashew, ART / "ui" / "cashew.png")

    # Coin
    coin = new(40, 40)
    d = ImageDraw.Draw(coin)
    oval(d, (2, 2, 38, 38), GOLD)
    oval(d, (8, 8, 32, 32), MUTED_GOLD, width=2)
    d.text((13, 10), "$", fill=IVORY)
    save(coin, ART / "ui" / "coin.png")

    # Button panel texture
    panel = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(panel)
    d.rounded_rectangle((0, 0, 255, 63), radius=16, fill=CREAM, outline=OUTLINE, width=3)
    save(panel, ART / "ui" / "panel.png")

    # Tea cup for tea time
    cup = new(80, 80)
    d = ImageDraw.Draw(cup)
    poly(d, [(15, 25), (65, 25), (58, 70), (22, 70)], IVORY)
    d.arc((60, 30, 78, 55), 270, 90, fill=OUTLINE, width=3)
    oval(d, (18, 18, 62, 35), (160, 120, 80, 255), width=2)
    save(cup, ART / "ui" / "teacup.png")

    # Memory card back
    card = new(96, 96)
    d = ImageDraw.Draw(card)
    d.rounded_rectangle((4, 4, 92, 92), radius=12, fill=SAGE, outline=OUTLINE, width=3)
    oval(d, (28, 28, 68, 68), MUTED_GOLD)
    save(card, ART / "ui" / "card_back.png")


def make_memory_icons():
    icons = {
        "leaf": SAGE,
        "seed": MUTED_GOLD,
        "berry": DUSTY_PINK,
        "cloud": (200, 210, 220, 255),
        "star": GOLD,
        "shell": CREAM,
    }
    for name, color in icons.items():
        img = new(80, 80)
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((4, 4, 76, 76), radius=10, fill=IVORY, outline=OUTLINE, width=3)
        oval(d, (18, 18, 62, 62), color)
        save(img, ART / "ui" / f"mem_{name}.png")


def main():
    make_baga_layers()
    make_chungus()
    make_chuggadi()
    make_cosmetics()
    make_room_and_ui()
    make_memory_icons()
    print("art generation complete")


if __name__ == "__main__":
    main()
