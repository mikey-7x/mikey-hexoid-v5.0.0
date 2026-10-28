# Security policy

## Supported versions

| Version | Supported |
| --- | --- |
| 5.0.0 | Yes |

## Safe-use design notes

`mikey:hexoid` installs toolchains and flashes firmware. Treat it as a privileged helper:

- The installer calls the system package manager with `sudo` for distribution packages.
  Read `mhex.sh` / `mhex_e.sh` before running them on a machine you care about.
- The generated Arduino CLI configuration sets `network.insecure: true` so that mirrors with
  older TLS chains still work, and the FPGA tool download uses `wget --no-check-certificate`.
  If your network is trusted, prefer verifying downloaded toolchains against their publisher
  checksums before use.
- Nothing is installed outside `$HOME` except distribution packages.
- Only flash firmware you built or trust, and confirm board identity and supply voltage first.

## Reporting a vulnerability

Please do not open a public issue for a security problem. Contact the author privately
through https://github.com/mikey-7x and include:

- affected file and version;
- steps to reproduce;
- impact (for example command execution, credential exposure, bricked device);
- any suggested fix.

You will get an acknowledgement as soon as reasonably possible. Please allow time for a fix
before public disclosure.

## Out of scope

- Vulnerabilities in third-party toolchains, cores or libraries — report those upstream.
- Damage caused by flashing the wrong board, wrong voltage or wrong file.
- Overclocked or experimental settings presented as certified.
