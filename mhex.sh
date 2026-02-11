#!/usr/bin/env bash

# =============================================================================
#
#   mikey:hexoid v5.0.0 (OMNIVERSE FINAL - CARRIER GRADE) - UNIVERSAL LINUX
#
#   Architect: mikey-7x | Platform: Universal Linux (Void/Debian/Arch/Termux)
#
#   Features: 100+ Boards | AI Auto-Repair | Full FPGA Suite (Schematic/VCD)
#             Industrial Self-Healing | Extensive Manual | Multi-Format Output
#
# =============================================================================

set +e
set -o pipefail

# --- Visuals ---
C_OFF='\033[0m'
C_CYAN='\033[1;36m'
C_GRN='\033[1;32m'
C_YEL='\033[1;33m'
C_RED='\033[1;31m'
C_MAG='\033[1;35m'
C_BLU='\033[1;34m'

# --- 0. Universal Environment Check ---

clear
echo -e "${C_CYAN}"
echo "╔═════════════════════════════════════════════════════════════════╗"
echo "║      mikey:hexoid v5.0.0 (Universal Linux Edition)              ║"
echo "║      100+ Boards Support | Smart Create | Universal Blink       ║"
echo "║      >> AI Auto-Repair & Industrial Self-Healing Enabled <<     ║"
echo "╚═════════════════════════════════════════════════════════════════╝"
echo -e "${C_OFF}"

# Detect Architecture
ARCH=$(uname -m)
CLI_ARCH="64bit"
if [[ "$ARCH" == "aarch64" ]]; then CLI_ARCH="ARM64"; elif [[ "$ARCH" == "armv7l" ]]; then CLI_ARCH="ARM"; fi

# Detect Distro & Package Manager
DISTRO_ID="unknown"
PKG_MGR="unknown"

if [ -f /etc/os-release ]; then 
    . /etc/os-release
    DISTRO_ID=$ID
fi

if command -v xbps-install >/dev/null; then PKG_MGR="xbps"
elif command -v apt >/dev/null; then PKG_MGR="apt"
elif command -v pacman >/dev/null; then PKG_MGR="pacman"
elif command -v pkg >/dev/null; then PKG_MGR="pkg" # Termux
fi

echo -e "${C_GRN}[+] Detected OS: $DISTRO_ID ($PKG_MGR) | Arch: $ARCH ($CLI_ARCH)${C_OFF}"

# --- Paths ---
BASE="$HOME/mikey-hexoid"
BIN="$BASE/bin"
CFG="$BASE/config"
SKETCH="$BASE/projects"
ARD_CFG="$CFG/arduino-cli.yaml"
DATA_DIR="$BASE/.arduino-data"

# FPGA Tools Path (OSS CAD Suite)
export PATH="$HOME/oss-cad-suite/bin:$PATH"

# Output Logic (Android Priority)
if [ -d "/storage/emulated/0" ]; then
    OUTPUTS="/storage/emulated/0/mikey-hexoid-outputs"
    DOWNLOADS="/storage/emulated/0/Download"
else
    OUTPUTS="$HOME/mikey-hexoid-outputs"
    DOWNLOADS="$HOME/Downloads"
fi
if [ ! -d "$DOWNLOADS" ]; then if [ -d "$HOME/Downloads" ]; then DOWNLOADS="$HOME/Downloads"; else DOWNLOADS="$HOME"; fi; fi

mkdir -p "$BIN" "$CFG" "$SKETCH" "$OUTPUTS" "$DATA_DIR"

# --- 1. Smart Dependency Verification (Universal) ---

echo -e "${C_GRN}[1/7] Verifying System Toolchains...${C_OFF}"

install_deps_smart() {
    # Essential Packages List (Added graphviz for PNG schematics)
    PKGS="python3 python3-pip git curl wget unzip tar base-devel clang sdcc graphviz fontconfig libX11 libXft iverilog"
    
    echo -e "${C_YEL}>>> Installing Dependencies using $PKG_MGR...${C_OFF}"
    
    case $PKG_MGR in
        xbps)
            sudo xbps-install -S
            sudo xbps-install -y python3 python3-pip git curl wget unzip tar base-devel clang sdcc graphviz fontconfig libX11 libXft iverilog 2>/dev/null
            ;;
        apt)
            sudo apt update
            sudo apt install -y $PKGS
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm $PKGS
            ;;
        pkg)
            pkg update -y
            pkg install -y python3 python-pip git curl wget unzip tar clang sdcc graphviz iverilog
            ;;
        *)
            echo -e "${C_RED}Unknown Package Manager. Please install dependencies manually.${C_OFF}"
            ;;
    esac
}

install_deps_smart

# --- 2. FPGA Toolchain Healer ---

check_fpga_tools() {
    if ! command -v yosys >/dev/null; then
        echo -e "${C_YEL}>>> FPGA Tools Missing. Installing OSS CAD Suite...${C_OFF}"
        cd "$HOME"
        # Intelligent Arch Selection
        if [[ "$ARCH" == "aarch64" ]]; then
            URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-09-03/oss-cad-suite-linux-arm64-20240903.tgz"
        elif [[ "$ARCH" == "x86_64" ]]; then
            URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-09-03/oss-cad-suite-linux-x64-20240903.tgz"
        fi
        
        wget --no-check-certificate -q --show-progress -O oss-cad-suite.tgz "$URL"
        
        if [ -s "oss-cad-suite.tgz" ]; then
            echo -e "${C_YEL}>>> Extracting...${C_OFF}"
            tar -xzf oss-cad-suite.tgz
            rm oss-cad-suite.tgz
            echo -e "${C_GRN} FPGA Tools Installed to ~/oss-cad-suite${C_OFF}"
        else
            echo -e "${C_RED} Download Failed. Check internet/permissions.${C_OFF}"
        fi
    else
        echo -e "${C_GRN} FPGA Tools Verified.${C_OFF}"
    fi
}

