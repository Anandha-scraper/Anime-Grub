#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v grub-mkfont &>/dev/null; then
    echo "grub-mkfont not found. Install it with:"
    echo "  sudo apt install grub2-common"
    exit 1
fi

mkdir -p fonts

# Ubuntu font paths (Ubuntu ships with the Ubuntu font family)
FONT_CANDIDATES=(
    "/usr/share/fonts/truetype/ubuntu/Ubuntu-R.ttf"
    "/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-R.ttf"
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
)

FONT_PATH=""
for candidate in "${FONT_CANDIDATES[@]}"; do
    if [[ -f "$candidate" ]]; then
        FONT_PATH="$candidate"
        break
    fi
done

if [[ -z "$FONT_PATH" ]]; then
    echo "No suitable font found. Install the Ubuntu font:"
    echo "  sudo apt install fonts-ubuntu"
    exit 1
fi

echo "Using font: $FONT_PATH"

echo "[1/5] Compiling size 13 (hint text)..."
grub-mkfont -o fonts/Ubuntu-Regular-13.pf2 -s 13 "$FONT_PATH"

echo "[2/5] Compiling size 16 (terminal fallback)..."
grub-mkfont -o fonts/Ubuntu-Regular-16.pf2 -s 16 "$FONT_PATH"

echo "[3/5] Compiling size 20 (title)..."
grub-mkfont -o fonts/Ubuntu-Regular-20.pf2 -s 20 "$FONT_PATH"

echo "[4/5] Compiling size 24 (legacy)..."
grub-mkfont -o fonts/Ubuntu-Regular-24.pf2 -s 24 "$FONT_PATH"

echo "[5/5] Compiling size 32 (menu items)..."
grub-mkfont -o fonts/Ubuntu-Regular-32.pf2 -s 32 "$FONT_PATH"

echo "Done! Fonts:"
ls -lh fonts/
echo ""
echo "NOTE: Reference fonts in theme.txt as:"
echo '  font = "Ubuntu Regular 24"'
echo "  GRUB matches the font name embedded in the .pf2 file."
