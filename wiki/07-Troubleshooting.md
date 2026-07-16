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

Choose exactly one approach:

1. Keep the original buffer section and use its supported disable variable,
   retaining the required `push_pin`; or
2. Remove that entire buffer include and use the supplied `runout_only.cfg`.

Do not load both implementations. The final documented machine uses the second
approach because the feeder was gutted.

## Fan still audible at room temperature

The bed-fan threshold can control Klipper’s cooldown behavior. A fan that continues at room temperature may be a directly powered PSU or electronics fan outside Klipper control.

## Community cross-checks

- [Reddit: SV08 upgrades and Eddy discussion](https://www.reddit.com/r/Sovol/comments/1ffpupx)
- [Reddit: recent SV08/Eddy-kit discussion](https://www.reddit.com/r/SovolSV08/comments/1tvowr5)
- [Rappetor mainline reference](https://github.com/Rappetor/Sovol-SV08-Mainline) — reference only; validate against SV08 Max hardware.

## “Drive current 15 not calibrated”

Do not start a print. Home X/Y and run the current upstream automatic
`PROBE_EDDY_NG_SETUP` flow first. If manual calibration is required, complete
the helper, test `PROBE_EDDY_NG_PROBE_STATIC`, perform a supervised Z home, and
verify the reading near Z=2 mm before `SAVE_CONFIG`. Repeated stale touchscreen
`ABORT` messages do not prove calibration was erased.

## `Option 'push_pin' ... must be specified`

The old buffer section requires `push_pin`; deleting only that option is not a
supported disable method. Either restore the complete old section and use its
global disable variable, or remove the complete include and use
`runout_only.cfg`. Never leave a partial section or load both.

## Motors make a slight high-pitched sound at rest

A quiet switching tone can occur with TMC drivers. Stop if there is grinding,
violent vibration, unexpected motion, overheating, or a new loud tone. Verify
the active run currents and motor definitions before changing registers.