check_fpga_tools

# --- 3. Arduino CLI Engine ---

ARD_CLI="$BIN/arduino-cli"
if [ ! -x "$ARD_CLI" ]; then
    echo -e "${C_GRN}[2/7] Installing Arduino CLI ($CLI_ARCH)...${C_OFF}"
    wget -q --show-progress -O "$BASE/arduino-cli.tar.gz" "https://downloads.arduino.cc/arduino-cli/arduino-cli_0.35.3_Linux_${CLI_ARCH}.tar.gz"
    tar -xzf "$BASE/arduino-cli.tar.gz" -C "$BIN"
    rm -f "$BASE/arduino-cli.tar.gz"
    chmod +x "$ARD_CLI"
fi

# --- 4. Configuration & Mirrors ---

echo -e "${C_GRN}[3/7] Generating Configuration...${C_OFF}"
cat > "$ARD_CFG" <<EOF
board_manager:
  additional_urls:
    - https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json
    - https://raw.githubusercontent.com/SpenceKonde/ReleaseScripts/master/package_drazzy.com_index.json
    - https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json
    - https://mcudude.github.io/MightyCore/package_MCUdude_MightyCore_index.json
    - https://mcudude.github.io/MegaCore/package_MCUdude_MegaCore_index.json
    - https://mcudude.github.io/MicroCore/package_MCUdude_MicroCore_index.json
    - https://adafruit.github.io/arduino-board-index/package_adafruit_index.json
    - https://arduino.esp8266.com/stable/package_esp8266com_index.json
    - https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
    - https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
    - https://www.pjrc.com/teensy/package_teensy_index.json
library:
  enable_unsafe_install: true
network:
  connection_timeout: 600s
  insecure: true
directories:
  data: $DATA_DIR
  user: $SKETCH
EOF

echo -e "${C_YEL}>>> Updating Indexes (Required First)...${C_OFF}"
"$ARD_CLI" core update-index --config-file "$ARD_CFG" >/dev/null 2>&1

# --- 5. Package Installation ---

echo -e "${C_GRN}[4/7] Installing Board Platforms...${C_OFF}"

force_install() {
    local name=$1; local core=$2
    if ! "$ARD_CLI" core list --config-file "$ARD_CFG" | grep -q "$core"; then
        echo -e "${C_YEL}>>> Installing $name ($core)...${C_OFF}"
        "$ARD_CLI" core install "$core" --config-file "$ARD_CFG" >/dev/null 2>&1 || echo -e "${C_RED}CLI Install Failed. Checking for manual fix...${C_OFF}"
    else
        echo -e "${C_GRN} $name is ready.${C_OFF}"
    fi
}

install_manual() {
    local name=$1; local repo=$2; local vendor=$3; local arch=$4
    local dest_path="$SKETCH/hardware/$vendor/$arch"
    local temp_path="$HOME/.mhex_temp_$name"

    if [ -d "$SKETCH/hardware/$vendor/$arch" ]; then
         echo -e "${C_GRN} $name is ready (Manual Check).${C_OFF}"
         return
    fi

    echo -e "${C_YEL}>>> [GIT FIX] Installing $name manually (Correct Structure)...${C_OFF}"
    if [ -d "$temp_path" ]; then rm -rf "$temp_path"; fi
    git clone --depth 1 "$repo" "$temp_path" >/dev/null 2>&1
    mkdir -p "$SKETCH/hardware/$vendor"

    if [ "$name" == "ATTinyCore" ]; then
        mv "$temp_path/avr" "$SKETCH/hardware/$vendor/"
    elif [ "$name" == "DxCore" ]; then
        mv "$temp_path/megaavr" "$SKETCH/hardware/$vendor/"
    fi
    rm -rf "$temp_path"
}

# Standard
force_install "Arduino AVR" "arduino:avr"
if [[ "$ARCH" != "aarch64" ]]; then force_install "Arduino SAMD" "arduino:samd"; fi

# IoT
force_install "ESP8266" "esp8266:esp8266"
force_install "ESP32" "esp32:esp32"
force_install "RP2040" "rp2040:rp2040"
force_install "STM32" "STMicroelectronics:stm32"

# Bare Metal
force_install "MiniCore" "MiniCore:avr"
force_install "MightyCore" "MightyCore:avr"
force_install "MegaCore" "MegaCore:avr"
force_install "MicroCore" "MicroCore:avr"

# Manual Fixes
install_manual "ATTinyCore" "https://github.com/SpenceKonde/ATTinyCore.git" "ATTinyCore" "avr"
install_manual "DxCore" "https://github.com/SpenceKonde/DxCore.git" "DxCore" "megaavr"

# Specialty
force_install "Adafruit AVR" "adafruit:avr"
force_install "Adafruit SAMD" "adafruit:samd"
force_install "Teensy" "teensy:avr"

# --- 6. Essential Libraries ---

echo -e "${C_GRN}[5/7] Verifying Essential Libraries...${C_OFF}"
REQ_LIBS=("LiquidCrystal" "Servo" "Stepper" "SD" "Wire" "SPI" "Adafruit GFX Library" "Adafruit SSD1306" "PubSubClient" "ArduinoJson" "Keypad" "DHT sensor library" "Adafruit NeoPixel" "FastLED" "OneWire" "DallasTemperature" "WiFiNINA")

if [ ! -d "$BASE/.arduino-data/user/libraries/Servo" ]; then
    for lib in "${REQ_LIBS[@]}"; do
        echo -n " Installing $lib... "
        "$ARD_CLI" lib install "$lib" --config-file "$ARD_CFG" >/dev/null 2>&1 && echo "OK" || echo "Skip"
    done
