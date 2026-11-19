"""Genera los íconos de FERROLAB (web, Android, iOS) a partir del logo del propietario.

Uso: uv run python scripts/gen_icons.py
Fuente: docs/assets/ferrolab_logo_source.png (tarjeta gris oscura redondeada sobre fondo blanco).
- Versión redondeada con transparencia fuera de la tarjeta: favicon, web e ícono de Android.
- Versión «a sangre» (fondo gris hasta el borde): iOS (no admite transparencia), apple-touch-icon y maskable,
  porque el sistema recorta su propia forma.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "apps" / "flutter_client"
SOURCE = ROOT / "docs" / "assets" / "ferrolab_logo_source.png"


def _card() -> tuple[Image.Image, tuple[int, int, int]]:
    """Recorta la tarjeta oscura (sin el fondo blanco) y devuelve también su color de fondo."""
    im = Image.open(SOURCE).convert("RGB")
    gray = im.convert("L")
    box = gray.point(lambda v: 255 if v < 200 else 0).getbbox()
    card = im.crop(box)
    side = max(card.size)
    sq = Image.new("RGB", (side, side), (255, 255, 255))
    sq.paste(card, ((side - card.width) // 2, (side - card.height) // 2))
    bg = sq.getpixel((side // 2, int(side * 0.06)))  # gris del fondo, arriba al centro
    return sq, bg


def _outside(card: Image.Image) -> Image.Image:
    """Máscara (255) del fondo blanco que rodea la tarjeta: relleno por inundación desde las cuatro esquinas sobre
    los píxeles claros, de modo que se respeta la forma exacta del logo y los píxeles claros del dibujo (las patas
    del horno, por ejemplo) no se tocan. Se ensancha 2 px para eliminar el halo del antialias."""
    side = card.width
    bright = card.convert("L").point(lambda v: 255 if v > 110 else 0)
    flood = bright.copy()
    for xy in ((0, 0), (side - 1, 0), (0, side - 1), (side - 1, side - 1)):
        if flood.getpixel(xy) == 255:
            ImageDraw.floodfill(flood, xy, 128)
    out = flood.point(lambda v: 255 if v == 128 else 0)
    return out.filter(ImageFilter.MaxFilter(5))


def masters() -> tuple[Image.Image, Image.Image, Image.Image]:
    card, bg = _card()
    side = card.width
    outside = _outside(card)
    inside = outside.point(lambda v: 255 - v).filter(ImageFilter.GaussianBlur(1.2))
    # 1) redondeado con transparencia (la forma de la tarjeta del propietario)
    rounded = card.convert("RGBA")
    rounded.putalpha(inside)
    # 2) a sangre: el fondo blanco se sustituye por el gris de la tarjeta
    bleed = Image.new("RGBA", (side, side), bg + (255,))
    bleed.alpha_composite(rounded)
    # 3) maskable: contenido reducido a la zona segura sobre fondo gris
    maskable = Image.new("RGBA", (side, side), bg + (255,))
    k = 0.84
    small = bleed.resize((int(side * k), int(side * k)), Image.LANCZOS)
    maskable.paste(small, ((side - small.width) // 2, (side - small.height) // 2))
    return rounded, bleed, maskable


def save(img: Image.Image, path: Path, size: int, *, opaque: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if opaque:
        out = out.convert("RGB")
    out.save(path)


def main() -> None:
    rounded, bleed, maskable = masters()
    web = APP / "web"
    save(rounded, web / "favicon.png", 32)
    save(rounded, web / "icons" / "Icon-192.png", 192)
    save(rounded, web / "icons" / "Icon-512.png", 512)
    save(maskable, web / "icons" / "Icon-maskable-192.png", 192)
    save(maskable, web / "icons" / "Icon-maskable-512.png", 512)
    save(bleed, web / "apple-touch-icon.png", 180, opaque=True)  # el iPhone lo busca primero en la raíz
    save(bleed, web / "icons" / "apple-touch-icon.png", 180, opaque=True)
    for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        save(rounded, APP / "android" / "app" / "src" / "main" / "res" / f"mipmap-{folder}" / "ic_launcher.png", px)
    iconset = APP / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    contents = json.loads((iconset / "Contents.json").read_text())
    for im in contents["images"]:
        if "filename" not in im:
            continue
        pt = float(im["size"].split("x")[0])
        scale = int(im["scale"].rstrip("x"))
        save(bleed, iconset / im["filename"], int(round(pt * scale)), opaque=True)
    save(bleed, ROOT / "docs" / "assets" / "ferrolab_icon_1024.png", 1024, opaque=True)
    print("Iconos generados")


if __name__ == "__main__":
    main()
