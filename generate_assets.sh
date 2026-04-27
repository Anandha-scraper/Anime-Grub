#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v convert &>/dev/null; then
    echo "ImageMagick not found. Install it with:"
    echo "  sudo apt install imagemagick"
    exit 1
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

mkdir -p icons

# ============================================================
# BACKGROUND: anime.png with left-to-right dark gradient overlay
# ============================================================

echo "[1/3] Resize anime.png to 1920x1080..."
convert anime.png -resize 1920x1080^ -gravity Center -extent 1920x1080 "$WORK/anime_bg.png"

echo "[2/3] Create left-dark gradient overlay..."
# Four-stop horizontal gradient matching the CSS:
#   0%  -> #050008 at 88% opacity  (alpha=224)
#   38% -> #050008 at 70% opacity  (alpha=179)  stop at x=730
#   60% -> #050008 at 10% opacity  (alpha=26)   stop at x=1152
#   100%-> fully transparent       (alpha=0)
python3 - <<'PYEOF'
from PIL import Image
img = Image.new("RGBA", (1920, 1080))
r, g, b = 5, 0, 8
stops = [(0, 224), (730, 179), (1152, 26), (1920, 0)]
pixels = img.load()
for x in range(1920):
    for i in range(len(stops) - 1):
        x0, a0 = stops[i]
        x1, a1 = stops[i + 1]
        if x0 <= x <= x1:
            t = (x - x0) / (x1 - x0)
            alpha = int(a0 + t * (a1 - a0))
            break
    for y in range(1080):
        pixels[x, y] = (r, g, b, alpha)
img.save("/tmp/grub_grad_overlay.png")
PYEOF
cp /tmp/grub_grad_overlay.png "$WORK/grad_overlay.png"

echo "[3/3] Composite gradient over anime background..."
composite -compose Over "$WORK/grad_overlay.png" "$WORK/anime_bg.png" background.png
echo "  -> background.png"

# ============================================================
# SELECTION HIGHLIGHT
# ============================================================

echo "[4/6] Selection highlight (card style with yellow glow)..."
# Dark semi-transparent card fill with rounded corners
convert -size 380x60 xc:none \
    -fill "rgba(5,0,8,0.82)" \
    -draw "roundrectangle 3,3 376,56 10,10" \
    "$WORK/card_fill.png"
# Yellow border on top of fill
convert "$WORK/card_fill.png" \
    -stroke "#ffe600" -strokewidth 2 -fill none \
    -draw "roundrectangle 3,3 376,56 10,10" \
    "$WORK/card_sharp.png"
# Blur the sharp card to make an outer glow layer
convert "$WORK/card_sharp.png" -blur 0x8 "$WORK/card_glow.png"
# Composite sharp card over glow for the final effect
composite -compose Over "$WORK/card_sharp.png" "$WORK/card_glow.png" select_c.png
echo "  -> select_c.png"

# ============================================================
# ICONS: resize icon.png into every entry slot
# ============================================================

echo "[5/6] Creating icons from icon.png..."

convert icon.png -resize 128x128 "$WORK/icon_resized.png"
cp "$WORK/icon_resized.png" icons/ubuntu.png
cp "$WORK/icon_resized.png" icons/windows.png

echo "[6/6] Done! All assets created:"
ls -lh background.png select_c.png icons/