fi

# --- 7. Python Engine ---

echo -e "${C_GRN}[6/7] Launching Omni-Engine v5.0.0...${C_OFF}"
cat > "$BASE/mhex.py" <<'EOF_PY'
import os, sys, shutil, subprocess, re, json, time, glob
from pathlib import Path

# --- GLOBAL CONFIGURATION ---
BASE = Path(os.path.expanduser("~/mikey-hexoid"))
PROJECTS = BASE / "projects"
ARD_CLI = BASE / "bin" / "arduino-cli"
ARD_CFG = BASE / "config" / "arduino-cli.yaml"

os.environ["PATH"] += os.pathsep + os.path.expanduser("~/oss-cad-suite/bin")

if os.path.exists("/storage/emulated/0"):
    OUTPUTS = Path("/storage/emulated/0/mikey-hexoid-outputs")
    DOWNLOADS = Path("/storage/emulated/0/Download")
else:
    OUTPUTS = Path(os.path.expanduser("~/mikey-hexoid-outputs"))
    DOWNLOADS = Path(os.path.expanduser("~/Downloads"))
    if not DOWNLOADS.exists(): DOWNLOADS = Path(os.path.expanduser("~"))

OUTPUTS.mkdir(parents=True, exist_ok=True)
EDITOR = os.environ.get("EDITOR", "nano")

# =============================================================================
# DATA DEFINITIONS (Verified FQBNs & LED Map)
# =============================================================================
LED_MAP = {
    "default": 13,
    "nodemcu": 2, "d1": 2, "generic": 2, "esp01": 1, "huzzah": 0,
    "esp32": 2, "esp32cam": 33, "wrover": 2, "saola": 18, "lolin": 22, 
    "c3": 8, "s3": 2, "box": 1,
    "bluepill": "PC13", "blackpill": "PC13", "nucleo": "PA5", "disco": "PD13",
    "attiny85": 1, "attiny45": 1, "attiny13": 3, "attiny84": 7, "attiny88": 0,
    "pico": 25, "rp2040": 25, "itsybitsy": 13,
    "teensy": 13,
    "gemma": 1, "trinket": 1, "feather": 13, "circuitplayground": 13,
    "ch552": 33,
}

