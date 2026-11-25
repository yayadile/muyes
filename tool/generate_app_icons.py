"""Generate ikon launcher Muyes dari assets/icons/logo-muyes.png.

Dipakai untuk:
- Android legacy mipmap (mipmap-*dpi/ic_launcher.png)
- Android adaptive icon foreground (mipmap-*dpi/ic_launcher_foreground.png,
  canvas 108dp, logo di tengah dengan inset aman)
- iOS AppIcon.appiconset (semua ukuran, tanpa alpha — wajib RGB)

Background pakai orange brand #FFA63D (spec §8.1).

Jalankan:
    python tool/generate_app_icons.py --preview out.png   # montase preview
    python tool/generate_app_icons.py                     # tulis file ikon
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent

SRC = ROOT / "assets/icons/logo-muyes.png"
ANDROID_RES = ROOT / "android/app/src/main/res"
IOS_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"

ORANGE = (255, 166, 61)  # #FFA63D — brand primary (spec §8.1)

# Adaptive foreground: rasio sisi logo terhadap canvas 108dp.
FG_FRAC = 0.64
# iOS: rasio sisi logo terhadap sisi ikon (sisa = fill orange).
IOS_FRAC = 0.88

ANDROID_LEGACY = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

# Hidepi 108dp canvas per density.
ANDROID_FG_CANVAS = {
    "mdpi": 108,
    "hdpi": 162,
    "xhdpi": 216,
    "xxhdpi": 324,
    "xxxhdpi": 432,
}

IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def load_logo() -> Image.Image:
    return Image.open(SRC).convert("RGBA")


def circle_mask(size: int, frac: float = 1 / 3) -> Image.Image:
    """Lingkaran seukuran frac * size (default 72dp/108dp ala adaptive)."""
    mask = Image.new("L", (size, size), 0)
    r = size * frac
    c = size / 2
    ImageDraw.Draw(mask).ellipse((c - r, c - r, c + r, c + r), fill=255)
    return mask


def squircle_mask(size: int, radius_frac: float = 0.2237) -> Image.Image:
    """Kotak rounded ala squircle iOS (~22.4% radius)."""
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=size * radius_frac, fill=255
    )
    return mask


def composite(
    logo: Image.Image, canvas_size: int, frac: float, bg: tuple[int, ...]
) -> Image.Image:
    """Tempel logo (frac * canvas) di tengah kanvas berwarna bg."""
    img = Image.new("RGBA", (canvas_size, canvas_size), bg)
    side = max(1, round(canvas_size * frac))
    logo_scaled = logo.resize((side, side), Image.LANCZOS)
    off = (canvas_size - side) // 2
    img.paste(logo_scaled, (off, off), logo_scaled)
    return img


def preview(out_path: str) -> None:
    """Montase kandidat mask: Android (0.64/0.72/0.85) + iOS (100%/88%)."""
    size = 216
    logo = load_logo()
    tiles: list[Image.Image] = []

    for frac in (0.64, 0.72, 0.85):
        t = composite(logo, size, frac, (*ORANGE, 255))
        t.putalpha(circle_mask(size))
        tiles.append(t)

    for frac in (1.0, 0.88):
        t = composite(logo, size, frac, (*ORANGE, 255))
        t.putalpha(squircle_mask(size))
        tiles.append(t)

    gap = 8
    width = len(tiles) * size + (len(tiles) - 1) * gap
    montage = Image.new("RGB", (width, size), (232, 232, 232))
    x = 0
    for tile in tiles:
        montage.paste(tile, (x, 0), tile)
        x += size + gap
    montage.save(out_path)
    print(f"preview saved: {out_path}")


def generate() -> None:
    logo = load_logo()

    # Android legacy — logo penuh (sudut transparan dibiarkan).
    for density, px in ANDROID_LEGACY.items():
        path = ANDROID_RES / f"mipmap-{density}" / "ic_launcher.png"
        logo.resize((px, px), Image.LANCZOS).save(path)
        print(f"wrote {path.relative_to(ROOT)}")

    # Android adaptive foreground — kanvas 108dp transparan.
    for density, px in ANDROID_FG_CANVAS.items():
        path = ANDROID_RES / f"mipmap-{density}" / "ic_launcher_foreground.png"
        composite(logo, px, FG_FRAC, (0, 0, 0, 0)).save(path)
        print(f"wrote {path.relative_to(ROOT)}")

    # iOS — flatten ke orange, tanpa alpha (syarat App Store).
    for name, px in IOS_ICONS.items():
        path = IOS_SET / name
        composite(logo, px, IOS_FRAC, (*ORANGE, 255)).convert("RGB").save(path)
        print(f"wrote {path.relative_to(ROOT)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--preview",
        metavar="OUT",
        help="Tulis montase preview ke OUT, tidak mengubah file ikon.",
    )
    args = parser.parse_args()
    if args.preview:
        preview(args.preview)
    else:
        generate()
