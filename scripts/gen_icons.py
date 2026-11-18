"""Genera el icono ORIGINAL de FERROLAB (horno estilizado) para web, Android e iOS.

Uso: uv run python scripts/gen_icons.py
Colores del Design System (doc 08): Sulphur Yellow, Ink, Peach Red, Light Green.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "apps" / "flutter_client"
YELLOW, INK, PEACH, GREEN, WHITE = (233, 231, 74), (23, 36, 29), (255, 114, 94), (189, 236, 193), (250, 251, 247)


def master(size: int = 1024, *, full_bleed: bool) -> Image.Image:
    """full_bleed=True: fondo a sangre (iOS, maskable). False: tarjeta redondeada (Android/web)."""
    s = size
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if full_bleed:
        d.rectangle([0, 0, s, s], fill=YELLOW)
    else:
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * .22), fill=YELLOW)
    k = .78 if full_bleed else .86  # zona segura para iconos adaptables
    def r(x0, y0, x1, y1):
        c = s / 2
        return [c + (x0 - .5) * s * k, c + (y0 - .5) * s * k, c + (x1 - .5) * s * k, c + (y1 - .5) * s * k]
    d.rounded_rectangle(r(.18, .16, .82, .84), radius=int(s * .07 * k), fill=INK)          # cuerpo del horno
    d.rounded_rectangle(r(.27, .25, .73, .60), radius=int(s * .035 * k), fill=(58, 30, 22))  # cámara
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle(r(.37, .45, .63, .55), radius=int(s * .02), fill=PEACH + (255,))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(s * .025)))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(r(.38, .46, .62, .54), radius=int(s * .015 * k), fill=PEACH)        # pieza caliente
    for i, y in enumerate((.31, .38)):                                                       # resistencias
        pts = [(r(.31 + j * .045, y, 0, 0)[0], r(0, y + (.02 if j % 2 else -.02), 0, 0)[1]) for j in range(10)]
        d.line(pts, fill=(255, 160, 80), width=max(2, int(s * .012 * k)), joint="curve")
        del i
    d.rounded_rectangle(r(.27, .67, .73, .76), radius=int(s * .02 * k), fill=WHITE)          # panel
    d.ellipse(r(.31, .69, .36, .74), fill=GREEN)
    return img


def save(img: Image.Image, path: Path, size: int, *, opaque: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if opaque:  # iOS no admite transparencia en el icono
        bg = Image.new("RGB", out.size, YELLOW)
        bg.paste(out, mask=out.split()[3])
        out = bg
    out.save(path)


def main() -> None:
    rounded, bleed = master(full_bleed=False), master(full_bleed=True)
    web = APP / "web"
    save(rounded, web / "favicon.png", 32)
    save(rounded, web / "icons" / "Icon-192.png", 192)
    save(rounded, web / "icons" / "Icon-512.png", 512)
    save(bleed, web / "icons" / "Icon-maskable-192.png", 192)
    save(bleed, web / "icons" / "Icon-maskable-512.png", 512)
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