# Updated FQBN Map - MAPPED TO UNIVERSAL GENERICS FOR STABILITY
BOARDS = {
    "1": ("Arduino Uno R3", "arduino:avr:uno"),
    "2": ("Arduino Nano (328P)", "arduino:avr:nano:cpu=atmega328"),
    "3": ("Arduino Nano (Old Bootloader)", "arduino:avr:nano:cpu=atmega328old"),
    "4": ("Arduino Mega 2560", "arduino:avr:mega:cpu=atmega2560"),
    "5": ("Arduino Leonardo", "arduino:avr:leonardo"),
    "6": ("Arduino Micro", "arduino:avr:micro"),
    "7": ("Arduino Pro Mini (5V/16MHz)", "arduino:avr:pro:cpu=16MHzatmega328"),
    "8": ("Arduino Pro Mini (3.3V/8MHz)", "arduino:avr:pro:cpu=8MHzatmega328"),
    "9": ("Arduino Ethernet", "arduino:avr:ethernet"),
    "10": ("Arduino Yun", "arduino:avr:yun"),
    "11": ("Arduino LilyPad (328P)", "arduino:avr:lilypad:cpu=atmega328"),
    "12": ("Arduino Esplora", "arduino:avr:esplora"),
    "13": ("Arduino UNO R4 Minima", "arduino:renesas_uno:minima"),
    "14": ("Arduino UNO R4 WiFi", "arduino:renesas_uno:unor4wifi"),
    "15": ("Arduino Nano 33 IoT", "arduino:samd:nano_33_iot"),
    "16": ("Arduino MKR1000 WiFi", "arduino:samd:mkr1000"),
    "17": ("Arduino MKR WiFi 1010", "arduino:samd:mkrwifi1010"),
    "18": ("Arduino MKR Zero", "arduino:samd:mkrzero"),
    "19": ("Arduino Zero (Native USB)", "arduino:samd:arduino_zero_native"),
    "20": ("Arduino Zero (Programming Port)", "arduino:samd:arduino_zero_edbg"),
    "21": ("NodeMCU 1.0 (ESP-12E)", "esp8266:esp8266:nodemcuv2"),
    "22": ("WeMos D1 Mini", "esp8266:esp8266:d1_mini"),
    "23": ("Generic ESP8266 Module", "esp8266:esp8266:generic"),
    "24": ("ESP-01 (Black/512k)", "esp8266:esp8266:esp01"),
    "25": ("ESP-01S (1MB)", "esp8266:esp8266:esp01_1m"),
    "26": ("Adafruit Feather Huzzah ESP8266", "esp8266:esp8266:huzzah"),
    "27": ("Olimex MOD-WIFI-ESP8266", "esp8266:esp8266:modwifi"),
    "28": ("ESP32 Dev Module", "esp32:esp32:esp32"),
    "29": ("ESP32-CAM (AI-Thinker)", "esp32:esp32:esp32cam"),
    "30": ("ESP32-WROVER Module", "esp32:esp32:esp32wrover"),
    "31": ("ESP32-S2 Saola-1", "esp32:esp32:esp32s2"),
    "32": ("ESP32-S2 Mini (Lolin)", "esp32:esp32:lolin_s2_mini"),
    "33": ("ESP32-C3 Dev Module", "esp32:esp32:esp32c3"),
    "34": ("ESP32-C3 SuperMini", "esp32:esp32:esp32c3"),
    "35": ("ESP32-S3 Dev Module", "esp32:esp32:esp32s3"),
    "36": ("ESP32-S3 Box", "esp32:esp32:esp32s3box"),
    "37": ("Seeed Xiao ESP32-C3", "esp32:esp32:esp32c3"), 
    "38": ("Seeed Xiao ESP32-S3", "esp32:esp32:esp32s3"), 
    "39": ("Adafruit Feather ESP32-S2", "esp32:esp32:adafruit_feather_esp32s2"),
    "40": ("BluePill F103C8", "STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C8"),
    "41": ("BluePill F103C6", "STMicroelectronics:stm32:GenF1:pnum=BLUEPILL_F103C6"),
    "42": ("BlackPill F401CC", "STMicroelectronics:stm32:GenF4:pnum=BLACKPILL_F401CC"),
    "43": ("BlackPill F411CE", "STMicroelectronics:stm32:GenF4:pnum=BLACKPILL_F411CE"),
    "44": ("Nucleo-64 F401RE", "STMicroelectronics:stm32:Nucleo_64:pnum=NUCLEO_F401RE"),
    "45": ("Nucleo-64 F446RE", "STMicroelectronics:stm32:Nucleo_64:pnum=NUCLEO_F446RE"),
    "46": ("Nucleo-64 F103RB", "STMicroelectronics:stm32:Nucleo_64:pnum=NUCLEO_F103RB"),
    "47": ("Nucleo-32 L432KC", "STMicroelectronics:stm32:Nucleo_32:pnum=NUCLEO_L432KC"),
    "48": ("Nucleo-144 F767ZI", "STMicroelectronics:stm32:Nucleo_144:pnum=NUCLEO_F767ZI"),
    "49": ("Discovery F407VG", "STMicroelectronics:stm32:Discovery:pnum=DISCO_F407VG"),
    "50": ("Discovery F303VC", "STMicroelectronics:stm32:Discovery:pnum=DISCO_F303VC"),
    "51": ("Generic F103C8Tx", "STMicroelectronics:stm32:GenF1:pnum=GENERIC_F103C8TX"),
    "52": ("Raspberry Pi Pico", "rp2040:rp2040:rpipico"),
    "53": ("Raspberry Pi Pico W", "rp2040:rp2040:rpipicow"),
    "54": ("Seeed Xiao RP2040", "rp2040:rp2040:seeed_xiao_rp2040"),
    "55": ("Adafruit Feather RP2040", "rp2040:rp2040:adafruit_feather"),
    "56": ("Adafruit ItsyBitsy RP2040", "rp2040:rp2040:adafruit_itsybitsy"),
    "57": ("Waveshare RP2040 Zero", "rp2040:rp2040:waveshare_rp2040_zero"),
    "58": ("SparkFun Pro Micro RP2040", "rp2040:rp2040:sparkfun_promicrorp2040"),
    "59": ("Generic RP2040", "rp2040:rp2040:generic"),
    "60": ("Teensy 4.1", "teensy:avr:teensy41"),
    "61": ("Teensy 4.0", "teensy:avr:teensy40"),
    "62": ("Teensy 3.6", "teensy:avr:teensy36"),
    "63": ("Teensy 3.5", "teensy:avr:teensy35"),
    "64": ("Teensy 3.2 / 3.1", "teensy:avr:teensy31"),
    "65": ("Teensy LC", "teensy:avr:teensyLC"),
    "66": ("Teensy ++ 2.0", "teensy:avr:teensy2pp"),
    "67": ("Teensy 2.0", "teensy:avr:teensy2"),
    "68": ("ATtiny85 (Digispark/Gemma)", "ATTinyCore:avr:attinyx5:chip=85"),
    "69": ("ATtiny45", "ATTinyCore:avr:attinyx5:chip=45"),
    "70": ("ATtiny25", "ATTinyCore:avr:attinyx5:chip=25"),
    "71": ("ATtiny84", "ATTinyCore:avr:attinyx4:chip=84"),
    "72": ("ATtiny44", "ATTinyCore:avr:attinyx4:chip=44"),
    "73": ("ATtiny24", "ATTinyCore:avr:attinyx4:chip=24"),
    "74": ("ATtiny167 (Digispark Pro)", "ATTinyCore:avr:attinyx7:chip=167"),
    "75": ("ATtiny88 (MH-ET)", "ATTinyCore:avr:attinyx8:chip=88"),
    "76": ("ATtiny1634", "ATTinyCore:avr:attiny1634:chip=1634"),
    "77": ("ATtiny2313", "ATTinyCore:avr:attinyx313:chip=2313"),
    "78": ("ATmega328P (Bare)", "MiniCore:avr:328"),
    "79": ("ATmega328PB", "MiniCore:avr:328pb"),
    "80": ("ATmega168", "MiniCore:avr:168"),
    "81": ("ATmega8", "MiniCore:avr:8"),
    "82": ("ATmega1284P", "MightyCore:avr:1284"),
    "83": ("ATmega644", "MightyCore:avr:644"),
    "84": ("ATmega32", "MightyCore:avr:32"),
    "85": ("ATmega16", "MightyCore:avr:16"),
    "86": ("ATmega2560 (Bare)", "MegaCore:avr:2560"),
    "87": ("ATmega1280", "MegaCore:avr:1280"),
    "88": ("ATmega128", "MegaCore:avr:128"),
    "89": ("ATmega64", "MegaCore:avr:64"),
    "90": ("ATtiny13", "MicroCore:avr:13"),
    "91": ("AVR128DA48 (Curiosity)", "DxCore:megaavr:avr128da48"),
    "92": ("AVR128DB48 (Curiosity)", "DxCore:megaavr:avr128db48"),
    "93": ("Adafruit Feather M0 Express", "adafruit:samd:adafruit_feather_m0_express"),
    "94": ("Adafruit Feather M4 Express", "adafruit:samd:adafruit_feather_m4"),
    "95": ("Adafruit ItsyBitsy M0", "adafruit:samd:adafruit_itsybitsy_m0"),
    "96": ("Adafruit ItsyBitsy M4", "adafruit:samd:adafruit_itsybitsy_m4"),
    "97": ("Circuit Playground Express", "adafruit:samd:adafruit_circuitplayground_m0"),
    "98": ("Adafruit Gemma M0", "adafruit:samd:adafruit_gemma_m0"),
    "99": ("Adafruit Flora (AVR)", "adafruit:avr:flora8"),
    "100": ("Adafruit Gemma (AVR)", "adafruit:avr:gemma"),
    "101": ("Adafruit Trinket 5V (AVR)", "adafruit:avr:trinket5"),
    "102": ("Adafruit Trinket 3V (AVR)", "adafruit:avr:trinket3"),
    "103": ("CH552 USB (8051)", "SDCC_CH552"),
    "104": ("Generic 8051 (SDCC)", "SDCC_8051"),
    "105": ("Generic STM8 (SDCC)", "SDCC_STM8"),
}

