# Outputs and board coverage

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## Output formats are target-dependent

`mikey:hexoid` does not invent file formats. It copies the artefacts your installed
toolchain produced, using these extensions: `.bin`, `.hex`, `.uf2`, `.elf`, `.map`, `.eep`.

| Target family | Usually produced | Not produced | Flashing route |
| --- | --- | --- | --- |
| Arduino AVR, MiniCore, MightyCore, MegaCore, MicroCore | `.hex`, `.elf`, sometimes `.eep` | `.uf2`, `.bin` | avrdude / USBasp |
| ATTinyCore | `.hex`, `.elf` | `.uf2` | avrdude / USBasp with the matching chip |
| STM32duino (F1, F4, L4, F7) | `.bin`, `.hex`, `.elf`, `.map` | `.uf2` | ST-LINK V2 + ZFlasher STM32, or DFU mode |
| ESP8266 / ESP32 | `.bin`, `.elf` | `.hex`, `.uf2` for most variants | ESP flasher at the core's default offset |
| RP2040 | `.uf2`, `.elf` | `.hex` | Copy the `.uf2` to the bootloader drive |
| Teensy | `.hex`, `.elf` | `.uf2` | Teensy loader |
| Adafruit SAMD / Arduino SAMD | `.bin`, `.uf2`, `.elf` (varies by core) | — | UF2 bootloader or SWD |
| SDCC: 8051, CH552, STM8 | `.hex` (SDCC writes `.ihx`, saved with a `.hex` name) | `.elf`, `.map` from this flow | Vendor programmer / ST-LINK for STM8 |
| FPGA iCE40 (ID `999`) | `logic.json`, `logic.blif`, `netlist.v`, `circuit.png`, `.asc`, `.bin`, `.hex`, `waveform.vcd` | `.elf` | IceStorm tools / supported programmer |

Every file above is conditional on the toolchain succeeding. A missing `.map` or `.eep` is a
toolchain property, not an engine fault.

## Board coverage at a glance

| Group | IDs | Count | Notes |
| --- | --- | --- | --- |
| Arduino AVR + R4 | 1–14 | 14 | R4 boards need the Renesas core |
| SAMD | 15–20 | 6 | Known build failures, see limitations |
| ESP8266 | 21–27 | 7 | Boards with 512 KB flash need matching settings |
| ESP32 family | 28–39 | 12 | Some entries are aliases |
| STM32 | 40–51 | 12 | STM32duino core, SWD flashing |
| RP2040 | 52–59 | 8 | `.uf2` copy flashing |
| Teensy | 60–67 | 8 | PJRC core |
| ATtiny / bare AVR | 68–90 | 23 | ATTinyCore, MiniCore, MightyCore, MegaCore, MicroCore |
| DxCore megaAVR | 91–92 | 2 | Known build failures |
| Adafruit | 93–102 | 10 | SAMD and AVR variants |
| SDCC | 103–105 | 3 | CH552, 8051, STM8 |
| FPGA | 999 | 1 | iCE40 flow |

Total: **105 selectable entries** plus the FPGA option.

## How the engine selects a target

Each entry maps an ID to a Fully Qualified Board Name (FQBN), for example:

```text
40 → STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8
```

Extra options such as `,usb=HID` can be appended in `~/mikey-hexoid/mhex.py` to change the
build profile without touching the table itself. ESP32 builds automatically receive
`board_build.flash_mode=qio` and `board_build.partitions=default`.

## LED default injection

If a sketch contains no `LED_BUILTIN`, no `HAL_GPIO` and no `LL_GPIO` calls, the engine
prepends:

```c
#ifndef LED_BUILTIN
#define LED_BUILTIN <pin for your board>
#endif
```

Examples: `13` for Arduino Uno, `PC13` for BluePill, `25` for Pico, `2` for ESP32. The
original sketch is restored after the build, so your file is not permanently edited.
