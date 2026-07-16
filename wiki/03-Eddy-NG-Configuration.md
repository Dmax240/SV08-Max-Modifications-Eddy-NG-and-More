# 3. Eddy NG configuration

Eddy-NG is the work of [Vladimir Vukicevic (`vvuk`) and project
contributors](https://github.com/vvuk/eddy-ng). Use its current wiki and
configuration reference as the authority for version-specific option names.

Use this as a checklist alongside the current SV08 Max configuration. It is not a drop-in replacement for every Max revision.

## Recorded Max values

| Setting | Recorded value |
| --- | --- |
| Sensor | LDC1612 on the extra MCU |
| I2C bus | `i2c2` |
| X offset | `-19.8` mm |
| Y offset | `-0.75` mm |
| `home_trigger_height` | `2.0` mm |
| `tap_target_z` | `-0.40` mm |
| Samples | 3 tap samples, 5 maximum samples |
| Standard deviation | `0.025` |
| Tap mode | `butter` |
| Threshold | `250` |

## Edit order

1. Back up the live configuration.
2. Confirm the extra MCU CAN UUID from the live machine.
3. Confirm the LDC1612 bus name is really `i2c2`.
4. Add or enable the Eddy-NG section.
5. Disable the stock probe section only after the Eddy section is present and backed up.
6. Check all probe offsets and safe Z heights.
7. Confirm ordinary configuration sections remain above Klipper’s generated `SAVE_CONFIG` area.
8. Confirm there is only one `SAVE_CONFIG` header.
9. Restart Klipper and verify `Ready`.

## Important historical value

An older `tap_adjust_z = 0.170` value was superseded. The live Max calibration later reported `tap_adjust_z: 0.0`. Read the live value before restoring anything from an old note.

## Annotated outline

See the cleaned [`config/eddy_ng.cfg`](https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More/blob/main/config/eddy_ng.cfg).
Section and option names can change with Eddy-NG versions, so compare the
example with the exact revision you installed. Do not paste it unchanged.

## `SAVE_CONFIG` boundary: the easiest way to break everything

Klipper owns everything after:

```text
#*# <---------------------- SAVE_CONFIG ---------------------->
```

All manual sections, includes, macros, TMC Autotune entries, and motor
constants must remain above that line. Check before and after every automated
save:

```bash
grep -n SAVE_CONFIG ~/printer_data/config/printer.cfg
```

There must be exactly one generated header. A duplicated header or manual
sections placed inside generated data can cause apparently unrelated probe,
PID, or motor errors after `SAVE_CONFIG`.
