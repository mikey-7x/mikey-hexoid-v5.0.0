# Usage reference

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## Menu map

| Option | Menu | Behaviour |
| --- | --- | --- |
| `1` | Create New Project (Smart) | Asks for a name and board ID, writes starter code and opens it in `$EDITOR` |
| `2` | Compile Project (Universal) | Lists projects, asks for a board ID, compiles, copies artefacts |
| `3` | Library Manager | Searches the Arduino library index, or installs a ZIP from the Downloads folder |
| `4` | Edit Project Code | Opens the first source file of a chosen project in `$EDITOR` |
| `5` | Generate Test Blinks | Creates fast and slow blink projects |
| `6` | Pin Definitions (Quick) | Prints the usual LED pin for common boards |
| `7` | Detailed Manual (Long) | In-engine manual: FPGA flow, STM32 flow, special notes |
| `8` | STM32 Advanced | LL / HAL / Arduino boilerplate and compilation (enhanced engine only) |
| `0` | Exit | Leaves the engine |

## Board IDs

Enter the number printed beside the target name. The table has 105 entries covering:

- Arduino AVR boards (IDs 1–12) and UNO R4 (13–14)
- SAMD boards (15–20) — see limitations before relying on these
- ESP8266 (21–27), ESP32 family (28–39)
- STM32: BluePill, BlackPill, Nucleo, Discovery, generic F103 (40–51)
- RP2040 (52–59)
- Teensy (60–67)
- ATtiny and bare AVR families (68–90)
- Curiosity / DxCore megaAVR (91–92) — see limitations
- Adafruit SAMD and AVR (93–102)
- SDCC targets: CH552, generic 8051, generic STM8 (103–105)
- `999` — FPGA iCE40 flow (prompted during compilation)

A few entries are aliases: `34`, `37` and `38` reuse the generic ESP32-C3/S3 definitions, so
a board-specific variant may need a corrected FQBN in `~/mikey-hexoid/mhex.py`.

## Project naming rules

Arduino CLI expects a sketch folder to share the name of the `.ino` file inside it. The smart
create step already does this; if you copy a project in by hand, keep the names identical.

## Editing

`$EDITOR` selects the editor. Behaviour differs by editor:

| Editor | Save | Exit |
| --- | --- | --- |
| `nano` (default) | `Ctrl+O`, then `Enter` | `Ctrl+X` |
| `vim` | `:w` | `:q` |

```bash
export EDITOR=nano     # or vim, micro, ...
./mhex_e.sh
```

## Libraries

- Search by name in **Library Manager**; the engine installs with `enable_unsafe_install`
  enabled so non-registry ZIPs also work.
- ZIP installs read from `Download`/`Downloads` on Android or Linux.
- Installed libraries live in `~/mikey-hexoid/.arduino-data/user/libraries`.

## Automatic dependency repair

If a build fails, the engine reads the compiler output:

1. `fatal error: X.h: No such file` → offers to install the library (a few common names are
   mapped to their registry names).
2. `Platform 'vendor:arch' not found` → offers to install the missing core.

If you accept, it installs and retries once. This fixes missing dependencies only; it cannot
repair broken source code, wrong pin use or toolchain mismatches.

## Output routing

Files are copied to:

```text
<outputs>/<Board Name>/<project>/
```

Only the extensions the toolchain emitted are copied: `.bin`, `.hex`, `.uf2`, `.elf`, `.map`,
`.eep`. FPGA results go to `<outputs>/FPGA_iCE40/<project>/`, SDCC results to
`<outputs>/<Board Name>/<project>/<project>.hex`.

## Uninstalling

```bash
rm -rf ~/mikey-hexoid ~/mikey-hexoid-outputs
```

Remove `~/oss-cad-suite` too if the FPGA tools were installed by the script, and keep the
cloned repository only if you want to reinstall.
