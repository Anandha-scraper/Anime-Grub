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

echo "[1/5] Checking os-prober for Windows detection ..."

if ! dpkg -s os-prober &>/dev/null 2>&1; then
    echo "  os-prober not found — installing..."
    apt-get install -y os-prober
    echo "  os-prober installed."
else
    echo "  os-prober already installed."
fi

if grep -q '^GRUB_DISABLE_OS_PROBER=' "$GRUB_DEFAULT"; then
    sed -i 's|^GRUB_DISABLE_OS_PROBER=.*|GRUB_DISABLE_OS_PROBER=false|' "$GRUB_DEFAULT"
    echo "  GRUB_DISABLE_OS_PROBER set to false."
else
    echo 'GRUB_DISABLE_OS_PROBER=false' >> "$GRUB_DEFAULT"
    echo "  GRUB_DISABLE_OS_PROBER=false appended."
fi

echo "[2/5] Installing theme to $THEME_DEST ..."
rm -rf "$THEME_DEST"
mkdir -p "$THEME_DEST"
cp -r "$SCRIPT_DIR"/. "$THEME_DEST/"
echo "  Copied."

echo "[3/5] Backing up $GRUB_DEFAULT ..."
cp "$GRUB_DEFAULT" "${GRUB_DEFAULT}.bak.$(date +%Y%m%d_%H%M%S)"

echo "[4/5] Updating $GRUB_DEFAULT ..."
# Remove any existing GRUB_THEME line
sed -i '/^GRUB_THEME=/d' "$GRUB_DEFAULT"
# Enable quiet splash to suppress boot text after OS selection
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_DEFAULT"; then
    if ! grep -q 'quiet' "$GRUB_DEFAULT"; then
        sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash \1"|' "$GRUB_DEFAULT"
        echo "  Added quiet splash to GRUB_CMDLINE_LINUX_DEFAULT."
    else
        echo "  quiet splash already set."
    fi
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' >> "$GRUB_DEFAULT"
    echo "  GRUB_CMDLINE_LINUX_DEFAULT=quiet splash appended."
fi
# Set resolution if not already set
if ! grep -q "^GRUB_GFXMODE=" "$GRUB_DEFAULT"; then
    echo 'GRUB_GFXMODE=1920x1080,auto' >> "$GRUB_DEFAULT"
fi
# Disable auto-boot timeout (wait for user input)
if grep -q '^GRUB_TIMEOUT=' "$GRUB_DEFAULT"; then
    sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=-1|' "$GRUB_DEFAULT"
    echo "  GRUB_TIMEOUT set to -1 (wait indefinitely)."
else
    echo 'GRUB_TIMEOUT=-1' >> "$GRUB_DEFAULT"
    echo "  GRUB_TIMEOUT=-1 appended."
fi
# Add new theme line
echo "GRUB_THEME=$THEME_DEST/theme.txt" >> "$GRUB_DEFAULT"
echo "  GRUB_THEME set to $THEME_DEST/theme.txt"

# Hide recovery mode entries
if ! grep -q "^GRUB_DISABLE_RECOVERY=" "$GRUB_DEFAULT"; then
    echo 'GRUB_DISABLE_RECOVERY=true' >> "$GRUB_DEFAULT"
else
    sed -i 's|^GRUB_DISABLE_RECOVERY=.*|GRUB_DISABLE_RECOVERY=true|' "$GRUB_DEFAULT"
fi

# Hide Advanced options submenu
if ! grep -q "^GRUB_DISABLE_SUBMENU=" "$GRUB_DEFAULT"; then
    echo 'GRUB_DISABLE_SUBMENU=y' >> "$GRUB_DEFAULT"
else
    sed -i 's|^GRUB_DISABLE_SUBMENU=.*|GRUB_DISABLE_SUBMENU=y|' "$GRUB_DEFAULT"
fi

# Hide memtest entries
if ! grep -q "^GRUB_DISABLE_MEMTEST=" "$GRUB_DEFAULT"; then
    echo 'GRUB_DISABLE_MEMTEST=true' >> "$GRUB_DEFAULT"
else
    sed -i 's|^GRUB_DISABLE_MEMTEST=.*|GRUB_DISABLE_MEMTEST=true|' "$GRUB_DEFAULT"
fi

echo "[5/5] Running update-grub ..."
update-grub

echo ""
echo "Installation complete! Reboot to see the theme."
echo "To revert: sudo cp ${GRUB_DEFAULT}.bak.* $GRUB_DEFAULT && sudo update-grub"
