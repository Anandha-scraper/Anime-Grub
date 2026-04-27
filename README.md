# ZYNC OS SELECT

### Cyberpunk GRUB2 Boot Theme — Ubuntu + Windows Dual Boot

A dark neon-noir boot menu for Ubuntu + Windows dual-boot systems. The screen opens on a deep purple-black background with an anime art panel fading into darkness on the left, golden-yellow title text, hot-pink magenta accents, and a bottom countdown bar — all rendered at native 1920×1080 by the standard Ubuntu GRUB2 package. No bootloader replacement, no rEFInd, no EFI tinkering required.

---

## Prerequisites

Install these once before anything else:

```bash
sudo apt install imagemagick grub2-common fonts-ubuntu \
    qemu-system-x86 ovmf mtools xorriso os-prober
```

For the safe QEMU preview tool:

```bash
sudo apt install pipx
pipx install grub2-theme-preview
pipx ensurepath
source ~/.bashrc
```

---

## Quick Start

Run these four steps in order from the project directory:

**Step 1 — Generate image assets**
```bash
./generate_assets.sh
```
Creates `background.png`, `select_c.png`, and `icons/` from the source images. Only needed once, or after changing `anime.png` or `icon.png`.

**Step 2 — Compile fonts**
```bash
./compile_fonts.sh
```
Converts Ubuntu TTF into GRUB `.pf2` bitmap fonts at 13, 16, 20, and 24 px. Only needed once.

**Step 3 — Preview (no changes to your system)**
```bash
./preview.sh
```
A QEMU window opens showing the real GRUB menu with your theme applied. Close it when done. Safe to run as many times as you like — nothing is written to your disk or bootloader.

**Step 4 — Install**
```bash
sudo ./install.sh
```
Copies the theme to `/boot/grub/themes/custom`, configures `/etc/default/grub`, enables Windows detection, and runs `update-grub`.

Reboot. The themed menu will appear with both Ubuntu and Windows entries.

---

## Windows + Ubuntu Dual Boot

On **Ubuntu 22.04 and later**, GRUB's `os-prober` is disabled by default. `os-prober` is the tool that scans your other drives for Windows (and other OSes) and adds them to the GRUB menu. Without it, only Ubuntu appears at boot even on a dual-boot machine.

`install.sh` handles this automatically:

- Installs `os-prober` if it is not already present.
- Sets `GRUB_DISABLE_OS_PROBER=false` in `/etc/default/grub`.
- Runs `update-grub`, which calls `os-prober` and adds the Windows entry.

During installation, look for a line like this in the output:

```
Found Windows Boot Manager on /dev/sda1@/EFI/Microsoft/Boot/bootmgfw.efi
```

> **If Windows is not detected:** Windows may be on a drive that wasn't mounted when `update-grub` ran. Run `sudo os-prober` manually to confirm it is visible, then `sudo update-grub` again.

---

## Preview Without Installing

The preview is the safe way to see exactly how the theme looks before applying it. It uses `grub2-theme-preview`, which spins up a temporary QEMU virtual machine internally — no VM setup needed, nothing is written to your disk or bootloader.

```bash
cd ~/Projects/GRUB
./generate_assets.sh   # once, or after changing source images
./compile_fonts.sh     # once
./preview.sh           # launch preview
```

**Iterate freely:** edit `theme.txt`, then re-run only `./preview.sh` to see changes instantly. No reboot, no changes to your bootloader.

> The preview shows dummy entries (Gentoo, Memtest86+) — that is normal. `grub2-theme-preview` uses a fake GRUB config for safety. On your real system it will show Ubuntu and Windows once installed.

**How it works under the hood:** `grub2-theme-preview` builds a temporary ISO with your theme baked in, boots it inside QEMU, and renders the actual GRUB menu — so what you see is pixel-perfect identical to what you'll get at real boot time.

---

## Customization

Edit `theme.txt`, then run `./preview.sh` to see the result instantly. No reboot needed.

| Property | Key in `theme.txt` | Current value |
|---|---|---|
| Background color | `desktop-color` | `"#050008"` |
| Title text | `text` in first `label` block | `"ZYNC_OS_SELECT"` |
| Subtitle text | `text` in second `label` block | `"[ PLAYER ONE // AWAITING INPUT ]"` |
| Menu item color | `item_color` | `"#663377"` |
| Selected item color | `selected_item_color` | `"#ffe600"` |
| Countdown text | `text` in `progress_bar` | `"JACKING_IN... %d seconds"` |
| Countdown bar color | `fg_color` in `progress_bar` | `"#ff0090"` |
| Resolution | `GRUB_GFXMODE` in `/etc/default/grub` | `1920x1080,auto` |

---

## File Overview

| File | Purpose |
|---|---|
| `theme.txt` | GRUB theme layout — colors, fonts, positions |
| `background.png` | 1920×1080 boot background (generated) |
| `select_c.png` | Selection highlight card with neon glow (generated) |
| `icons/ubuntu.png` | Ubuntu boot entry icon (generated) |
| `icons/windows.png` | Windows boot entry icon (generated) |
| `fonts/*.pf2` | Compiled GRUB bitmap fonts at 13/16/20/24 px (generated) |
| `anime.png` | Source artwork used by `generate_assets.sh` |
| `icon.png` | Source icon used for both OS entries |
| `grub.cfg` | Minimal config used only by `preview.sh` (not installed) |
| `generate_assets.sh` | Builds all PNGs from source images |
| `compile_fonts.sh` | Converts Ubuntu TTF → `.pf2` for GRUB |
| `preview.sh` | Launches QEMU-based live preview |
| `install.sh` | Installs theme, configures GRUB, enables os-prober |

---

## Reverting

`install.sh` backs up `/etc/default/grub` automatically before making any changes.

```bash
# List the backup (timestamp is embedded in the filename)
ls /etc/default/grub.bak.*

# Restore — replace YYYYMMDD_HHMMSS with what ls showed
sudo cp /etc/default/grub.bak.YYYYMMDD_HHMMSS /etc/default/grub
sudo update-grub
```

To also remove the theme files:

```bash
sudo rm -rf /boot/grub/themes/custom
```
