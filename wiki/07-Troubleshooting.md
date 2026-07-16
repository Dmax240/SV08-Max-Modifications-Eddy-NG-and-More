# 7. Troubleshooting

## “Tap detected too close to target z”

Confirm the nozzle is clean and the probe is installed correctly. Change `tap_target_z` in small steps; the documented Max change was `-0.30` to `-0.40`. Do not compensate by randomly changing live Z at the same time.

## First layer too close or ragged

Pause macro edits. Run a small first-layer patch and change one variable at a time. Check tap adjustment, cleaning height, mesh behavior, and pressure advance separately.

## Klipper fails after editing `printer.cfg`

Check the generated boundary:

```text
grep -n SAVE_CONFIG printer.cfg
```

There must be exactly one result. Normal config, macros, motor constants, and TMC sections belong above that boundary. Restore the latest relevant dated backup, restart, and confirm `Ready`.

## Buffer feeder jam

Do not delete the required `push_pin` option. The supported disable method recorded for this Max is:

```ini
variable_is_push_buffer: False
```

This disables buffer push/jam automation while leaving the normal runout sensor active.

## Fan still audible at room temperature

The bed-fan threshold can control Klipper’s cooldown behavior. A fan that continues at room temperature may be a directly powered PSU or electronics fan outside Klipper control.

## Community cross-checks

- [Reddit: SV08 upgrades and Eddy discussion](https://www.reddit.com/r/Sovol/comments/1ffpupx)
- [Reddit: recent SV08/Eddy-kit discussion](https://www.reddit.com/r/SovolSV08/comments/1tvowr5)
- [Rappetor mainline reference](https://github.com/Rappetor/Sovol-SV08-Mainline) — reference only; validate against SV08 Max hardware.
