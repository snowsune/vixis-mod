#!/usr/bin/env python3
"""Stitch rendered Blender frames into the load-shed breaker spritesheets.

Render graphics/blender/Breaker.blend (frames 1-100) as 400x705 RGBA PNGs
named 0001.png ... 0100.png. By default frames are read from
graphics/entity/load-shed-breaker/ (where they're gitignored); pass another
folder to read them from there instead. Sheets are always written to
graphics/entity/load-shed-breaker/.

If you change a frame count below, also update frame_count/line_length in
prototypes/load-shed-breaker-animations.lua and the frame count in VIS in
control.lua. tripped.png is also the entity's base sprite in
prototypes/load-shed-breaker-entity.lua. Sprites are drawn at scale = 0.5.

Needs Pillow (`pacman -S python-pillow` or `pip install pillow`).
"""
import argparse
import sys
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parent.parent
OUT_DIR = REPO / "graphics/entity/load-shed-breaker"
W, H = 400, 705

# name: (first frame, last frame, columns). Ranges are inclusive Blender frame numbers.
SHEETS = {
    "on-idle":     (100, 100, 1),   # vixis-load-shed-on
    "closed-hold": (97, 97, 1),     # vixis-load-shed-closed-hold
    "eject":       (6, 66, 20),     # vixis-load-shed-eject
    "tripped":     (60, 60, 1),     # vixis-load-shed-tripped
    "reset":       (80, 99, 20),    # vixis-load-shed-reset
}


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("frames", nargs="?", type=Path, default=OUT_DIR,
                        help=f"folder holding 0001.png... (default: {OUT_DIR.relative_to(REPO)})")
    src = parser.parse_args().frames

    missing = sorted({f"{n:04d}.png" for a, b, _ in SHEETS.values() for n in range(a, b + 1)
                      if not (src / f"{n:04d}.png").exists()})
    if missing:
        sys.exit(f"{len(missing)} frame(s) missing from {src}: {', '.join(missing[:5])}...")

    for name, (first, last, cols) in SHEETS.items():
        frames = [src / f"{n:04d}.png" for n in range(first, last + 1)]
        rows = -(-len(frames) // cols)
        sheet = Image.new("RGBA", (W * cols, H * rows), (0, 0, 0, 0))
        for i, path in enumerate(frames):
            im = Image.open(path).convert("RGBA")
            if im.size != (W, H):
                sys.exit(f"{path} is {im.size}, expected {(W, H)}")
            sheet.paste(im, ((i % cols) * W, (i // cols) * H))
        sheet.save(OUT_DIR / f"{name}.png", optimize=True)
        print(f"{name}.png: frames {first}-{last} ({len(frames)}), {cols}x{rows} -> {sheet.size}")


if __name__ == "__main__":
    main()
