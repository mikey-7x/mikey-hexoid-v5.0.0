# Flashing the build

`POWERED BY [mikey:hexoid-sys]` · Created by mikey-7x — Yogesh R. Chauhan

## STM32 with ST-LINK V2 and ZFlasher STM32 (Android)

### Wiring

| ST-LINK V2 | BluePill / STM32 board |
| --- | --- |
| `SWDIO` | `SWDIO` (usually labelled `DIO`) |
| `SWCLK` | `SWCLK` (usually labelled `CLK`) |
| `GND` | `GND` — always connect this |
| `3.3V` | `3.3V` only if the board has no other supply |

Do not connect both an external supply and ST-LINK 3.3 V at the same time.

### Steps

1. Install **ZFlasher STM32** from the Play Store and connect the ST-LINK through a USB-OTG
   adapter.
2. Open the app and let it detect the ST-LINK and the target chip.
3. Choose the compiled `.bin` or `.hex` from
   `/storage/emulated/0/mikey-hexoid-outputs/<Board Name>/<project>/`.
4. For a raw `.bin`, set the start address to `0x08000000` unless your project says
   otherwise.
5. Tap **Go!** and wait for the confirmation message. Power-cycle the board afterwards.

ZFlasher supports ST-LINK V1/V2/V3 and STM32F1 devices. Its documented 32 KB file limit
applies to other families, not to STM32F1 parts, so a normal BluePill build fits.

### If detection fails

- Check GND first, then SWDIO/SWCLK; reversed data lines are the most common mistake.
- Power the board from its own 3.3 V supply and leave ST-LINK 3.3 V disconnected.
- Try a shorter OTG cable, and confirm the phone grants USB permission to the app.
- Some clones need the board held in reset briefly while connecting.

## AVR with USBasp and ZFlasher AVR

1. Wire the 10-pin or 6-pin ISP header: `MOSI`, `MISO`, `SCK`, `RESET`, `VCC`, `GND`.
2. Open **ZFlasher AVR**, select the USBasp programmer and the correct chip.
3. Choose the `.hex` file from the output folder.
4. Read the existing fuse values before changing anything; most Arduino boards use an
   external crystal and need matching fuse settings.
5. Flash, then power-cycle.

## RP2040

Hold `BOOTSEL`, connect USB, release. A drive appears; copy the `.uf2` file onto it. The board
reboots into the new firmware.

## ESP8266 / ESP32

Use the `.bin` with a flasher that matches your core version. Default addresses differ by
board; when in doubt, use the same core version as the build machine.

## Before you flash

- Confirm the file belongs to the board you are holding — wrong voltage or wrong target can
  brick a device.
- Keep the original firmware if it matters to you; read it out first when the chip allows it.
- Flash over a stable power source. Brown-outs during writing are the usual cause of a
  damaged bootloader.

## Limits

Flashing is outside what `mikey:hexoid` can verify. A successful compile does not prove the
file is correct for your wiring, and a successful flash does not prove the hardware works.
