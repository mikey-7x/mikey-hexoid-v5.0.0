# Architecture

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## Two layers

| Layer | File | Responsibility |
| --- | --- | --- |
| Installer (Bash) | `mhex.sh`, `mhex_e.sh` | Detect platform, install packages, fetch Arduino CLI, write configuration, install cores and libraries, generate the Python engine, then launch it |
| Engine (Python) | generated as `~/mikey-hexoid/mhex.py` | Menu loop, board table, project creation, compilation, library manager, FPGA and STM32 flows |

The engine is embedded inside the shell script as a heredoc, so the installed file is
regenerated on each run. Edit `~/mikey-hexoid/mhex.py` for temporary changes; edit the
script only if you are maintaining the project.

## Installer sequence

1. Environment detection (architecture, distribution, package manager).
2. Dependency installation through the native package manager.
3. FPGA tool check; OSS CAD Suite download when `yosys` is absent.
4. Arduino CLI 0.35.3 download into `~/mikey-hexoid/bin`.
5. Arduino CLI configuration written to `~/mikey-hexoid/config/arduino-cli.yaml`, including
   all third-party board indexes.
6. Core installation, with a direct Git clone fallback for ATTinyCore and DxCore.
7. One-time installation of common libraries.
8. Python engine generation and launch.

## Compile pipeline

```text
project folder
   ↓  LED_BUILTIN injection (temporary, restored afterwards)
arduino-cli compile --fqbn <target> --output-dir build/
   ↓  on failure: parse log → offer core/library install → retry once
build artefacts
   ↓  copy .bin .hex .uf2 .elf .map .eep
<outputs>/<Board Name>/<project>/
```

Special cases:

- **SDCC targets** (8051, CH552, STM8) generate or compile `main.c` with `sdcc` and save the
  `.ihx` as `<project>.hex`.
- **FPGA** (ID 999) runs Yosys, Graphviz, nextPNR, icepack and Icarus Verilog, copying each
  result into `FPGA_iCE40/<project>/`.
- **ESP32** builds receive flash-mode and partition build properties.

## Directories

| Path | Contents |
| --- | --- |
| `~/mikey-hexoid/bin` | Arduino CLI and the `mhex` launcher |
| `~/mikey-hexoid/config` | Arduino CLI YAML |
| `~/mikey-hexoid/projects` | Sketches and manual board additions (`hardware/`) |
| `~/mikey-hexoid/.arduino-data` | Cores, libraries, tools |
| `~/mikey-hexoid-outputs` or `/storage/emulated/0/mikey-hexoid-outputs` | Final artefacts |

## Design choices and consequences

- **Pinned CLI version** keeps behaviour reproducible; it also means older cores and modern
  ones may disagree.
- **Unsafe library installs** allow ZIP libraries outside the registry; that is convenient
  and also removes a safety net.
- **Log-driven repair** is intentionally conservative: it installs dependencies, then retries
  once, rather than looping and hiding the real error.
- **Terminal only.** There is no GUI, no background service and no telemetry.

## Extending

To add a board, add an entry to the `BOARDS` dictionary in the script (and regenerate
`~/mikey-hexoid/mhex.py`), keep the existing IDs, and test one build per new family.
