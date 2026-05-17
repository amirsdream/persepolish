#!/usr/bin/env python3
"""
Generate a beautiful app icon for Polska — Polish learning app.
Design: Polish flag circle (white/red split) on dark navy background,
bold "P" letter with colour inversion across the split, golden accents.
Outputs: assets/icon/icon.png  (1024×1024)
"""

import math
import os
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# ── constants ────────────────────────────────────────────────────────────────
SIZE = 1024
HALF = SIZE // 2
RADIUS = SIZE // 2  # full-bleed rounded-square corners handled by stores

# Colours
NAVY        = (26,  26,  46)      # #1A1A2E  (app background)
NAVY2       = (15,  52,  96)      # #0F3460
WHITE       = (255, 255, 255)
RED         = (220,  20,  60)     # #DC143C  (Polish flag crimson)
RED_DARK    = (160,  10,  40)
GOLD        = (255, 215,   0)     # star accents
GOLD_DIM    = (200, 160,   0)


def make_radial_gradient(size, c_inner, c_outer):
    """Create a radial gradient image (inner → outer)."""
    img = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(img)
    cx = cy = size / 2
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            dist = math.hypot(x - cx, y - cy)
            t = min(dist / max_r, 1.0)
            r = int(c_inner[0] * (1 - t) + c_outer[0] * t)
            g = int(c_inner[1] * (1 - t) + c_outer[1] * t)
            b = int(c_inner[2] * (1 - t) + c_outer[2] * t)
            draw.point((x, y), (r, g, b))
    return img


def draw_star(draw, cx, cy, r, fill, n=5):
    """Draw an n-pointed star centred at (cx, cy) with outer radius r."""
    points = []
    for i in range(n * 2):
        angle = math.pi / n * i - math.pi / 2
        radius = r if i % 2 == 0 else r * 0.45
        points.append((cx + math.cos(angle) * radius,
                        cy + math.sin(angle) * radius))
    draw.polygon(points, fill=fill)


