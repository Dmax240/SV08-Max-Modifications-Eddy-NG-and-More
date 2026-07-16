# Sovol SV08 Max · Eddy NG

> Community field guide for getting **Eddy NG working on the Sovol SV08 Max**.
>
> **This is SV08 Max documentation only.** Do not copy plain SV08 geometry, motor values, or travel limits into an SV08 Max configuration—or the other way around.

## Start here

1. [Compatibility and recovery checklist](01-Baseline-and-Backups.md)
2. [Toolhead firmware and Katapult layout](02-Toolhead-Firmware.md)
3. [Eddy NG configuration](03-Eddy-NG-Configuration.md)
4. [Calibration sequence](04-Calibration.md)
5. [Cleaning macro and print-start sequence](05-Start-Sequence.md)
6. [Print-quality tuning](06-Print-Quality.md)
7. [Troubleshooting](07-Troubleshooting.md)
8. [TMC Autotune, motors, fans, and buffer](08-TMC-Fans-and-Buffer.md)
9. [Touchscreen behavior and recovery lessons](10-Touchscreen-and-Recovery-Lessons.md)
10. [Acknowledgements and source map](11-Acknowledgements-and-Sources.md)

## The rule that keeps this project recoverable

Make one change, save a dated backup, restart Klipper, confirm `Ready`, and record the result before making the next change.

## What this guide records

- Katapult toolhead application address: `0x08002000`
- Eddy-NG toolhead offsets: X `-19.8`, Y `-0.75`
- Eddy-NG tap target used during the documented Max calibration: `-0.40`
- Recorded drive/tap current: `15`
- Latest recorded Max resonance results: X MZV `49.8 Hz`, Y MZV `34.2 Hz`
- Recorded hotend PID at 250 °C: Kp `37.537`, Ki `5.820`, Kd `60.526`

These are recorded results from one SV08 Max setup, not universal values. Verify them against the exact hardware in front of you.

## Privacy convention

Descriptive placeholders such as `YOUR_PRINTER_IP`,
`YOUR_PRINTER_USERNAME`, and `YOUR_TOOLHEAD_CAN_UUID` mark information that
must come from your own printer.

## Primary references

- [Eddy-NG by vvuk and contributors](https://github.com/vvuk/eddy-ng)
- [BIGTREETECH Eddy documentation](https://github.com/bigtreetech/Eddy)
- [Sovol SV08 Max repository](https://github.com/Sovol3d/SV08MAX)
- [Klipper configuration checks](https://www.klipper3d.org/Config_checks.html)
- [Klipper bed mesh](https://www.klipper3d.org/Bed_Mesh.html)
- [Klipper resonance compensation](https://www.klipper3d.org/Resonance_Compensation.html)
- [SV08 community discussion](https://www.reddit.com/r/Sovol/comments/1ffpupx)

This field guide builds on work by many people and projects. Read the
[acknowledgements and source map](11-Acknowledgements-and-Sources.md) before
redistributing excerpts.

## Safety boundary

Firmware flashing, wiring, driver-current changes, probing recalibration, and motor tuning can damage hardware. Back up first, supervise every motion test, keep an emergency stop ready, and verify Klipper returns to `Ready` after every restart.