class UI:
    C, G, Y, R, M, B, OFF = "\033[36m", "\033[32m", "\033[33m", "\033[31m", "\033[35m", "\033[1m", "\033[0m"
    @staticmethod
    def header():
        print(f"\n{UI.C}╔" + "═"*60 + "╗")
        print(f"║{UI.B}   mikey:hexoid v5.0.0 (OMNIVERSE FINAL)                  {UI.OFF}{UI.C}║")
        print("╚" + "═"*60 + "╝" + UI.OFF)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def get_project_list():
    return [p for p in PROJECTS.iterdir() if p.is_dir() and p.name not in ["libraries", "hardware", "build"]]

def detect_led_pin(fqbn):
    val = LED_MAP["default"]
    for k, v in LED_MAP.items():
        if k in fqbn.lower(): val = v; break
    if isinstance(val, int): return str(val)
    return val

def verify_core_before_compile(fqbn):
    # Extracts platform key from FQBN (e.g., teensy:avr)
    parts = fqbn.split(":")
    if len(parts) < 2: return
    platform = f"{parts[0]}:{parts[1]}"
    
    # Check if installed
    res = subprocess.run([str(ARD_CLI), "core", "list", "--config-file", str(ARD_CFG)], capture_output=True, text=True)
    if platform not in res.stdout:
        print(f"{UI.Y}[Self-Healing] Missing core {platform}. Installing...{UI.OFF}")
        subprocess.call([str(ARD_CLI), "core", "install", platform, "--config-file", str(ARD_CFG)])

def try_auto_repair(error_log):
    print(f"\n{UI.M}>> AI AUTO-REPAIR ENGINE ACTIVATED <<{UI.OFF}")
    
    missing_libs = re.findall(r"fatal error: (.*?)\.h: No such file", error_log)
    if missing_libs:
        print(f"{UI.Y}[!] FAULT DETECTED: Missing Libraries: {', '.join(missing_libs)}{UI.OFF}")
        c = input(f"{UI.C}[?] Attempt to Auto-Install these libraries? (y/n): {UI.OFF}")
        if c.lower() == 'y':
            for lib in missing_libs:
                lib_map = {"DHT": "DHT sensor library", "Adafruit_NeoPixel": "Adafruit NeoPixel", "FastLED": "FastLED"}
                target = lib_map.get(lib, lib)
                print(f" -> Installing {target}...")
                subprocess.call([str(ARD_CLI), "lib", "install", target, "--config-file", str(ARD_CFG)])
            return True

    missing_core = re.search(r"Platform '(.*?)' not found", error_log)
    if missing_core:
        core = missing_core.group(1)
        print(f"{UI.Y}[!] FAULT DETECTED: Missing Board Core ({core}){UI.OFF}")
        c = input(f"{UI.C}[?] Auto-Install {core}? (y/n): {UI.OFF}")
        if c.lower() == 'y':
            print(f" -> Installing {core}...")
            subprocess.call([str(ARD_CLI), "core", "install", core, "--config-file", str(ARD_CFG)])
            return True
    return False

def compile_arduino(path, fqbn, name):
    print(f"{UI.Y}Compiling {name} ({fqbn})...{UI.OFF}")
    
    # 1. Pre-Check: Ensure core is actually installed to prevent "Invalid FQBN"
    verify_core_before_compile(fqbn)

    if (path/"main.c").exists(): (path/"main.c").unlink()
    
    ino_files = list(path.glob("*.ino"))
    if not ino_files:
        ino = path/f"{path.name}.ino"
        ino.write_text("void setup(){}\nvoid loop(){}")
    else:
        ino = ino_files[0]

    try: txt = ino.read_text()
    except: txt = ""
    injected = False
    
    if "LED_BUILTIN" not in txt:
        led_pin = detect_led_pin(fqbn)
        print(f"{UI.G}Injecting LED_BUILTIN = {led_pin} for {name}{UI.OFF}")
        newtxt = f"#ifndef LED_BUILTIN\n#define LED_BUILTIN {led_pin}\n#endif\n" + txt
        ino.write_text(newtxt); injected = True
    
    build = path/"build"; 
    if build.exists(): shutil.rmtree(build)
    build.mkdir(parents=True, exist_ok=True)
    
    cmd = [str(ARD_CLI), "compile", "--fqbn", fqbn, "--config-file", str(ARD_CFG), "--output-dir", str(build), str(path)]
    if "esp32" in fqbn: 
        cmd += ["--build-property", "board_build.flash_mode=qio", "--build-property", "board_build.partitions=default"]
    
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if injected: ino.write_text(txt)
    
    if proc.returncode != 0: 
        print(f"{UI.R}Failed:\n{proc.stderr}{UI.OFF}")
        if try_auto_repair(proc.stderr):
            print(f"{UI.G}Retrying Compilation...{UI.OFF}")
            compile_arduino(path, fqbn, name)
        return

    dest = OUTPUTS/name.replace(" ","_")/path.name; dest.mkdir(parents=True, exist_ok=True)
    copied_files = 0
    for f in build.iterdir():
        if f.suffix in ['.bin', '.hex', '.uf2', '.elf', '.map', '.eep']: 
            shutil.copy2(f, dest/f"{path.name}{f.suffix}")
            copied_files += 1
    if copied_files > 0: print(f"{UI.G}Success! Outputs ({copied_files} files) saved to: {dest}{UI.OFF}")
    else: print(f"{UI.R}Warning: No output files found.{UI.OFF}")

