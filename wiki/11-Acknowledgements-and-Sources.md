# 11. Acknowledgements and source map

This guide is a community synthesis, not a solo invention. Thank you to every
maintainer, author, tester, and forum participant who published the pieces that
made a recoverable SV08 Max Eddy-NG conversion possible.

## People and projects

### Vladimir Vukicevic (`vvuk`) and Eddy-NG contributors

- Project: [vvuk/eddy-ng](https://github.com/vvuk/eddy-ng)
- Used for: LDC1612 support, Eddy-NG installation, tap behavior, configuration
  options, calibration commands, status checks, and the reading-to-height
  model.
- Credit boundary: Eddy-NG owns the software concepts and commands; this guide
  contributes one SV08 Max installation history and measured values.
- Beginner-flow verification: the July 16, 2026 revision was checked against
  Eddy-NG source commit `1ed056b` and Wiki commit `ade8664`, including automatic
  `PROBE_EDDY_NG_SETUP` and post-calibration tests before `SAVE_CONFIG`.

### Roar Ree (3DPrintDemon)

- Project: [Demon Klipper Essentials Unified](https://github.com/3DPrintDemon/Demon_Klipper_Essentials_Unified)
- Used for: Sovol/Klipper community knowledge, macro and UI behavior context,
  recovery-minded workflows, and broader printer-modification experience.
- Thank you: Roar has done substantial work around this printer family and
  shared experience that helped the community avoid repeating failures.
- Credit boundary: the touchscreen field modification in this repository is
  not represented as an official DKEU patch unless an upstream source is later
  identified and linked.

### bearclaw92

- Project: [Zero Toolhead Guide](https://github.com/bearclaw92/Zero_Toolhead_Guide)
- Used for: a comparable Sovol Zero toolhead CAN/Katapult workflow, wiring and
  flashing checkpoints, and the warning that stock Zero toolheads already use
  Katapult.
- Credit boundary: that guide targets a standard SV08-to-Zero conversion. This
  repository is SV08 Max-specific and does not copy standard SV08 geometry or
  motor values.

### Rappetor

- Project: [Sovol SV08 Mainline](https://github.com/Rappetor/Sovol-SV08-Mainline)
- Used for: mainline Klipper and Katapult/CAN reference concepts and community
  troubleshooting cross-checks.
- Credit boundary: the project targets the standard SV08. Every Max value in
  this guide was checked separately.

### Andrew (`andrewmcgr`) and contributors

- Project: [Klipper TMC Autotune](https://github.com/andrewmcgr/klipper_tmc_autotune)
- Used for: automatic TMC register calculation and the custom motor-constants
  format.
- Credit boundary: Max motor constants and currents came from Max-specific
  labels, drawings, and factory configuration; they are not universal values.

### Sovol

- Project: [Official SV08 Max repository](https://github.com/Sovol3d/SV08MAX)
- Used for: factory configuration, board/hardware references, Max-specific
  motor models, motor drawings, currents, and source baseline.

### Klipper team and contributors

- Project: [Klipper](https://github.com/Klipper3d/klipper)
- Used for: firmware, configuration semantics, `SAVE_CONFIG`, PID calibration,
  resonance measurement, input shaper, bed mesh, and pressure advance.
- Documentation: [klipper3d.org](https://www.klipper3d.org/)

### Kevin O'Connor, Arksine, and Katapult contributors

- Project: [Katapult](https://github.com/Arksine/katapult)
- Used for: CAN bootloader protocol, application offset, query and flashing
  behavior.

### BIGTREETECH and Eddy contributors

- Project: [BIGTREETECH Eddy](https://github.com/bigtreetech/Eddy)
- Used for: Eddy hardware documentation and calibration cross-checks.

### STMicroelectronics

- Tool: [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
- Used for: ST-Link connection, full-flash backup, device identification, and
  recovery preparation.

## Community discussions

Thanks to the people who asked questions, posted logs, challenged assumptions,
and documented failures in:

- [r/Sovol](https://www.reddit.com/r/Sovol/)
- [r/SovolSV08](https://www.reddit.com/r/SovolSV08/)
- [r/SovolSV08Max](https://www.reddit.com/r/SovolSV08Max/)
- [r/klippers](https://www.reddit.com/r/klippers/)

Threads used as community cross-checks include:

- [SV08 toolhead CAN discussion](https://www.reddit.com/r/Sovol/comments/1evvyjl)
- [SV08 upgrades and Zero Toolhead Guide mention](https://www.reddit.com/r/SovolSV08/comments/1p50d94/what_are_the_must_have_sv08_mods/)
- [SV08 Max toolhead experience](https://www.reddit.com/r/SovolSV08Max/comments/1unnr9t/anyone_successfully_running_an_alternative/)
- [Eddy-NG configuration/update troubleshooting](https://www.reddit.com/r/klippers/comments/1rdtefe/eddy_probe_issue/)

Forum advice is treated as a lead, not an authority. Hardware- and
firmware-sensitive claims in this guide are cross-checked against primary
project documentation or the actual SV08 Max state.

## How to add missing credit

If a procedure or example here came from your work and the attribution is
missing or incomplete, please open an issue or pull request with the original
source link and the section that needs correction. Credit corrections should
be treated as high priority.
