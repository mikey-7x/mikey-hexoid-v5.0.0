#!/usr/bin/env python3
"""Offline self-check for the mikey:hexoid v5.0.0 repository.

Verifies the expected file set, the required attribution, licence terms, shell
syntax, the embedded Python engine, the board table and the brand-asset
checksums. Prints a summary and exits non-zero when anything fails.
"""
from __future__ import annotations

import hashlib
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BRAND = "POWERED BY [mikey:hexoid-sys]"
REPO_URL = "https://github.com/mikey-7x/mikey-hexoid-v5.0.0"
AUTHOR = "Yogesh R. Chauhan"
COPYRIGHT = "Copyright © 2026 Yogesh R. Chauhan (mikey-7x). All rights reserved."
ARTWORK_SHA256 = "14f0cf6bca8435993e8a2bfd10d3691c278d841fcc1a93f907023b5f9d6a9945"

REQUIRED_FILES = [
    "README.md", "LICENSE", "NOTICE.md", "AUTHORS.md", "CHANGELOG.md",
    "CONTRIBUTING.md", "SECURITY.md", "SUPPORT.md", "CITATION.cff",
    "mhex.sh", "mhex_e.sh",
    ".gitattributes", ".gitignore",
    "assets/powered-by-mikey-hexoid-sys.png",
    "assets/powered-by-mikey-hexoid-sys.svg",
    "assets/mikey-hexoid-sys-mark.png",
    "assets/mikey-hexoid-sys-mark.svg",
    "assets/github-social-preview.png",
    "assets/README.md", "assets/SHA256SUMS",
    "docs/QUICKSTART.md", "docs/USAGE.md", "docs/OUTPUTS-AND-BOARDS.md",
    "docs/FLASHING.md", "docs/STM32-WORKFLOW.md", "docs/FPGA-WORKFLOW.md",
    "docs/TROUBLESHOOTING.md", "docs/KNOWN-LIMITATIONS.md",
    "docs/ARCHITECTURE.md",
    "tools/verify_repository.py",
    ".github/workflows/verify.yml",
    ".github/ISSUE_TEMPLATE/bug_report.yml",
    ".github/ISSUE_TEMPLATE/commercial_licence.yml",
    ".github/ISSUE_TEMPLATE/config.yml",
    ".github/PULL_REQUEST_TEMPLATE.md",
]

placed = []
failures = []


def check(name, condition, detail=""):
    if condition:
        placed.append(name)
    else:
        failures.append(f"{name}{(': ' + detail) if detail else ''}")


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def engine_python():
    """Extract the embedded Python engine from either installer."""
    text = read("mhex_e.sh")
    marker = "<<'EOF_PY'"
    start = text.index(marker) + len(marker)
    end = text.index("\nEOF_PY", start)
    return text[start:end], text


# ---------------------------------------------------------------- structure
for rel in REQUIRED_FILES:
    check(f"file exists: {rel}", (ROOT / rel).is_file())

# ------------------------------------------------------------------- credit
for rel in ("README.md", "NOTICE.md", "AUTHORS.md", "LICENSE", "assets/README.md",
            "mhex.sh", "mhex_e.sh", "docs/QUICKSTART.md"):
    if (ROOT / rel).is_file():
        check(f"brand line in {rel}", BRAND in read(rel))

readme = read("README.md") if (ROOT / "README.md").is_file() else ""
check("README credits the author", "Created by mikey-7x" in readme and AUTHOR in readme)
check("README links the official repository", REPO_URL in readme)
check("README links the author profile", "https://github.com/mikey-7x" in readme)
check("README records the copyright", "All rights reserved" in readme)
check("README has no stale project title", "298.666" not in readme)
check("README embeds the project card", "assets/github-social-preview.png" in readme)
check("README keeps the powered-by hero image", "assets/powered-by-mikey-hexoid-sys.png" in readme)

# ------------------------------------------------------------------ licence
licence = read("LICENSE") if (ROOT / "LICENSE").is_file() else ""
for phrase in ("STRICT PERSONAL & EDUCATIONAL USE LICENCE",
               "Attribution is a condition of permission",
               "ABSOLUTE COMMERCIAL AND INDUSTRIAL PROHIBITION",
               "Copyright (c) 2026 Yogesh R. Chauhan",
               BRAND, REPO_URL):
    check(f"licence contains: {phrase[:38]}", phrase in licence)
