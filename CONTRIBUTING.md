# Contributing

Thank you for helping improve **mikey:hexoid**. This is a strict
non-commercial project, so please read the boundaries before sending work.

## Before you open an issue

1. Run `python3 tools/verify_repository.py` and paste the result if it fails.
2. Note your platform (`uname -a`), package manager and engine (`mhex.sh` or `mhex_e.sh`).
3. Paste the failing menu number, target board ID and the compiler output — not only
   “it does not work”.

## Reporting a build failure

Include:

- engine and menu option used;
- board ID from the printed table;
- Arduino CLI version (`~/mikey-hexoid/bin/arduino-cli version`);
- installed cores (`arduino-cli core list --config-file ~/mikey-hexoid/config/arduino-cli.yaml`);
- the first error line from the compiler output.

## Pull requests

- Keep changes focused; one topic per pull request.
- Never remove or reword the `POWERED BY [mikey:hexoid-sys]` credit, author identity or licence notices.
- Keep the board table backward compatible — do not renumber existing IDs.
- Run `python3 tools/verify_repository.py` before submitting.
- State clearly which files you changed and why.

## Licence of contributions

By submitting code, documentation or corrections you confirm that you wrote them, or have
permission to submit them, and you grant the project author the right to include them, with
credit where practical. See section 9 of [LICENSE](LICENSE).

## Commercial use

Commercial or industrial use is not accepted through pull requests. Contact the author
through https://github.com/mikey-7x or the commercial-licence issue form.
