# Clean SV08 Max configuration bundle

These files are a cleaned, privacy-safe reconstruction of a working Sovol
SV08 Max configuration after converting its stock LDC1612 toolhead sensor to
Eddy-NG behavior.

## Files and responsibility

| File | Required | Purpose |
| --- | --- | --- |
| `printer.cfg` | Yes | Max hardware pins, steppers, heaters, fans, and limits |
| `eddy_ng.cfg` | Yes | Eddy-NG probe, mesh, QGL, and Eddy-aware homing |
| `macros.cfg` | Yes | Start/end, tested cleaning, pause/resume, fan mapping, and idle shutdown |
| `runout_only.cfg` | Yes for stock buffer MCU runout | Keeps only the PA10 runout switch; no feeder motor or jam logic |
| `tmc_autotune.cfg` | Optional | Max-specific TMC Autotune motor definitions |
| `saved_variables.cfg` | Yes | Initially empty storage used by `[save_variables]` |

The old `buffer_stepper.cfg` is deliberately not included. The documented
printer's feeder was gutted because it damaged filament. Publishing both
`buffer_stepper.cfg` and `runout_only.cfg` would create duplicate MCU/sensor
sections and confuse readers.

The old standalone `Eddy.cfg` and `eddyng.cfg` were inactive USB-Eddy examples.
This Max uses the toolhead LDC1612 through `extra_mcu:i2c2`; use the included
`eddy_ng.cfg` instead.

## Replace these placeholders

- `YOUR_MAIN_MCU_CAN_UUID`
- `YOUR_TOOLHEAD_CAN_UUID`
- `YOUR_BUFFER_MCU_CAN_UUID`

Discover CAN UUIDs while Klipper is stopped:

```bash
sudo systemctl stop klipper
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
sudo systemctl start klipper
```

Never copy another printer's UUID.

## Install order

1. Confirm this is an **SV08 Max**, not a standard SV08.
2. Install Eddy-NG from its current upstream documentation.
3. If using TMC Autotune, install it before enabling its include.
4. Back up the complete live configuration directory off the printer.
5. Upload the six files to `~/printer_data/config/`.
6. Replace every `YOUR_...` placeholder.
7. Keep the Mainsail-provided `mainsail.cfg` in the same directory.
8. If TMC Autotune is not installed, comment only this line in `printer.cfg`:

   ```ini
   [include tmc_autotune.cfg]
   ```

9. Run `RESTART` and verify Klipper reports `Ready`.
10. Calibrate Eddy-NG. Do not copy another probe's generated model.
11. Run PID calibration for the installed hotend/bed if hardware differs.
12. Run `SHAPER_CALIBRATE`, then `SAVE_CONFIG`.
13. Run the first cleaning and homing cycle under supervision.

## Generated data

This bundle intentionally contains no `SAVE_CONFIG` block, bed mesh, Eddy
frequency model, drive-current table, or copied device calibration. Klipper
creates those for the actual machine. There must be only one generated
`SAVE_CONFIG` header, and every manual section must remain above it.

## Deliberate cleanup from the live history

- Removed obsolete USB Eddy files and commented stock-probe remnants.
- Removed the gutted buffer stepper, jam detection, feeder LEDs, and feeder
  macros.
- Runout now calls `M600` immediately instead of waiting an old 1100 mm buffer
  distance.
- Removed `START_PRINT`'s `40000` acceleration override; `[printer] max_accel`
  remains authoritative.
- Removed dead/commented macro branches and obsolete buffer references.
- Standardized runout status checks on Klipper's `enabled` attribute.
- Separated Eddy-NG and TMC Autotune into clear includes.

## Tested cleaning geometry

The documented machine raised its textured cleaning surface evenly with four
identical washers. In the relative (`G91`) second cleaning stage, the tested
descent is:

```gcode
G1 Z-5.325
```

Do not use that move without reproducing/remeasuring the mechanical stack and
confirming the macro is in relative mode.