def compile_sdcc(path, name, arch):
    print(f"{UI.Y}Using Internal SDCC for {arch} ({name})...{UI.OFF}")
    src = path/"main.c"
    if not src.exists():
        print(f"{UI.G}[Smart] Converting blink code to SDCC-C...{UI.OFF}")
        if arch == "stm8": code = "void main() { unsigned char *p = (unsigned char *)0x5005; *p |= 0x20; while(1) { *p ^= 0x20; for(long i=0; i<30000; i++); } }"
        elif arch == "ch552": code = "#include <stdint.h>\n__sbit __at (0x90) P1_0;\nvoid delay(uint16_t x){while(x--);}\nvoid main(){while(1){P1_0=!P1_0;delay(20000);}}"
        else: code = "#include <8051.h>\nvoid delay(long x){long i; for(i=0;i<x;i++);}\nvoid main(){while(1){P1_0=!P1_0;delay(10000);}}"
        src.write_text(code)
    
    build = path/"build"; build.mkdir(exist_ok=True)
    out = build/f"{path.name}.ihx"
    
    # Map CH552 to mcs51 architecture for SDCC
    sdcc_arch = "mcs51" if arch == "ch552" else arch
    
    cmd = ["sdcc", f"-m{sdcc_arch}", str(src), "-o", str(out)]
    if subprocess.call(cmd) == 0:
        dest = OUTPUTS/name.replace(" ","_")/path.name; dest.mkdir(parents=True, exist_ok=True)
        shutil.copy2(out, dest/f"{path.name}.hex")
        print(f"{UI.G}Success! Saved HEX to: {dest}{UI.OFF}")
    else: print(f"{UI.R}SDCC Build Failed.{UI.OFF}")

def compile_fpga(path):
    print(f"{UI.Y}FPGA Workflow (IceStorm)...{UI.OFF}")
    
    if not shutil.which("yosys"): print(f"{UI.R}CRITICAL: 'yosys' missing.{UI.OFF}"); return
    
    build = path/"build"; build.mkdir(exist_ok=True)
    log_file = build/"build.log"
    v_file = path/"top.v"; tb = path/"tb.v"
    
    # Self-Healing: Create valid Testbench for VCD generation if missing or empty
    if not v_file.exists():
        v_file.write_text("module top(input clk, output led);\n  reg [25:0] c;\n  always @(posedge clk) c <= c + 1;\n  assign led = c[25];\nendmodule\n")
        
    # Write a PROPER testbench that dumps VCD
    tb.write_text("`timescale 1ns/1ps\nmodule tb;\n  reg clk;\n  wire led;\n  top uut (.clk(clk), .led(led));\n  initial begin\n    $dumpfile(\"waveform.vcd\");\n    $dumpvars(0, tb);\n    clk = 0;\n    #1000000 $finish;\n  end\n  always #5 clk = ~clk;\nendmodule\n")

    dest = OUTPUTS/"FPGA_iCE40"/path.name; dest.mkdir(parents=True, exist_ok=True)

    with open(log_file, "w") as log:
        # 1. Synthesis (JSON + BLIF + Schematic)
        print(f" {UI.C}[1/5] Synthesizing (Yosys)... {UI.OFF}", end="", flush=True)
        # Correctly separate show command and use explicit -format dot
        yosys_cmd = f"read_verilog {v_file}; synth_ice40 -json {build}/out.json -blif {build}/out.blif; write_verilog {build}/netlist.v; show -format dot -prefix {build}/circuit"
        rc = subprocess.call(["yosys", "-p", yosys_cmd], stdout=log, stderr=log)
        if rc != 0: 
            print(f"{UI.R}[FAIL]{UI.OFF}"); return
        print(f"{UI.G}[DONE]{UI.OFF}")
        
        # Copy Logic outputs
        if (build/"out.json").exists(): shutil.copy2(build/"out.json", dest/"logic.json")
        if (build/"out.blif").exists(): shutil.copy2(build/"out.blif", dest/"logic.blif")
        if (build/"netlist.v").exists(): shutil.copy2(build/"netlist.v", dest/"netlist.v")
        
        # FIX: Generate PNG from DOT correctly (Fixes dots & dashes)
        if shutil.which("dot") and (build/"circuit.dot").exists(): 
            subprocess.call(["dot", "-Tpng", str(build/"circuit.dot"), "-o", str(dest/"circuit.png")])
        
        # 2. Place & Route
        PNR = "nextpnr-ice40" if shutil.which("nextpnr-ice40") else "nextpnr"
        if shutil.which(PNR):
            print(f" {UI.C}[2/5] Place & Route... {UI.OFF}", end="", flush=True)
            rc = subprocess.call([PNR, "--hx1k", "--json", str(build/"out.json"), "--asc", str(build/"out.asc")], stdout=log, stderr=log)
            if rc == 0:
                print(f"{UI.G}[DONE]{UI.OFF}")
                if shutil.which("icepack"):
                    print(f" {UI.C}[3/5] Packing Bitstream... {UI.OFF}", end="", flush=True)
                    subprocess.call(["icepack", str(build/"out.asc"), str(build/"bit.bin")], stdout=log, stderr=log)
                    shutil.copy2(build/"bit.bin", dest/"bitstream.bin")
                    try:
                        with open(str(build/"bit.bin"),"rb") as b, open(dest/"bitstream.hex","w") as h: h.write(b.read().hex())
                    except: pass
                    print(f"{UI.G}[DONE]{UI.OFF}")
            else: print(f"{UI.R}[FAIL (Check Log)]{UI.OFF}")
        else: print(f"{UI.R}Skipping PNR (nextpnr missing).{UI.OFF}")

        # 4. Simulation (Waveforms)
        if shutil.which("iverilog") and tb.exists():
            print(f" {UI.C}[4/5] Generating Waveform... {UI.OFF}", end="", flush=True)
            # Compile Sim
            subprocess.call(["iverilog", "-o", str(build/"sim"), str(v_file), str(tb)], stdout=log, stderr=log)
            # Run Sim inside Dest folder so .vcd generates there
            subprocess.call(["vvp", str(build/"sim")], cwd=str(dest), stdout=log, stderr=log)
            print(f"{UI.G}[DONE]{UI.OFF}")

    print(f"\n{UI.Y}>> Full Verification Complete. All Files in {dest}{UI.OFF}")

