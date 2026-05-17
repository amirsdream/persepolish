#!/usr/bin/env python3
"""Resize the generated icon to all web icon sizes needed by Flutter web."""
import os
from PIL import Image

SRC_FLAT = r"D:\code\b2\b2_polish\assets\icon\icon_flat.png"
SRC_ALPHA = r"D:\code\b2\b2_polish\assets\icon\icon.png"
ICONS_DIR = r"D:\code\b2\b2_polish\web\icons"
FAVICON_PATH = r"D:\code\b2\b2_polish\web\favicon.png"

os.makedirs(ICONS_DIR, exist_ok=True)

flat = Image.open(SRC_FLAT).convert("RGB")
alpha = Image.open(SRC_ALPHA).convert("RGBA")

sizes = [192, 512]
for sz in sizes:
    # Regular icon (no alpha needed for web manifest)
    flat.resize((sz, sz), Image.LANCZOS).save(
        os.path.join(ICONS_DIR, f"Icon-{sz}.png"))
    print(f"  Icon-{sz}.png")

    # Maskable (same image, designed to be safe-area-friendly)
    flat.resize((sz, sz), Image.LANCZOS).save(
        os.path.join(ICONS_DIR, f"Icon-maskable-{sz}.png"))
    print(f"  Icon-maskable-{sz}.png")

# Favicon (32x32, with alpha)
alpha.resize((32, 32), Image.LANCZOS).save(FAVICON_PATH)
print(f"  favicon.png (32x32)")

print("Done.")
