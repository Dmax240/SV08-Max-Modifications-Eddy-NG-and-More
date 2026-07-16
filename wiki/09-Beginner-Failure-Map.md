# 9. Beginner failure map

Start with the exact message on screen. Match it below and perform only that
branch. After every correction, run `RESTART` and confirm Mainsail shows
`Ready` before continuing.

## Mainsail is disconnected

1. Confirm the printer is powered and network-connected.
2. Refresh `http://YOUR_PRINTER_IP/`.
3. In SSH, run:

   ```bash
   systemctl status klipper --no-pager
   journalctl -u klipper -n 80 --no-pager
   ```

4. Fix the first actual Klipper error. Later messages are often consequences.

## `Unable to open CAN port` or a missing MCU

In SSH:

```bash
ip -details -statistics link show can0
grep -Rns '^[[:space:]]*canbus_uuid:' ~/printer_data/config
```

Expected bus state: `ERROR-ACTIVE`, bitrate `1000000`, and no rising bus-error
or bus-off counts. Confirm every UUID came from this printer.

Stop if CAN is bus-off or the toolhead has no power. Reflashing is not the
first response to a wiring, power, bitrate, or UUID problem.

## `Option ... must be specified`

The named section exists but a required line is missing or commented out.

Common examples from this project:

- Extruder needs `control: pid` and all three PID values together.
- The old buffer feeder needs its required `push_pin`; deleting only that line
  is not a supported disable method.
- `buffer_stepper.cfg` and `runout_only.cfg` must not both define the same MCU
  or sensor.

Compare with the dated backup. Do not invent a value.

## More than one `SAVE_CONFIG` result

In SSH:

```bash
grep -n 'SAVE_CONFIG' ~/printer_data/config/printer.cfg
```

There must be no more than one generated boundary. If manual sections appear
below it, restore the latest clean backup and reapply those sections above the
single boundary. Do not hand-edit generated calibration lines unless you are
deliberately removing the whole affected generated section.

## `Unknown command: PROBE_EDDY_NG_...`

Eddy-NG is not installed into the active Klipper tree, Klipper was updated
after installation, or the relevant configuration was not loaded.

In SSH:

```bash
ls -l ~/klipper/klippy/extras/probe_eddy_ng.py
ls -l ~/klipper/klippy/extras/ldc1612_ng.py
```

If missing:

```bash
cd ~/eddy-ng
git pull
./install.sh
sudo systemctl restart klipper
```

Rebuild and reflash toolhead firmware only if the host files are correct but
the MCU firmware lacks Eddy-NG support.

## `PROBE_EDDY_NG_STATUS` shows `0xffffffff`

This is a sensor communication failure, not a Z-offset problem.

Check:

- Toolhead MCU is connected.
- `sensor_type: ldc1612`.
- `i2c_mcu: extra_mcu`.
- `i2c_bus: i2c2` for the documented Max board.
- Firmware was rebuilt after Eddy-NG installation.

Do not home Z until real changing coil values appear.

## `X and Y must be homed before calibrating`

In the Mainsail Console:

```text
G28 X Y
G90
G0 X271 Y251 F9000
```

Then start `PROBE_EDDY_NG_SETUP` or the chosen calibration command again.
Use a space between `X` and `Y`.

## `Unknown command: TESTZ`, `ACCEPT`, or `ABORT`

Those commands exist only while a manual-probe helper is active. The helper
already completed, aborted, or was interrupted. Start calibration again; do
not repeatedly send stale touchscreen buttons.

When Eddy-NG says calibration was saved, follow its current post-calibration
tests before `SAVE_CONFIG`.

## `Drive current ... not calibrated`

Do not print. First try the current upstream automatic flow:

```text
G28 X Y
G90
G0 X271 Y251 F9000
PROBE_EDDY_NG_SETUP
```

Use manual `PROBE_EDDY_NG_CALIBRATE DRIVE_CURRENT=...` only when automatic
setup fails or you intentionally need a different current. Current 15 is a
recorded result from one toolhead, not a universal answer.

## Z homing keeps descending

Hit emergency stop or remove printer power immediately.

Before retrying, confirm:

- A spring-steel plate is installed.
- The probe is over metal during Z home.
- `[stepper_z]` uses `endstop_pin: probe:z_virtual_endstop`.
- A safe `homing_override` moves the sensor over the bed.
- Static probe readings are plausible.

Never retry unattended.

## `Tap detected too close to target z`

1. Clean the nozzle completely.
2. Confirm no filament blob or debris is touching first.
3. Test one sample with a conservative target.
4. Change `TARGET_Z` in 0.100 mm steps only when the nozzle is not making
   adequate contact before the commanded limit.

Do not change `tap_adjust_z`, live Z, mesh, and target Z together.

## Tap completes movement without triggering

The configured target may be reached before adequate physical contact, or the
signal/threshold is wrong. Manually verify the mechanical contact position
under supervision. A suspicious result almost equal to `TARGET_Z` is not a
trustworthy tap.

Save `/tmp/tap-samples.csv` and, when enabled, `/tmp/tap.html` for diagnosis.

## QGL fails or threatens the bed

The first QGL pass must tolerate gantry skew. The supplied macro performs a
coarse pass at 8 mm before the accurate low pass. Confirm that macro loaded and
the plate is installed. Stop for grinding, contact, or a sensor error.

## First layer is too close or ragged

Do not edit the cleaning macro, tap target, Z offset, mesh, flow, and pressure
advance in the same test.

Use this order:

1. Clean nozzle and plate.
2. Repeat tap.
3. Repeat a small first-layer patch.
4. Adjust live Z by one 0.010 mm step.
5. Reprint the same patch.
6. Persist only after the result repeats cold and warm.

The old `tap_adjust_z: 0.170` is not a current requirement.

## Cleaning moves above or presses into the plate

Stop the macro. Cleaning height is mechanical geometry, not probe calibration.

The documented `G1 Z-5.325` is safe only in the relative `G91` stage with the
cleaning surface raised by four identical washers. Measure your own stack and
supervise the first pass. Do not compensate with global Z offset.

## Buffer says filament is jammed after the feeder was gutted

Do not load the old `buffer_stepper.cfg`. Use the supplied
`runout_only.cfg`, which keeps only the PA10 filament-presence switch. Ensure
only one buffer MCU and one `filament_sensor` section are active.

## A fan still runs at room temperature

Use your ears and a safe visual inspection to identify the physical fan. The
Klipper `bed_fan` should respond to its heater threshold. A PSU or electronics
fan may be hardwired and cannot be stopped by a fan macro. Do not modify
mains-adjacent wiring merely to silence it.

## TMC motors make a faint high-pitched sound

A quiet switching tone can be normal. Stop for grinding, loud new noise,
unexpected motion, driver shutdown, or overheating. Confirm the Max-specific
motor models and currents before changing registers.

## Fast rollback to the dated configuration backup

Use this only when Klipper cannot load the new configuration and the backup was
known-good. In SSH, replace `YOUR_BACKUP_DIRECTORY` with the exact path printed
in Step 2:

```bash
sudo systemctl stop klipper
mv ~/printer_data/config ~/printer_data/config-failed-$(date +%Y%m%d-%H%M%S)
cp -a YOUR_BACKUP_DIRECTORY ~/printer_data/config
sudo systemctl start klipper
```

Expected result: Mainsail returns to the pre-conversion state. This rollback
does not change MCU firmware; toolhead firmware recovery may still be required
when the host and MCU firmware no longer match.

