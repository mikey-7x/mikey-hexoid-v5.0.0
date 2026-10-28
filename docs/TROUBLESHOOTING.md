# Troubleshooting

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## The installer stops early

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Unknown Package Manager` | Unsupported distribution | Install `bash python3 git curl wget unzip tar clang sdcc graphviz iverilog` manually, then re-run |
| `sudo: command not found` | Minimal container or Termux | Run as a user with `sudo`, or install the packages first |
| `CLI Install Failed` | Index or network problem | Re-run the engine; check `arduino-cli core list --config-file ~/mikey-hexoid/config/arduino-cli.yaml` |
| Download hangs | Large toolchain on mobile data | Connect to Wi-Fi, or pre-install `yosys` to skip the suite download |

## The menu opens but compiles fail

1. Run `~/mikey-hexoid/bin/arduino-cli core list --config-file ~/mikey-hexoid/config/arduino-cli.yaml`
   and confirm the target platform is listed.
2. Confirm the project folder name equals the `.ino` file name.
3. Try **2. Compile Project** with a simple blink project (menu `5`) to separate code
   problems from toolchain problems.
4. Check known failing board IDs in [KNOWN-LIMITATIONS.md](KNOWN-LIMITATIONS.md).

## `No output files found`

The compile succeeded but nothing matched the copied extensions. Check the project's `build`
folder for what the toolchain actually produced, then confirm the target family's expected
formats in [OUTPUTS-AND-BOARDS.md](OUTPUTS-AND-BOARDS.md).

## Missing libraries keep coming back

Search the library in **Library Manager** and install it there; ZIP installs must come from
`Download` or `Downloads`. Some libraries need a specific version — install it explicitly
with Arduino CLI in a terminal if the menu resolves the wrong one.

## Android storage problems

- Grant Termux storage access: `termux-setup-storage`.
- Confirm `/storage/emulated/0/mikey-hexoid-outputs` exists and is writable.
- If files do not appear in ZFlasher, rescan the folder or move the file with a file manager.

## ESP32 build errors about partitions

The engine passes `board_build.flash_mode=qio` and `board_build.partitions=default`. Large
projects need a different partition scheme; edit the FQBN or compile that board outside the
engine.

## The editor does not open

Install an editor (`nano`, `vim`, `micro`) or set one explicitly:

```bash
export EDITOR=nano
```

## FPGA steps fail

| Failure | Check |
| --- | --- |
| `'yosys' missing` | OSS CAD Suite download finished; `~/oss-cad-suite/bin` in `PATH` |
| nextPNR not found | The suite is present but not on `PATH` for this shell |
| No `circuit.png` | Graphviz `dot` is missing |
| No `.bin` | `icepack` failed — read the packing log |

## Still stuck

Open an issue with the details listed in [CONTRIBUTING.md](../CONTRIBUTING.md): platform,
engine, menu option, board ID, core list and the first error line.