check("licence is not an open-source grant",
      re.search(r"not\s+an\s+open-source\s+licence", licence.lower()) is not None)
check("licence has no foreign project name",
      "298.666" not in licence and "transmitter" not in licence.lower())

# ------------------------------------------------------------------- scripts
for script in ("mhex.sh", "mhex_e.sh"):
    if not (ROOT / script).is_file():
        continue
    text = read(script)
    check(f"{script} keeps its shebang", text.startswith("#!/usr/bin/env bash"))
    check(f"{script} names the author", AUTHOR in text)
    check(f"{script} carries the licence notice", "Strict Personal & Educational Use Licence" in text)
    check(f"{script} prints the attribution", "POWERED BY [mikey:hexoid-sys]" in text)
    check(f"{script} pins Arduino CLI 0.35.3", "arduino-cli_0.35.3" in text)
    if script == "mhex_e.sh":
        check("mhex_e.sh keeps the STM32 workflow menu", 'elif c=="8": stm32_workflow()' in text)
    proc = subprocess.run(["bash", "-n", str(ROOT / script)], capture_output=True, text=True)
    check(f"{script} has valid bash syntax", proc.returncode == 0, proc.stderr.strip()[:200])

# -------------------------------------------------------------- engine code
try:
    code, shell = engine_python()
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as handle:
        handle.write(code)
        tmp = handle.name
    proc = subprocess.run([sys.executable, "-m", "py_compile", tmp], capture_output=True, text=True)
    check("embedded Python engine compiles", proc.returncode == 0, proc.stderr.strip()[:200])
    ids = re.findall(r'^\s*"(\d+)": \(', code, re.M)
    check("board table has 105 entries", len(ids) == 105, f"found {len(ids)}")
    check("board IDs are unique", len(set(ids)) == len(ids))
    check("board 40 is the BluePill F103C8", 'BLUEPILL_F103C8' in code)
    check("engine prints the attribution", BRAND in code)
    check("engine keeps the FPGA entry point", 'compile_fpga(' in code)
    check("engine keeps the SDCC flow", 'compile_sdcc(' in code)
except Exception as exc:  # pragma: no cover - defensive
    check("embedded Python engine readable", False, repr(exc))

# -------------------------------------------------------------------- assets
sums = ROOT / "assets" / "SHA256SUMS"
if sums.is_file():
    listed = 0
    for line in sums.read_text().splitlines():
        if not line.strip():
            continue
        digest, name = line.split(maxsplit=1)
        target = ROOT / "assets" / name.strip()
        actual = hashlib.sha256(target.read_bytes()).hexdigest() if target.is_file() else ""
        check(f"asset checksum: {name.strip()}", actual == digest)
        listed += 1
    check("asset checksum list is complete", listed == 5, f"listed {listed}")
else:
    check("asset checksum list exists", False)

artwork = ROOT / "mhex.png"
check("mhex.png artwork present",
      artwork.is_file(),
      "expected in a full repository checkout; an update package ships only changed files")
if artwork.is_file():
    check("mhex.png artwork unchanged",
          hashlib.sha256(artwork.read_bytes()).hexdigest() == ARTWORK_SHA256)

# ---------------------------------------------------------------- leftovers
for rel in ("README.md", "NOTICE.md", "AUTHORS.md", "CONTRIBUTING.md", "SUPPORT.md"):
    if (ROOT / rel).is_file():
        text = read(rel).lower()
        check(f"no placeholders in {rel}", not any(w in text for w in ("todo", "tbd", "lorem ipsum", "fixme")))

# -------------------------------------------------------------------- output
total = len(placed) + len(failures)
print(f"Repository verification: {len(placed)}/{total} passed")
if failures:
    print("\nFailed checks:")
    for item in failures:
        print(f"  - {item}")
    sys.exit(1)
print("All structural, branding, licence, syntax and asset checks passed.")
print("This verifies files only; it does not test hardware or compiler correctness.")
