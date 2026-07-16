# 1. Baseline and backups

Do this before changing firmware, `printer.cfg`, `Macro.cfg`, probe settings, or motor settings.

## Confirm the machine

- Confirm the label and hardware are **Sovol SV08 Max**.
- Do not use the standard SV08 motor, geometry, travel, probing, or OrcaSlicer values as substitutes.
- Record the current Klipper, Moonraker, and UI versions.
- Record the main MCU and toolhead/extra MCU identifiers.

## Create recovery copies

Make dated copies of:

1. The complete live printer configuration directory.
2. `printer.cfg`.
3. `Macro.cfg` and any included macro files.
4. The current toolhead firmware/build configuration.
5. The full ST-Link backup, kept separately from the working copy.

Never overwrite the only backup. Keep the original factory files and every dated `printer.pre-*.cfg` or `Macro.pre-*.cfg` file.

## Baseline gate

Before continuing, Mainsail must show `Ready`. If it does not:

1. Read the complete error.
2. Fix or restore the existing problem.
3. Restart Klipper.
4. Confirm `Ready` again.

The documented Max baseline was reachable at `***.***.***.***`, with HTTP returning `200 OK`. That address is intentionally redacted; confirm the address of your own printer.
