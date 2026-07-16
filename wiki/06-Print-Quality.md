# 6. Print-quality tuning

Do this only after Eddy-NG probing and the first layer are stable.

## Input shaper

Measure resonances using the [Klipper resonance compensation guide](https://www.klipper3d.org/Resonance_Compensation.html). Recorded Max results were approximately X `42.6 Hz` and Y `38.0 Hz`. These are not defaults for every machine.

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
