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
 * Process: Locate the .bin or .hex file. Connect the ST-LINK/V2 to your board and use ZFlasher STM32 to upload the firmware via SWD communication.

⚠️ Known Issues & Call for Contributors
Currently, the compilation for the following board IDs encounters errors:
 * 79 (ATmega328PB)
 * 91, 92 (Curiosity AVR128DA48 / DB48)
 * 15 (Arduino Nano 33 IoT)
 * 16, 17, 18, 19, 20 (Arduino MKR & Zero SAMD families)
Help Wanted: If you are an experienced embedded developer and know how to resolve the CLI compilation pathways or toolchain linking errors for these specific SAMD/MegaAVR boards, please reach out.

***
## 💫 improved mikey:hexoid v5.0.0
```bash
git clone https://github.com/mikey-7x/mikey-hexoid-v5.0.0.git
cd mikey-hexoid-v5.0.0
chmod +x mhex_e.sh
./mhex_e.sh
```

🚀 Release Notes: mikey:hexoid v5.0.0 (STM32 Carrier-Grade Update)

1. All-New STM32 Advanced Workflow (Option 8)
 * Dedicated Omni-Compiler Menu: Added a specialized interactive workflow exclusively for STM32 hardware (BluePill, BlackPill, Nucleo, Discovery).
 * Tri-Framework Support: Developers can now seamlessly switch between LL (Low-Layer), HAL (Hardware Abstraction Layer), and Standard Arduino coding styles.
 * Smart Boilerplate Generation: Automatically injects architecture-specific C++ boilerplate (clock initializations, RCC enabling, and correct pin mappings) based on the chosen framework and target board.

2. Modernized Bare-Metal LL Compatibility
 * Macro Unification Fix: Patched legacy macro conflicts (e.g., replacing the deprecated LL_GPIO_MODE_OUT_PP with the modern LL_GPIO_MODE_OUTPUT).
 * Cross-Series Support: Code generation now dynamically includes the correct #if defined(STM32F1) and #if defined(STM32F4) pre-processor directives, ensuring perfect compilation across both F1 (BluePill) and F4 (BlackPill/Discovery) architectures.

3. Bulletproof Dependency Manager (Cross-Distro)
 * Native Arch Linux / Termux Fixes: Refactored the install_deps_smart function to eliminate "Target not found" and redundant installation errors.
 * Dynamic Package Resolution: The engine now intelligently maps exact package names based on the detected OS package manager (pacman, apt, xbps, or pkg). (e.g., automatically resolving libX11 to libx11 and applying --needed flags for Arch).

4. Unified Android File Routing
 * Zero-Friction Exports: STM32 .hex, .bin, .elf, and .map files are securely routed to the core /storage/emulated/0/mikey-hexoid-outputs/ directory, keeping Android shared-storage access clean and sequential without breaking internal temporary builds.

5. 100% Core Preservation
 * All existing Omniverse features remain completely intact: AI Auto-Repair, FPGA IceStorm Toolchain (Yosys/NextPnR), SDCC for 8051/STM8, and the 100+ standard Arduino core targets.

## enable the USB HID Profile for the Blue Pill in the compilation flags.

Here is exactly how to patch your mhex engine to support BadUSB/HID compilation:

1. Edit your Python Engine

Open your terminal and use nano to edit the main engine script:
```
nano ~/mikey-hexoid/mhex.py
```
2. Add the HID Build Flag

Press Ctrl + W to open the search function, type BLUEPILL_F103C8, and press Enter. It will jump to this exact line:

"40": ("BluePill F103C8", "STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8"),

Modify the line to add ,usb=HID at the end of the board string. Make it look exactly like this:

"40": ("BluePill F103C8", "STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8,usb=HID"),

3. Save and Compile

Press Ctrl + O, hit Enter to save, and press Ctrl + X to exit nano.

Now, launch mhex, Compile Project and enter Target Board ID 40.

Because you injected ,usb=HID into the FQBN (Fully Qualified Board Name), the STM32 toolchain will now successfully link the native USB hardware to the <Keyboard.h> library, compile without errors, and output your .bin file to your phone's storage. Flash it via ZFlasher and plug it into the PC!

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



