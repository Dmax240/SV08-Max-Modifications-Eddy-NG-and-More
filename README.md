# SV08 Max Modifications: Eddy-NG and More

## Community documentation

I spent the past few days exhausting all my AI credits and totally changing the printer into something custom and perfect. here is everything i did documented. some of it is useless, some useful, but its worth sharing so others dont duplicate work. Yes, in the process I unneccessarilly wasted time figuring out things others have already figured out. This is hugely possibly because of all of you, and developers such as Roar Ree and others. i tried to give credit everytime everywhere but my apologies if i missed any citations. this is AI but its working perfect with no errors afters like 100 hrs of prints.

The step-by-step, GitHub/Wiki-ready guide is here:

- [SV08 Max Eddy NG guide home](wiki/Home.md)
- [Baseline and backups](wiki/01-Baseline-and-Backups.md)
- [Toolhead firmware and Katapult](wiki/02-Toolhead-Firmware.md)
- [Eddy NG configuration](wiki/03-Eddy-NG-Configuration.md)
- [Calibration sequence](wiki/04-Calibration.md)
- [Start sequence and cleaning macro](wiki/05-Start-Sequence.md)
- [Print-quality tuning](wiki/06-Print-Quality.md)
- [Troubleshooting](wiki/07-Troubleshooting.md)
- [TMC Autotune, motors, fans, and filament buffer](wiki/08-TMC-Fans-and-Buffer.md)
- [Touchscreen behavior and recovery lessons](wiki/10-Touchscreen-and-Recovery-Lessons.md)
- [Acknowledgements and source map](wiki/11-Acknowledgements-and-Sources.md)

These pages are **SV08 Max only**. They are written so they can be copied into a GitHub Wiki, while the links also work directly from the repository.

This repository is a field guide built from a real SV08 Max Eddy-NG conversion,
including the mistakes, recovery steps, configuration traps, and calibration
results that mattered. Recorded values are examples, not universal defaults.

This is the **SV08 Max**, not the standard Sovol SV08.  Do not copy motor,
travel or probing values from the standard SV08 without checking
compatibility first.

## What was changed

The scripts are intentionally beginner-friendly and verbose:

- Adjustable values are grouped near the top and explained beside their use.
- The monitor prints numbered stages, individual results, state changes, and a
  visible countdown before the next check.
- The nozzle macro prints a message before and after each major Klipper stage.
- Safety-sensitive heights are called out clearly because smaller Z values move
  closer to the brush or bed.

## Thanks

This guide exists because open-source maintainers and community members shared
their work. Special thanks to Vladimir Vukicevic and the `vvuk/eddy-ng`
contributors; Roar Ree (3DPrintDemon); bearclaw92; Rappetor; Andrew
(`andrewmcgr`); the Klipper, Katapult, BIGTREETECH, and Sovol teams;
and the r/Sovol, r/SovolSV08, r/SovolSV08Max, and r/klippers communities. See
the [full acknowledgements and source map](wiki/11-Acknowledgements-and-Sources.md)
for exactly where each project informed this guide.

Current observed baseline:

- `ping` responds successfully
- `http://YOUR_PRINTER_IP/` returns `200 OK`
- `https://YOUR_PRINTER_IP/` is not listening on port `443`

## Privacy

Personal names, usernames, passwords, device addresses, serial numbers, CAN
UUIDs, and local paths are replaced with descriptive placeholders such as
`YOUR_PRINTER_IP` and `YOUR_TOOLHEAD_CAN_UUID`. Replace them with values read
from your own machine. Never copy another printer's MCU UUID.

## Included examples

- `monitor_eddy_ng.sh`: continuous monitor with staged console output
- `examples/eddy-ng-reference.cfg`: annotated Eddy-NG configuration outline
- `examples/tmc-autotune-reference.cfg`: Max-specific motor references
- `examples/cleaning-height-tested-change.cfg`: tested mechanical/macro change

## Run the monitor

```bash
chmod +x monitor_eddy_ng.sh
./monitor_eddy_ng.sh
```

The monitor does not change printer settings.  It only checks reachability and
the HTTP page, then waits and repeats.  Press `Control+C` to stop it.

Optional environment variables:

- `INTERVAL_SECONDS=30`
- `HTTP_URL=http://YOUR_PRINTER_IP/`
- `EXPECTED_HTTP_CODE=200`
- `LOG_DIR=./logs`

To change a value for one run, put it before the command.  For example, this
checks every 10 seconds:

```bash
INTERVAL_SECONDS=10 ./monitor_eddy_ng.sh
```

To use a different printer address, provide it as the first argument:

```bash
./monitor_eddy_ng.sh YOUR_PRINTER_IP
```

## States

- `healthy`: ping succeeds and HTTP returns the expected status code
- `degraded`: ping succeeds but HTTP is unreachable or returns a different code
- `down`: ping fails

## Cleaning macro status

The newest cleaning change was tested successfully on the documented machine.
The cleaning surface was raised with four identical washers and the active
relative cleaning move was changed to `G1 Z-5.325`. This is a proven result on
that physical stack-up, not a universal Z value. See the measured-change file
and reproduce the washer height before copying the motion value.

1. Make a dated backup of the printer's current `Macro.cfg`.
2. Confirm that the X/Y brush and bed coordinates match this SV08 Max.
3. Review the four values marked as adjustable in the macro.
4. Paste/include the macro using the printer's normal Klipper configuration
   workflow.
5. Restart Klipper and confirm that the printer returns to `Ready`.
6. Run the first cleaning cycle while watching the printer and console.

You can override the macro's adjustable values for a supervised test without
editing the file:

```text
CLEAN_NOZZLE CLEAN_TEMP=200 COOL_TEMP=130 BRUSH_Z=0.79 BED_RUB_Z=0.05
```

Do not lower `BRUSH_Z` or `BED_RUB_Z` casually.  A smaller number moves the
nozzle closer to the contact surface.  Change one value at a time and test a
small first-layer patch afterward.

## Important safety boundary

Firmware flashing, driver-current changes, probing calibration, and supervised
motion tests can damage hardware. Back up first, change one thing at a time,
and verify Klipper is `Ready` after every restart.
