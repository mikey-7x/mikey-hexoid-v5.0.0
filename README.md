# mikey:hexoid v5.0.0 (OMNIVERSE FINAL - CARRIER GRADE)

![Platform](https://img.shields.io/badge/Platform-Termux%20%7C%20Linux-blue)
![Version](https://img.shields.io/badge/Version-5.0.0-brightgreen)
![License](https://img.shields.io/badge/License-Non--Commercial%20Educational-red)

**mikey:hexoid v5.0.0** is a carrier-grade, universal cross-compilation engine designed for mobile (Termux/Android) and desktop Linux environments. It transforms your portable device into a fully fledged industrial workstation, capable of compiling C/C++ and Verilog code for over 100+ microcontrollers and FPGA boards directly from your terminal.

Engineered to run seamlessly on everything from standard Linux distributions to high-performance mobile hardware like Snapdragon 8 Gen 3 devices, this tool bridges the gap between PC-dependent compilation and on-the-go embedded systems engineering. 

![mikey:hexoid v5.0.0](mhex.png)

## 🚀 Why v5.0.0 is a Massive Leap Forward

Compared to the older `mikey:hexoid` script, v5.0.0 is faster, significantly more resilient, and architecturally superior. 

* **Industrial Self-Healing & Auto-Correction:** The AI-driven auto-repair engine actively monitors your build logs. If a compilation fails due to a missing library (e.g., `Adafruit_NeoPixel.h`, `DHT.h`) or a missing board core, the engine interrupts the failure, automatically searches the Arduino CLI index, installs the missing dependencies, and safely resumes the build.
* **True Universal Blink Generation:** Forget searching for pinout diagrams. The engine dynamically injects `#define LED_BUILTIN [pin]` for your specific board directly into the code. It even auto-generates SDCC-compatible C code for 8051/STM8 architectures.
* **Unmatched FPGA Integration:** Full support for the IceStorm toolchain. It synthesizes Verilog, routes the bitstream, generates visual circuit schematics (PNG), and outputs VCD waveforms for simulation—all from a single prompt.
* **Drastically Improved Speed:** Optimized background caching and intelligent dependency verification mean sub-second menu navigation and faster `.hex`/`.bin` generation times.

## ⚙️ Core Features

* **100+ Boards Supported:** From bare AVRs (ATmega32, ATmega8a, ATmega328p) and STM32s (perfect for building control systems or emulating retro hardware on a Blue Pill) to ESP32s, RP2040s, and 8051 architectures.
* **Multi-Format Outputs:** Generates `.hex`, `.bin`, `.uf2`, `.elf`, and `.eep` files ready for direct hardware flashing.
* **Built-in Library Manager:** Search, download, and install zip libraries directly from the CLI without touching a GUI.
* **Intelligent Workspace Management:** Auto-detects Android file systems to route outputs directly to your `/storage/emulated/0` directory for easy access via Android flashing apps.

## 📥 Installation

Run the following command in your Linux or Termux environment to deploy the script:

```bash
git clone https://github.com/mikey-7x/mikey-hexoid-v5.0.0.git
cd mikey-hexoid-v5.0.0
chmod +x mhex.sh
./mhex.sh
```

Once installed, simply type mhex in your terminal to launch the Omni-Engine.

🛠️ Usage & Hardware Flashing
This engine acts as the compiler. To upload the generated binaries to your physical hardware directly from your Android phone, follow these steps:
1. Bare AVR Chips (ATmega32, ATmega8a, ATmega328p, etc.)
 * Hardware Required: USBASP Programmer (via USB OTG).
 * Software Required: ZFlasher AVR
 * Process: Locate the compiled .hex file in your mikey-hexoid-outputs folder. Use ZFlasher AVR alongside your USBASP to flash the code directly to the chip via SPI communication.
2. STM32 / STM8 Boards (Blue Pill, Black Pill, etc.)
 * Hardware Required: ST-LINK/V2 in-circuit debugger/programmer (via USB OTG).
 * Software Required: ZFlasher STM32
 * Process: Locate the .bin or .hex file. Connect the ST-LINK/V2 to your board and use ZFlasher STM32 to upload the firmware.

⚠️ Known Issues & Call for Contributors
Currently, the compilation for the following board IDs encounters errors:
 * 79 (ATmega328PB)
 * 91, 92 (Curiosity AVR128DA48 / DB48)
 * 15 (Arduino Nano 33 IoT)
 * 16, 17, 18, 19, 20 (Arduino MKR & Zero SAMD families)
Help Wanted: If you are an experienced embedded developer and know how to resolve the CLI compilation pathways or toolchain linking errors for these specific SAMD/MegaAVR boards, please reach out.

***

## ©️ Copyright & Usage Rights

**Copyright © 2026 mikey-7x. All rights reserved.**

This software, **mikey:hexoid v5.0.0**, is distributed under a strict **Non-Commercial Educational License**. It is built by and for the maker community, students, and embedded systems enthusiasts.

**✓ Permitted Use:**
* Downloading, modifying, and running the engine for personal, educational, or hobbyist projects.
* Sharing the tool with other students or developers completely free of charge.

**✗ Strictly Prohibited:**
* Selling the script, engine, or any derived outputs.
* Bundling this software into a paid product or proprietary commercial ecosystem.
* Using this tool to generate financial profit without prior authorization.

Please refer to the `LICENSE` file in this repository for the complete legal text.

**Commercial Inquiries:** If you wish to utilize this project in a commercial setting, require a proprietary license, or wish to support the project financially, you must obtain explicit written permission. Please reach out directly to: **chauhanyogesh9512@gmail.com**



