# Sovol SV08 Max Eddy NG Workspace

## Community documentation

The step-by-step, GitHub/Wiki-ready guide is here:

- [SV08 Max Eddy NG guide home](wiki/Home.md)
- [Baseline and backups](wiki/01-Baseline-and-Backups.md)
- [Toolhead firmware and Katapult](wiki/02-Toolhead-Firmware.md)
- [Eddy NG configuration](wiki/03-Eddy-NG-Configuration.md)
- [Calibration sequence](wiki/04-Calibration.md)
- [Start sequence and cleaning macro](wiki/05-Start-Sequence.md)
- [Print-quality tuning](wiki/06-Print-Quality.md)
- [Troubleshooting](wiki/07-Troubleshooting.md)

These pages are **SV08 Max only**. They are written so they can be copied into a GitHub Wiki, while the links also work directly from the repository.

This workspace contains the monitoring script, the verbose two-stage nozzle
cleaning macro, and OrcaSlicer profiles for the **Sovol SV08 Max** with
Eddy-NG and a 0.4 mm nozzle.

This is the **SV08 Max**, not the standard Sovol SV08.  Do not copy motor,
travel, probing, or profile values from the standard SV08 without checking
compatibility first.

## What was changed

The scripts are intentionally beginner-friendly and verbose:

- Adjustable values are grouped near the top and explained beside their use.
- The monitor prints numbered stages, individual results, state changes, and a
  visible countdown before the next check.
- The nozzle macro prints a message before and after each major Klipper stage.
- Safety-sensitive heights are called out clearly because smaller Z values move
  closer to the brush or bed.

Current observed baseline:

- `ping` responds successfully
- `http://***.***.***.***/` returns `200 OK`
- `https://***.***.***.***/` is not listening on port `443`

## Files

- `monitor_eddy_ng.sh`: continuous monitor with staged console output
- `logs/eddy-ng-monitor.log`: append-only activity log
- `logs/eddy-ng-monitor.state`: latest known state
- `sv08_two_stage_clean_macro.cfg`: verbose Klipper nozzle-clean macro
- `profiles/`: SV08 Max Eddy-NG OrcaSlicer profile bundle

## Run the monitor

```bash
chmod +x monitor_eddy_ng.sh
./monitor_eddy_ng.sh
```

The monitor does not change printer settings.  It only checks reachability and
the HTTP page, then waits and repeats.  Press `Control+C` to stop it.

Optional environment variables:

- `INTERVAL_SECONDS=30`
- `HTTP_URL=http://***.***.***.***/`
- `EXPECTED_HTTP_CODE=200`
- `LOG_DIR=./logs`

To change a value for one run, put it before the command.  For example, this
checks every 10 seconds:

```bash
INTERVAL_SECONDS=10 ./monitor_eddy_ng.sh
```

To use a different printer address, provide it as the first argument:

```bash
./monitor_eddy_ng.sh ***.***.***.***
```

## States

- `healthy`: ping succeeds and HTTP returns the expected status code
- `degraded`: ping succeeds but HTTP is unreachable or returns a different code
- `down`: ping fails

## Install and test the nozzle-clean macro

`sv08_two_stage_clean_macro.cfg` is a reference snippet.  Before putting it
on the printer:

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

This workspace documents and monitors the SV08 Max.  It does not authorize
firmware flashing, driver-current changes, probing recalibration, coding,
adaptations, or other risky printer changes.  Back up the live configuration
before making those changes and verify Klipper is `Ready` afterward.
