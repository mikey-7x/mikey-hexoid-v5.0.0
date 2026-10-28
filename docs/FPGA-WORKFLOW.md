# FPGA workflow (iCE40)

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

Board ID **999** runs the open-source iCE40 flow. Choose it when the compile step asks for a
board ID.

## Toolchain

| Tool | Role |
| --- | --- |
| Yosys | Synthesis of the Verilog design |
| Graphviz (`dot`) | Renders the synthesised schematic to `circuit.png` |
| nextPNR (`nextpnr-ice40`) | Place and route |
| IceStorm (`icepack`) | Packs the routed design into a bitstream |
| Icarus Verilog (`iverilog`) | Simulation waveform |

The installer downloads the YosysHQ OSS CAD Suite when `yosys` is not available and adds it
to `PATH` (`~/oss-cad-suite/bin`).

## Inputs

Put a project folder under `~/mikey-hexoid/projects/` containing `top.v`. If the file is
missing, a small LED-counter example is generated for you. A testbench (`tb.v`) is written
automatically and uses `top` as the unit under test.

Keep the module name `top` — the flow reads that name in the generated wrapper files.

## Outputs

Written to `<outputs>/FPGA_iCE40/<project>/`:

| File | Meaning |
| --- | --- |
| `logic.json` | Yosys JSON netlist |
| `logic.blif` | BLIF netlist |
| `netlist.v` | Synthesised Verilog netlist |
| `circuit.png` | Schematic image, when `dot` is present |
| `*.asc` | Placed and routed design |
| `*.bin` | Packed bitstream |
| `*.hex` | Hex dump of the bitstream |
| `waveform.vcd` | Simulation waveform, viewable in GTKWave |

Any file can be absent if the corresponding stage failed — read the log printed by each
stage.

## Limits

- Generic iCE40 flow; no vendor-specific primitives, timing constraints or pin constraints
  are generated automatically.
- One top-level module and one fixed testbench template.
- A bitstream alone is not a working board: you still need the correct pin constraints for
  your PCB before the LEDs respond.
