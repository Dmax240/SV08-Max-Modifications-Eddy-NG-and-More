# 1. Baseline and backups

Do this before changing firmware, `printer.cfg`, `Macro.cfg`, probe settings, or motor settings.

## Confirm the machine

- Confirm the label and hardware are **Sovol SV08 Max**.
- Do not use the standard SV08 motor, geometry, travel, or probing values as substitutes.
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

Example configuration backup:

```bash
cp ~/printer_data/config/printer.cfg \
  ~/printer_data/config/printer.pre-eddy-$(date +%Y%m%d-%H%M%S).cfg
cp ~/printer_data/config/Macro.cfg \
  ~/printer_data/config/Macro.pre-eddy-$(date +%Y%m%d-%H%M%S).cfg
```

Also copy the entire `~/printer_data/config/` directory off the printer.

## ST-Link backup before toolhead flashing

Read the complete STM32 flash, not only the 8 KiB currently displayed in
STM32CubeProgrammer. For an STM32F103 with 128 KiB flash, read from
`0x08000000` for `0x20000` bytes. Verify that the resulting file is 131,072
bytes and record its SHA-256. An 8 KiB file is only the bootloader region and
is not a complete recovery image.

Do not erase or change option bytes while making the backup.

## Baseline gate

Before continuing, Mainsail must show `Ready`. If it does not:

1. Read the complete error.
2. Fix or restore the existing problem.
3. Restart Klipper.
4. Confirm `Ready` again.

The documented Max baseline returned HTTP `200 OK`. Its private address is not
published; use `YOUR_PRINTER_IP` from your own network.
