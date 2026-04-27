#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DEST="/boot/grub/themes/custom"
GRUB_DEFAULT="/etc/default/grub"

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Check required assets exist
for f in background.png theme.txt fonts/Ubuntu-Regular-16.pf2 icons/ubuntu.png icons/windows.png; do
    if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
        echo "Missing: $f"
        echo "Run ./generate_assets.sh and ./compile_fonts.sh first."
        exit 1
    fi
done

echo "[1/4] Installing theme to $THEME_DEST ..."
rm -rf "$THEME_DEST"
mkdir -p "$THEME_DEST"
cp -r "$SCRIPT_DIR"/. "$THEME_DEST/"
echo "  Copied."

echo "[2/4] Backing up $GRUB_DEFAULT ..."
cp "$GRUB_DEFAULT" "${GRUB_DEFAULT}.bak.$(date +%Y%m%d_%H%M%S)"

echo "[3/4] Updating $GRUB_DEFAULT ..."
# Remove any existing GRUB_THEME line
sed -i '/^GRUB_THEME=/d' "$GRUB_DEFAULT"
# Set resolution if not already set
if ! grep -q "^GRUB_GFXMODE=" "$GRUB_DEFAULT"; then
    echo 'GRUB_GFXMODE=1920x1080,auto' >> "$GRUB_DEFAULT"
fi
# Add new theme line
echo "GRUB_THEME=$THEME_DEST/theme.txt" >> "$GRUB_DEFAULT"
echo "  GRUB_THEME set to $THEME_DEST/theme.txt"

echo "[4/4] Running update-grub ..."
update-grub

echo ""
echo "Installation complete! Reboot to see the theme."
echo "To revert: sudo cp ${GRUB_DEFAULT}.bak.* $GRUB_DEFAULT && sudo update-grub"
