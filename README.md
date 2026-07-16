# Sovol SV08 Max: Eddy-NG and Proven Modifications

This is a practical, recovery-conscious guide for converting the **stock Sovol
SV08 Max toolhead LDC1612 sensor** to Eddy-NG and integrating the result into a
clean Klipper configuration. It documents the working path, the mistakes that
caused real failures, and the checks that keep those mistakes from being
repeated.

This project grew out of several intense days of rebuilding and testing the
printer, including many wrong turns that others had already solved. Everything
useful is collected here so the next owner does not have to duplicate that
work. The documented setup has completed roughly 100 hours of printing without
the earlier errors. That result was possible because maintainers and community
members—including Roar Ree and the people credited below—shared their work. If
an attribution is missing, please open an issue so it can be corrected.

> This repository is for the **SV08 Max**, not the standard SV08. Their motion
> limits, motors, board layout, firmware, probing geometry, and macros must not
> be treated as interchangeable.

## Start here

1. Read [Baseline and backups](wiki/01-Baseline-and-Backups.md) before changing
   firmware or configuration.
2. Follow [Toolhead firmware and Katapult](wiki/02-Toolhead-Firmware.md) if the
   toolhead firmware has not already been prepared.
3. Install and configure Eddy-NG with
   [Eddy-NG configuration](wiki/03-Eddy-NG-Configuration.md).
4. Complete the full [calibration sequence](wiki/04-Calibration.md).
5. Install the [clean configuration bundle](config/README.md) only after
   comparing every pin, UUID placeholder, and hardware option with your own
   printer.

## Clean configuration bundle

| File | What it contains |
| --- | --- |
| [`config/printer.cfg`](config/printer.cfg) | SV08 Max pins, steppers, heaters, fans, currents, and safe limits |
| [`config/eddy_ng.cfg`](config/eddy_ng.cfg) | Stock toolhead LDC1612, Eddy-NG probing, mesh, QGL, and homing |
| [`config/macros.cfg`](config/macros.cfg) | Start/end, pause/resume, runout, power-down, and the tested cleaning routine |
| [`config/runout_only.cfg`](config/runout_only.cfg) | Stock buffer MCU used only for filament-presence runout detection |
| [`config/tmc_autotune.cfg`](config/tmc_autotune.cfg) | Optional, SV08 Max-specific TMC Autotune motor definitions |
| [`config/saved_variables.cfg`](config/saved_variables.cfg) | Empty persistent-variable file required by the clean configuration |

The bundle deliberately excludes inactive USB-Eddy examples, the gutted buffer
feeder and jam logic, copied calibration models, duplicate `SAVE_CONFIG`
headers, old commented code, and untested slicer profiles.

## Guide index

- [Home and scope](wiki/Home.md)
- [Baseline and backups](wiki/01-Baseline-and-Backups.md)
- [Toolhead firmware and Katapult](wiki/02-Toolhead-Firmware.md)
- [Eddy-NG configuration](wiki/03-Eddy-NG-Configuration.md)
- [Calibration sequence](wiki/04-Calibration.md)
- [Start sequence and proven cleaning macro](wiki/05-Start-Sequence.md)
- [Print-quality tuning](wiki/06-Print-Quality.md)
- [Troubleshooting and recovery](wiki/07-Troubleshooting.md)
- [TMC Autotune, fans, and runout-only buffer MCU](wiki/08-TMC-Fans-and-Buffer.md)
- [Touchscreen communication fix and recovery lessons](wiki/10-Touchscreen-and-Recovery-Lessons.md)
- [Acknowledgements and source map](wiki/11-Acknowledgements-and-Sources.md)

## Proven cleaning geometry

On the documented machine, the textured cleaning surface was raised evenly
with **four identical washers**. The second, relative-motion cleaning stage was
then proven with:

```gcode
G1 Z-5.325
```

That value is not portable by itself. It is safe only after reproducing or
remeasuring the physical stack-up, confirming the macro is in `G91` relative
mode, and supervising the first cycle with emergency stop immediately
available.

## Touchscreen communication fix

The factory touchscreen could leave routine messages in a blocking **Sure**
dialog and prevent Mainsail or another external client from submitting a print.
The required behavior change, safety boundaries, and verification steps are
documented in [Touchscreen behavior and recovery
lessons](wiki/10-Touchscreen-and-Recovery-Lessons.md). The fix keeps routine
messages visible without letting them own the printer's communication state;
real destructive actions still require confirmation.

## Non-negotiable safety rules

- Make a complete off-printer backup before firmware, MCU, or configuration
  work.
- Never copy CAN UUIDs from this repository or another printer.
- Confirm the firmware application offset before flashing. A no-offset image
  and an 8 KiB Katapult-offset image are not interchangeable.
- An 8 KiB read is not a full backup of a 128 KiB STM32F103.
- Keep all manual configuration above the single generated `SAVE_CONFIG`
  boundary.
- Never copy another Eddy coil model, drive-current calibration, bed mesh,
  input-shaper result, PID result, or live Z offset.
- Change one variable at a time and verify Klipper returns to `Ready` after
  every restart.

## Privacy placeholders

Personal paths and device identifiers are replaced with names such as
`YOUR_PRINTER_IP`, `YOUR_MAIN_MCU_CAN_UUID`, `YOUR_TOOLHEAD_CAN_UUID`, and
`YOUR_BUFFER_MCU_CAN_UUID`. Replace them only with values read from your own
machine.

## Acknowledgements

This work stands on Eddy-NG by Vladimir Vukicevic and contributors; community
work shared by Roar Ree (3DPrintDemon), bearclaw92, Rappetor, and Andrew
McGrath; and the Klipper, Katapult, Sovol, STMicroelectronics, and BIGTREETECH
projects and communities. See the [full acknowledgements and source
map](wiki/11-Acknowledgements-and-Sources.md) for attribution and the limits of
each source's applicability to the SV08 Max.

## Status

- Eddy-NG conversion and calibration path: documented from a working SV08 Max
- Four-washer cleaning routine with `G1 Z-5.325`: physically tested
- Clean configuration bundle: reconstructed from the active configuration and
  stripped of personal identifiers, inactive legacy files, and generated
  per-printer calibration data
- Slicer profiles: intentionally not included because they were not validated