def list_boards():
    print(f"\n{UI.B}=== AVAILABLE BOARDS (1-105) ==={UI.OFF}")
    keys = sorted(BOARDS.keys(), key=lambda x: int(x))
    mid = (len(keys) + 1) // 2
    for i in range(mid):
        k1 = keys[i]; n1 = BOARDS[k1][0][:32]; col1 = f"{k1.rjust(3)}. {n1}"
        col2 = ""
        if i + mid < len(keys):
            k2 = keys[i + mid]; n2 = BOARDS[k2][0][:32]; col2 = f"{k2.rjust(3)}. {n2}"
        print(f" {col1:<40} {col2}")
    print(f"{UI.Y}  999{UI.OFF}. FPGA (Verilog/IceStorm)")
    print("    0. Back")

def library_manager():
    while True:
        print(f"\n{UI.B}--- LIBRARY MANAGER ---{UI.OFF}")
        print("1. Search & Install (Online)")
        print("2. Install ZIP (Downloads)")
        print("0. Back")
        c = input(f"{UI.C}lib > {UI.OFF}")
        if c == "1":
            query = input("Search Query: "); 
            if not query: continue
            print(f"{UI.Y}Searching...{UI.OFF}")
            try:
                res = subprocess.run([str(ARD_CLI), "lib", "search", query, "--format", "json", "--config-file", str(ARD_CFG)], capture_output=True, text=True)
                data = json.loads(res.stdout); libs = data.get("libraries", [])
                if not libs: print("No results."); continue
                chunk=15; idx=0
                while idx < len(libs):
                    print(f"\n{UI.C}{'NAME':<35} | {'VER':<8} | {'DESC'}{UI.OFF}\n" + "-"*80)
                    for l in libs[idx:idx+chunk]:
                        ver = l.get("latest", {}).get("version", "?")
                        desc = l.get("latest", {}).get("sentence", "No Desc")[:35]
                        print(f"{l['name'][:34]:<35} | {ver:<8} | {desc}...")
                    print("-" * 80)
                    rem = len(libs) - (idx + chunk)
                    val = input(f"Install Name (Enter for more ({rem}), 0 Back): ").strip()
                    if val=="0": break
                    elif val=="": 
                        if rem <= 0: break
                        idx += chunk; continue
                    else:
                        subprocess.call([str(ARD_CLI), "lib", "install", val, "--config-file", str(ARD_CFG)]); break
            except Exception as e: print(f"Search Error: {e}")
        elif c == "2":
            zips = list(DOWNLOADS.glob("*.zip"))
            for i,z in enumerate(zips): print(f"{i+1}. {z.name}")
            try:
                sel=int(input("Select #: "))
                if sel>0: subprocess.call([str(ARD_CLI), "lib", "install", "--zip-path", str(zips[sel-1]), "--config-file", str(ARD_CFG)])
            except: pass
        elif c=="0": break

def create_ui():
    list_boards()
    bid = input(f"{UI.C}Target Board ID > {UI.OFF}").strip()
    if bid=="0": return
    n = input(f"{UI.C}Name: {UI.OFF}").replace(" ", "_")
    p = PROJECTS/n; p.mkdir(parents=True, exist_ok=True)
    f = p/f"{n}.ino"
    if bid=="999":
        f=p/"top.v"; f.write_text("module top(input clk, output led);\n // Verilog\nendmodule")
        (p/"tb.v").write_text("`timescale 1ns/1ps\nmodule tb(); endmodule")
    elif bid in BOARDS and "SDCC" in BOARDS[bid][1]:
        f=p/"main.c"; f.write_text("void main() { while(1); }")
    else:
        f.write_text("void setup(){pinMode(LED_BUILTIN, OUTPUT);}\nvoid loop(){digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN)); delay(500);}")
    subprocess.call([EDITOR, str(f)])

