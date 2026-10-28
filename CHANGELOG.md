# Changelog

All notable changes to **mikey:hexoid** are recorded here. The project uses a simple
`MAJOR.MINOR.PATCH` version string.

## [5.0.0] — documentation, identity and repository-quality release

### Added

- Repository-wide `POWERED BY [mikey:hexoid-sys]` identity: hero artwork, square mark, social preview and
  `assets/README.md` describing approved usage.
- `NOTICE.md`, `AUTHORS.md`, `CITATION.cff`, `SUPPORT.md`, `SECURITY.md` and
  `CONTRIBUTING.md`.
- Structured documentation: quick start, usage, output formats, flashing, STM32 workflow,
  FPGA workflow, troubleshooting, limitations and architecture notes.
- `tools/verify_repository.py` and a GitHub Actions workflow that check file structure,
  required credits, licence terms, script syntax, the embedded Python engine and asset
  checksums.
- Issue forms for bug reports and commercial-licence requests, plus a pull-request template.

### Changed

- `LICENSE` replaced with the stricter mikey-7x personal and educational licence, adapted
  for a compiler and its build outputs: attribution and logo use are now conditions of
  permission, and commercial or industrial use requires written permission.
- `README.md` rewritten for accuracy: target-dependent output formats, honest description of
  the dependency-repair step, known failing board IDs and verified flashing steps.
- `mhex.sh` and `mhex_e.sh` gained author, licence and powered-by headers and a console
  attribution line. **No compilation logic was changed.**

### Unchanged

- The 105-entry board table, LED map, compile pipeline, FPGA flow, SDCC flow, library
  manager and output routing.
- `mhex.png` original artwork, kept byte-for-byte.

## [5.0.0] — STM32 carrier-grade update

### Added

- STM32 advanced workflow (menu 8) with LL, HAL and Arduino boilerplate.
- Cross-series guards for STM32F1 and STM32F4 projects.
- Modernised LL macro names (`LL_GPIO_MODE_OUTPUT`).

### Fixed

- Cross-distribution package resolution for `apt`, `pacman`, `xbps` and Termux `pkg`.
- Unified Android output routing for STM32 `.hex`, `.bin`, `.elf` and `.map` files.
