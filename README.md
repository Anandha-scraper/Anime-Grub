# Custom GRUB2 Theme — Ubuntu + Windows Dual Boot

A minimal dark GRUB boot menu theme for Ubuntu/Windows dual boot systems.

---

## Prerequisites

Install these once:

```bash
sudo apt install imagemagick grub2-common fonts-ubuntu \
    qemu-system-x86 ovmf mtools xorriso

sudo apt install pipx
pipx install grub2-theme-preview
pipx ensurepath
source ~/.bashrc
```

---

## Preview — without touching your system

This is the safe way to see exactly how the theme looks **before applying it**.
It uses `grub2-theme-preview`, which spins up a temporary QEMU virtual machine
internally — no VM setup needed, nothing is written to your disk or bootloader.

Run these three commands in order from the project directory:

```bash
cd ~/Projects/GRUB

# 1. Generate background and icons (only needed once, or after changing assets)
./generate_assets.sh

# 2. Compile fonts (only needed once)
./compile_fonts.sh

# 3. Launch preview — a QEMU window opens with your GRUB theme
./preview.sh
```

A window will open showing the real GRUB menu rendered with your theme.
Close it when done.

**Iterate freely:** edit `theme.txt`, then re-run only `./preview.sh` to see
the result instantly. No reboot, no changes to your bootloader.

> The preview shows dummy entries (Gentoo, Memtest86+) — that is normal.
> `grub2-theme-preview` uses a fake GRUB config for safety. On your real system
> it will show Ubuntu and Windows once installed.

**How it works under the hood:**
`grub2-theme-preview` builds a temporary ISO with your theme baked in,
boots it inside QEMU, and renders the actual GRUB menu — so what you see
is pixel-perfect identical to what you'll get at real boot time.

---

## Install to your system

Once happy with the look:

```bash
sudo ./install.sh
```

Then reboot. The theme will appear at boot.

To revert, restore the backup that `install.sh` created automatically:

```bash
sudo cp /etc/default/grub.bak.* /etc/default/grub
sudo update-grub
```

---

## File Overview

| File | Purpose |
|---|---|
| `theme.txt` | Main GRUB theme config (colors, layout, fonts) |
| `background.png` | Boot screen background (generated) |
| `icons/ubuntu.png` | Ubuntu menu icon (generated) |
| `icons/windows.png` | Windows menu icon (generated) |
| `fonts/*.pf2` | Compiled bitmap fonts for GRUB (generated) |
| `generate_assets.sh` | Creates all PNG assets via ImageMagick |
| `compile_fonts.sh` | Compiles Ubuntu TTF → GRUB `.pf2` format |
| `preview.sh` | Launches QEMU preview |
| `install.sh` | Installs theme and runs `update-grub` |

---

## Customization

Edit `theme.txt` to change colors, font sizes, or layout, then re-run `./preview.sh` to see the result instantly — no reboot needed.

Key values to tweak:

| Property | Location in theme.txt | Example |
|---|---|---|
| Background color | `desktop-color` | `"#0d0d1a"` |
| Menu item color | `item_color` | `"#a0a0cc"` |
| Selected item color | `selected_item_color` | `"#ffffff"` |
| Title text | `text` in label block | `"Select Your OS"` |
| Progress bar color | `fg_color` in progress_bar | `"#5050cc"` |
