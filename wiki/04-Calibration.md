# 4. Eddy NG calibration sequence

Do not change drive current, tap target, live Z, mesh, and pressure advance in one session. Each result must be observable.

## Gate A — drive current

Run the current calibration from the
[Eddy-NG calibration documentation](https://github.com/vvuk/eddy-ng/wiki/Calibration)
and cross-check relevant hardware details with the
[BIGTREETECH Eddy guide](https://github.com/bigtreetech/Eddy). For the
documented Max run, drive current and tap current were both saved at `15`.

Verify with:

```text
PROBE_EDDY_NG_CALIBRATION_STATUS
```

Recorded result: valid height range `0.004`–`4.999 mm`, frequency spread `1.84%`, fit `0.0043`.

The documented command was:

```text
PROBE_EDDY_NG_CALIBRATE DRIVE_CURRENT=15 START_Z=5
```

Home X and Y first. `START_Z` must be above the minimum accepted by the
installed Eddy-NG version. During the manual stage, `TESTZ` and `ACCEPT` only
exist while the helper is active. `Unknown command: TESTZ`, `ACCEPT`, or
`ABORT` usually means the helper already ended or the UI replayed a stale
button command.

After Eddy reports that calibration was saved, run:

```text
SAVE_CONFIG
```

Then verify the calibration status after Klipper restarts.

## Gate B — reading-to-height mapping

Complete the mapping procedure from the current Eddy-NG instructions. Do not assume the mapping from another printer or probe.

## Gate C — tap behavior

1. Heat and clean the nozzle as appropriate.
2. Confirm the bed and toolhead are clear.
3. Home only under supervision.
4. Run the Eddy tap test.
5. If it triggers too close to the target, change `tap_target_z` in a small, documented step.
6. Restart and repeat the test.

The documented Max correction changed the target from `-0.30` to `-0.40` after an early-trigger failure.

## Gate D — first layer

Run a small first-layer patch. Make one small live-Z change at a time. Do not persist a value until the patch is repeatable.

## Gate E — mesh

Create and save the mesh only after tap behavior and first-layer height are stable. Follow [Klipper bed mesh documentation](https://www.klipper3d.org/Bed_Mesh.html) for command behavior.

## Thermal consistency

Use the same nozzle/bed heat-soak state for calibration and first-layer tests.
An inductive coil can drift with temperature. If the installed Eddy-NG version
supports drift compensation, follow that version's calibration instructions;
do not copy coefficients from another probe.