def gen_blinks():
    p1 = PROJECTS/"blink_fast"; p1.mkdir(parents=True, exist_ok=True)
    (p1/"blink_fast.ino").write_text("void setup(){pinMode(LED_BUILTIN,OUTPUT);}void loop(){digitalWrite(LED_BUILTIN,1);delay(100);digitalWrite(LED_BUILTIN,0);delay(100);}")
    p2 = PROJECTS/"blink_slow"; p2.mkdir(parents=True, exist_ok=True)
    (p2/"blink_slow.ino").write_text("void setup(){pinMode(LED_BUILTIN,OUTPUT);}void loop(){digitalWrite(LED_BUILTIN,1);delay(1000);digitalWrite(LED_BUILTIN,0);delay(1000);}")
    print(f"{UI.G}Generated blink_fast & blink_slow.{UI.OFF}")

def help_ui():
    print(f"\n{UI.B}══════════════════════════════════════════════════════════════════════{UI.OFF}")
    print(f"{UI.C}     PIN CONFIGURATION QUICK REFERENCE (v5.0.0)             {UI.OFF}")
    print(f"{UI.B}══════════════════════════════════════════════════════════════════════{UI.OFF}")
    print(" 1. Arduino AVR (Uno/Nano): Pin 13")
    print(" 2. ESP8266 (NodeMCU): GPIO 2 (D4) or GPIO 16 (D0)")
    print(" 3. ESP32 (Dev Module): GPIO 2")
    print(" 4. STM32 BluePill: PC13 (Active Low)")
    print(" 5. Raspberry Pi Pico: GP25")
    print(" 6. ATtiny85: Pin 1 (PB1)")
    print(" 7. Teensy 4.0: Pin 13")
    print(f"{UI.B}══════════════════════════════════════════════════════════════════════{UI.OFF}")
    input("\nPress Enter to return...")

def show_manual():
    manual_text = f"""
{UI.C}╔══════════════════════════════════════════════════════════════════════════╗
║                   MIKEY:HEXOID v5.0.0 - OPERATOR MANUAL                  ║
╚══════════════════════════════════════════════════════════════════════════╝{UI.OFF}

{UI.B}1. INTRODUCTION{UI.OFF}
   mikey:hexoid is a carrier-grade, universal cross-compilation engine designed for
   mobile (Termux/Android) and desktop Linux.

{UI.B}2. FPGA WORKFLOW (Board ID 999){UI.OFF}
   - The engine performs:
     a. Synthesis (Yosys) -> Generates .json, .blif (Netlist) & .v (Netlist)
     b. Visualization -> Generates circuit.png (Schematic Diagram)
     c. Place & Route (NextPnR) -> Generates .asc
     d. Packing (IcePack) -> Generates .bin (Bitstream) & .hex (Hex dump)
     e. Simulation (Icarus) -> Generates waveform.vcd (GTKWave)

{UI.B}3. SPECIAL NOTES{UI.OFF}
   - Teensy/ESP32: The engine now auto-installs missing cores before compilation.
   - CH55x/8051: Now uses internal SDCC engine for maximum compatibility.

{UI.Y}[ END OF MANUAL ]{UI.OFF}
"""
    print(manual_text)
    input(f"\n{UI.Y}[Press Enter to Return to Menu...]{UI.OFF}")

def main():
    while True:
        UI.header()
        print(" 1. Create New Project (Smart)")
        print(" 2. Compile Project (Universal)")
        print(" 3. Library Manager")
        print(" 4. Edit Project Code")
        print(" 5. Generate Test Blinks")
        print(" 6. Pin Definitions (Quick)")
        print(" 7. Detailed Manual (Long)")
        print(" 0. Exit")
        c = input(f"\n{UI.C}mhex > {UI.OFF}")
        if c=="1": create_ui()
        elif c=="2":
            projs = get_project_list()
            if not projs:
                print(f"{UI.R}No projects found. Use option 1 or 5 first.{UI.OFF}")
            else:
                for i,p in enumerate(projs): print(f" {i+1}. {p.name}")
                try:
                    sel=int(input(f"{UI.C}Number > {UI.OFF}")); path=projs[sel-1]
                    list_boards(); bid = input(f"{UI.C}Board ID > {UI.OFF}").strip()
                    if bid=="999": compile_fpga(path)
                    elif bid in BOARDS:
                        if "SDCC" in BOARDS[bid][1]: 
                            arch = "mcs51" if "8051" in BOARDS[bid][1] else "stm8"
                            if "CH552" in BOARDS[bid][0]: arch = "ch552"
                            compile_sdcc(path, BOARDS[bid][0], arch)
                        else: compile_arduino(path, BOARDS[bid][1], BOARDS[bid][0])
                except Exception as e: 
                    print(f"{UI.R}Selection Error: {e}{UI.OFF}")
        elif c=="3": library_manager()
        elif c=="4":
            projs = get_project_list()
            for i,p in enumerate(projs): print(f" {i+1}. {p.name}")
            try: sel=int(input("Select: ")); p=projs[sel-1]; f=list(p.glob("*.*")); subprocess.call([EDITOR, str(f[0])])
            except: pass
        elif c=="5": gen_blinks()
        elif c=="6": help_ui()
        elif c=="7": show_manual()
        elif c=="0": sys.exit()

if __name__ == "__main__":
    main()
EOF_PY

chmod +x "$BASE/mhex.py"
cat > "$BIN/mhex" <<EOF
#!/bin/bash
export PATH="$BIN:$PATH"
python3 "$BASE/mhex.py"
EOF
chmod +x "$BIN/mhex"
if [ -d "/usr/bin" ]; then ln -sf "$BIN/mhex" /usr/bin/mhex; elif [ -d "/usr/local/bin" ]; then ln -sf "$BIN/mhex" /usr/local/bin/mhex; fi

echo -e "\n${C_GRN}mikey:hexoid v5.0.0 (UNIVERSAL) INSTALLED SUCCESSFULLY.${C_OFF}"
echo -e "Type ${C_CYAN}mhex${C_OFF} to start the Omni-Engine."
