# Quick start

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## 1. Check your platform

| Environment | What to expect |
| --- | --- |
| Android + Termux | Outputs go to `/storage/emulated/0/mikey-hexoid-outputs` so flashing apps can find them |
| Debian / Ubuntu / Linux Mint | `apt` path, needs `sudo` for distribution packages |
| Arch / Manjaro / EndeavourOS | `pacman` path with `--needed` |
| Void Linux | `xbps` path |
| Other Linux | Packages must be present already; the script reports what is missing |

You need internet access on the first run and roughly 3–6 GB of free space if you install
several board families at once.

## 2. Clone and start

```bash
git clone https://github.com/mikey-7x/mikey-hexoid-v5.0.0.git
cd mikey-hexoid-v5.0.0
chmod +x mhex_e.sh
./mhex_e.sh
```

Use `mhex.sh` instead if you only want the classic menus (1–7). `mhex_e.sh` adds the STM32
workflow as menu 8.

The first run prints a numbered progress sequence, installs what is missing, then opens the
menu. It is safe to re-run later: existing cores and tools are detected and skipped.

## 3. Create your first project

1. Choose **1. Create New Project (Smart)**.
2. Give the project a name — no spaces are needed, they are replaced with underscores.
3. Pick your board ID from the printed table (for example `1` Arduino Uno, `40` BluePill
   F103C8, `28` ESP32 Dev Module).
4. The starter sketch opens in `$EDITOR` (default `nano`). Write your code, then save with
   `Ctrl+O`, `Enter`, and leave with `Ctrl+X`.

## 4. Compile it

1. Choose **2. Compile Project (Universal)**.
2. Select the project number.
3. Enter the same board ID.

On success you see a line such as:

```text
Success! Outputs (4 files) saved to: ~/mikey-hexoid-outputs/BluePill_F103C8/blink
```

## 5. Flash it

- **STM32:** ZFlasher STM32 + ST-LINK V2 over USB-OTG — see [FLASHING.md](FLASHING.md).
- **AVR:** ZFlasher AVR + USBasp — see [FLASHING.md](FLASHING.md).
- **RP2040:** copy the `.uf2` file to the board's bootloader drive.
- **ESP32 / ESP8266:** use the `.bin` with your usual flasher at the core's default offset.

## Where things live

| Path | Purpose |
| --- | --- |
| `~/mikey-hexoid/projects/` | Your sketches, one folder per sketch |
| `~/mikey-hexoid/bin/arduino-cli` | Pinned Arduino CLI 0.35.3 |
| `~/mikey-hexoid/config/arduino-cli.yaml` | Board indexes and directory settings |
| `~/mikey-hexoid/.arduino-data/` | Installed cores and libraries |
| `~/mikey-hexoid/mhex.py` | Generated Python engine (menus are defined here) |
| `/storage/emulated/0/mikey-hexoid-outputs` | Android output folder |
| `~/mikey-hexoid-outputs` | Linux output folder |

## Updating

```bash
cd mikey-hexoid-v5.0.0
git pull
./mhex_e.sh          # re-run to refresh cores; it also regenerates ~/mikey-hexoid/mhex.py
```

If you patched `~/mikey-hexoid/mhex.py` (for example for USB HID), re-apply the patch after
a re-run — see [STM32-WORKFLOW.md](STM32-WORKFLOW.md).
