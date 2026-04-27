#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$HOME/.local/bin:$PATH"

if ! command -v grub2-theme-preview &>/dev/null; then
    echo "grub2-theme-preview not found. Install it with:"
    echo ""
    echo "  sudo apt install grub-common qemu-system-x86 ovmf mtools xorriso"
    echo "  pip3 install --user grub2-theme-preview"
    echo ""
    echo "Then make sure ~/.local/bin is in your PATH."
    exit 1
fi

echo "Launching GRUB theme preview..."
echo "(A QEMU window will open showing the boot menu. Close it when done.)"
echo ""

grub2-theme-preview \
    --resolution 1920x1080 \
    --timeout 10 \
    --grub-cfg "$SCRIPT_DIR/grub.cfg" \
    "$SCRIPT_DIR"
