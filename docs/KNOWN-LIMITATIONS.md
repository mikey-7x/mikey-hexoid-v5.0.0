# Known limitations

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

Stated plainly so nobody loses a day to them.

## Boards that do not build with the current cores

| ID | Board | Status |
| --- | --- | --- |
| 79 | ATmega328PB | Compilation errors |
| 91 | AVR128DA48 (Curiosity) | Compilation errors |
| 92 | AVR128DB48 (Curiosity) | Compilation errors |
| 15 | Arduino Nano 33 IoT | Compilation errors |
| 16–20 | Arduino MKR and Zero SAMD families | Compilation errors |

## Aliases and duplicates

- Entries `34`, `37` and `38` reuse the generic ESP32-C3 and ESP32-S3 FQBNs, so a specific
  board variant may need its own `pnum=` option.
- The board table is a Python dictionary; a repeated numeric key would silently keep the last
  value. IDs are stable — do not renumber them.

## BluePill USB profile

Board ID `40` builds without USB support until `,usb=HID` (or another USB profile) is
appended in `~/mikey-hexoid/mhex.py`. The engine regenerates that file on every run.

## Output formats

The engine copies what the toolchain produced. It never converts between formats, and no
toolchain emits every format for every board. See
[OUTPUTS-AND-BOARDS.md](OUTPUTS-AND-BOARDS.md).

## FPGA flow

Generic iCE40 only, one fixed `top` module, no automatic pin constraints, and a fixed
testbench template.

## Installation

- Distribution packages are installed with `sudo`; the script needs that privilege.
- Downloaded archives are not checksum-verified by the script, and the generated Arduino CLI
  configuration sets `network.insecure: true` for older mirror TLS chains.
- First run is heavy: several hundred megabytes to a few gigabytes depending on cores.

## Verification claims

A successful compile and a successful flash do not prove electrical correctness, timing
margin or measurement accuracy. No build here is certified for safety-critical, medical,
automotive or industrial use.

## Licence

The project is **not** open source. Personal and educational use only; commercial and
industrial use need a separate signed written licence. See [LICENSE](../LICENSE).
