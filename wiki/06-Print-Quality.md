# 6. Print-quality tuning

Do this only after Eddy-NG probing and the first layer are stable.

## Input shaper

Measure resonances using the [Klipper resonance compensation guide](https://www.klipper3d.org/Resonance_Compensation.html). The latest documented run selected:

```ini
[input_shaper]
shaper_type_x: mzv
shaper_freq_x: 49.8
damping_ratio_x: 0.1
shaper_type_y: mzv
shaper_freq_y: 34.2
damping_ratio_y: 0.1
```

These are measurements from one machine, not defaults. Run:

```text
SHAPER_CALIBRATE
SAVE_CONFIG
```

The Y result suggested `max_accel <= 3400 mm/s^2`. A surface-quality-first
ceiling of `3000 mm/s^2` was chosen. The weaker axis governs the global CoreXY
limit; do not use X's higher recommendation as the global limit.

`TEST_RESONANCES` produces raw CSV data but does not apply a shaper. Existing
CSV files can be analyzed with `~/klipper/scripts/calibrate_shaper.py`; the
script prints a recommendation that must be entered manually. A live
`SHAPER_CALIBRATE` stages values for `SAVE_CONFIG`.

## Hotend PID

The documented Max hotend calibration at 250 °C produced:

```ini
control: pid
pid_Kp: 37.537
pid_Ki: 5.820
pid_Kd: 60.526
```

Keep `control: pid` and the PID values active. A commented-out control line can make Klipper reject an otherwise valid calibration.

## Bed PID, flow, and pressure advance

- Bed PID still needs a deliberate calibration at the normal bed temperature.
- Calibrate flow for each filament and actual spool.
- Tune pressure advance after mechanics, temperature, and flow are stable.
- A historical Max pressure-advance value of `0.025` is a starting point, not a universal recommendation.

## PID save trap

The factory extruder section had `control` and PID entries commented. After a
PID tune, Klipper can fail with `Option 'control' ... must be specified` or
`Option 'pid_Kp' ... must be specified` if only part of the PID block is
active. Keep the complete block together above `SAVE_CONFIG`:

```ini
control: pid
pid_Kp: 37.537
pid_Ki: 5.820
pid_Kd: 60.526
```
