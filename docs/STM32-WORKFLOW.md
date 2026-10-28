# STM32 workflow

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

Menu **8** of `mhex_e.sh` is dedicated to STM32 boards. `mhex.sh` does not include it.

## Supported targets

| ID | Board | Core family |
| --- | --- | --- |
| 40 | BluePill F103C8 | STM32F1 |
| 41 | BluePill F103C6 | STM32F1 |
| 42 | BlackPill F401CC | STM32F4 |
| 43 | BlackPill F411CE | STM32F4 |
| 44–48 | Nucleo-64 / Nucleo-32 / Nucleo-144 | F4, F1, L4, F7 |
| 49–50 | Discovery F407VG / F303VC | F4, F3 |
| 51 | Generic F103C8Tx | STM32F1 |

## Three code styles

| Choice | What the generated file contains |
| --- | --- |
| LL (Low-Layer) | Direct register-level GPIO setup with `stm32f1xx_ll_*` / `stm32f4xx_ll_*` headers and `#if defined(STM32F1)` / `#if defined(STM32F4)` guards |
| HAL | `HAL_GPIO_Init` with `GPIO_InitTypeDef` and `__HAL_RCC_GPIOC_CLK_ENABLE()` |
| Arduino | Plain `pinMode` / `digitalWrite` blink |

The boilerplate toggles `PC13`, the on-board LED on BluePill and BlackPill. Nucleo and
Discovery boards use different pins — change them, or the code compiles but the LED stays
dark.

Both actions are available: **create new** (writes boilerplate, opens the editor) and
**compile existing** (routes to the standard compile pipeline).

## USB HID profile for BluePill (board 40)

The board table maps ID 40 to:

```text
STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8
```

That default has no USB device profile. To build HID/Keyboard experiments, append
`,usb=HID`:

1. Open the generated engine:

   ```bash
   nano ~/mikey-hexoid/mhex.py
   ```

2. Search (`Ctrl+W`) for `BLUEPILL_F103C8`.
3. Change the line to:

   ```python
   "40": ("BluePill F103C8", "STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8,usb=HID"),
   ```

4. Save with `Ctrl+O`, `Enter`, then exit with `Ctrl+X`.
5. Run the engine, choose **2. Compile Project**, and enter board ID `40`.

Notes:

- `,usb=HID` selects the USB device profile at build time. It is **not** a flashing
  transport — you still program the chip through ST-LINK/SWD.
- `~/mikey-hexoid/mhex.py` is regenerated each time `mhex.sh` or `mhex_e.sh` runs, so a
  reinstall removes the edit. Re-apply it when needed.
- Builds with and without HID produce different binaries; compare checksums if you need to
  match a previously published artefact.

## Clock and board caveats

STM32 boards ship with different crystals (8 MHz on BluePill, 25 MHz on some Nucleo parts)
and different flash sizes. If a build succeeds but the board misbehaves, check the core's
board menu options — clock source, USB support and optimisation level all matter.

## Flashing

See [FLASHING.md](FLASHING.md) for ST-LINK V2 and ZFlasher STM32 steps, including the
`0x08000000` start address used for raw `.bin` files.