def main():
    os.makedirs(r"D:\code\b2\b2_polish\assets\icon", exist_ok=True)

    # ── 1. Background — dark radial gradient ─────────────────────────────────
    bg = make_radial_gradient(SIZE, NAVY2, NAVY)

    # ── 2. Dark vignette ring (soft glow look) ────────────────────────────────
    vignette = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    for i in range(60, 0, -1):
        alpha = int(180 * (1 - i / 60))
        vd.ellipse([HALF - HALF - i*3, HALF - HALF - i*3,
                    HALF + HALF + i*3, HALF + HALF + i*3],
                   outline=(0, 0, 0, alpha), width=6)
    bg = bg.convert("RGBA")
    bg.alpha_composite(vignette)

    # ── 3. Flag circle ────────────────────────────────────────────────────────
    circ_r = int(SIZE * 0.38)
    circ_cx, circ_cy = HALF, HALF

    # Shadow behind the circle
    shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    for offset in range(20, 0, -1):
        a = int(120 * (1 - offset / 20))
        sd.ellipse([circ_cx - circ_r - offset + 8,
                    circ_cy - circ_r - offset + 12,
                    circ_cx + circ_r + offset + 8,
                    circ_cy + circ_r + offset + 12],
                   fill=(0, 0, 0, a))
    shadow = shadow.filter(ImageFilter.GaussianBlur(12))
    bg.alpha_composite(shadow)

    # Circle mask
    circle_img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    cd = ImageDraw.Draw(circle_img)

    # White top half
    cd.ellipse([circ_cx - circ_r, circ_cy - circ_r,
                circ_cx + circ_r, circ_cy + circ_r],
               fill=(*WHITE, 255))
    # Red bottom half (overwrite lower half of the circle)
    cd.rectangle([circ_cx - circ_r - 2, circ_cy,
                  circ_cx + circ_r + 2, circ_cy + circ_r + 2],
                 fill=(*RED, 255))
    # Re-clip to circle for clean edge
    mask = Image.new("L", (SIZE, SIZE), 0)
    md = ImageDraw.Draw(mask)
    md.ellipse([circ_cx - circ_r, circ_cy - circ_r,
                circ_cx + circ_r, circ_cy + circ_r], fill=255)
    circle_img.putalpha(mask)

    # Thin white border ring around circle
    ring = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    rd.ellipse([circ_cx - circ_r - 6, circ_cy - circ_r - 6,
                circ_cx + circ_r + 6, circ_cy + circ_r + 6],
               outline=(*WHITE, 200), width=6)
    bg.alpha_composite(ring)
    bg.alpha_composite(circle_img)

    # ── 4. Letter "P" with flag inversion ────────────────────────────────────
    # We draw the letter twice: once in red (on white half) and once in white
    # (on red half), then composite so each half shows the inverted colour.

    # Try system fonts — use bold if available
    font_size = int(circ_r * 1.25)
    font = None
    for font_path in [
        "C:/Windows/Fonts/arialbd.ttf",    # Arial Bold
        "C:/Windows/Fonts/calibrib.ttf",   # Calibri Bold
        "C:/Windows/Fonts/trebucbd.ttf",   # Trebuchet Bold
        "C:/Windows/Fonts/times.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]:
        try:
            font = ImageFont.truetype(font_path, font_size)
            break
        except (IOError, OSError):
            continue
    if font is None:
        font = ImageFont.load_default()

    letter = "P"

    # Measure
    tmp = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    td = ImageDraw.Draw(tmp)
    bbox = td.textbbox((0, 0), letter, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    lx = circ_cx - tw // 2 - bbox[0]
    ly = circ_cy - th // 2 - bbox[1] - int(th * 0.05)

    # Layer A: Red "P" visible only on white (top) half
    layer_a = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    da = ImageDraw.Draw(layer_a)
    da.text((lx, ly), letter, font=font, fill=(*RED_DARK, 255))
    # mask: only top half of circle
    top_mask = Image.new("L", (SIZE, SIZE), 0)
    tmd = ImageDraw.Draw(top_mask)
    tmd.ellipse([circ_cx - circ_r, circ_cy - circ_r,
                 circ_cx + circ_r, circ_cy + circ_r], fill=255)
    tmd.rectangle([0, circ_cy, SIZE, SIZE], fill=0)
    layer_a.putalpha(top_mask)
    bg.alpha_composite(layer_a)

    # Layer B: White "P" visible only on red (bottom) half
    layer_b = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    db = ImageDraw.Draw(layer_b)
    db.text((lx, ly), letter, font=font, fill=(*WHITE, 255))
    bot_mask = Image.new("L", (SIZE, SIZE), 0)
    bmd = ImageDraw.Draw(bot_mask)
    bmd.ellipse([circ_cx - circ_r, circ_cy - circ_r,
                 circ_cx + circ_r, circ_cy + circ_r], fill=255)
    bmd.rectangle([0, 0, SIZE, circ_cy], fill=0)
    layer_b.putalpha(bot_mask)
    bg.alpha_composite(layer_b)

    # ── 5. "OLSKA" subtitle text below P ────────────────────────────────────
    sub_size = int(circ_r * 0.32)
    sub_font = None
    for font_path in [
        "C:/Windows/Fonts/arialbd.ttf",
        "C:/Windows/Fonts/calibrib.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]:
        try:
            sub_font = ImageFont.truetype(font_path, sub_size)
            break
        except (IOError, OSError):
            continue
    if sub_font is None:
        sub_font = ImageFont.load_default()

    sub_text = "OLSKA"
    sub_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sld = ImageDraw.Draw(sub_layer)
    sbbox = sld.textbbox((0, 0), sub_text, font=sub_font)
    sw = sbbox[2] - sbbox[0]
    sh = sbbox[3] - sbbox[1]
    # Position in lower red section of the circle
    sx = circ_cx - sw // 2 - sbbox[0]
    sy = circ_cy + int(circ_r * 0.30) - sbbox[1]
    sld.text((sx, sy), sub_text, font=sub_font, fill=(*WHITE, 230))
    # Clip to bottom half of circle only
    sub_mask = Image.new("L", (SIZE, SIZE), 0)
    smk = ImageDraw.Draw(sub_mask)
    smk.ellipse([circ_cx - circ_r, circ_cy - circ_r,
                 circ_cx + circ_r, circ_cy + circ_r], fill=255)
    smk.rectangle([0, 0, SIZE, circ_cy], fill=0)
    sub_layer.putalpha(sub_mask)
    bg.alpha_composite(sub_layer)

    # ── 6. Gold star accents (four corners) ──────────────────────────────────
    star_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    stard = ImageDraw.Draw(star_layer)
    angle45 = math.radians(45)
    dist = int(circ_r * 0.82)
    star_r = int(circ_r * 0.09)
    for angle_deg in [45, 135, 225, 315]:
        angle_rad = math.radians(angle_deg)
        sx2 = int(circ_cx + math.cos(angle_rad) * dist)
        sy2 = int(circ_cy + math.sin(angle_rad) * dist)
        draw_star(stard, sx2, sy2, star_r, (*GOLD, 230))
        # Tiny inner star for sparkle
        draw_star(stard, sx2, sy2, int(star_r * 0.45), (*WHITE, 200))
    bg.alpha_composite(star_layer)

    # ── 7. Subtle inner glow on top of circle ────────────────────────────────
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([circ_cx - circ_r + 30, circ_cy - circ_r + 30,
                circ_cx + 10, circ_cy + 10],
               fill=(255, 255, 255, 20))
    glow = glow.filter(ImageFilter.GaussianBlur(20))
    bg.alpha_composite(glow)

    # ── 8. Save ───────────────────────────────────────────────────────────────
    out_path = r"D:\code\b2\b2_polish\assets\icon\icon.png"
    final = bg.convert("RGBA")
    # Apply rounded corners mask (iOS/Android round the icon themselves,
    # but include rounded corners for any platform that shows it square)
    corner_r = int(SIZE * 0.22)
    round_mask = Image.new("L", (SIZE, SIZE), 0)
    rm = ImageDraw.Draw(round_mask)
    rm.rounded_rectangle([0, 0, SIZE, SIZE], radius=corner_r, fill=255)
    final.putalpha(round_mask)
    final.save(out_path, "PNG")
    print(f"Icon saved: {out_path}")

    # Also save a flat (no alpha) version for Android adaptive icon
    flat = Image.new("RGB", (SIZE, SIZE), NAVY)
    flat.paste(final.convert("RGB"), mask=final.split()[3])
    flat_path = r"D:\code\b2\b2_polish\assets\icon\icon_flat.png"
    flat.save(flat_path, "PNG")
    print(f"Flat icon saved: {flat_path}")


if __name__ == "__main__":
    main()
