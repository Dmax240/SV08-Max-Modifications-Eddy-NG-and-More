# 4. Eddy NG calibration sequence

Do not change drive current, tap target, live Z, mesh, and pressure advance in one session. Each result must be observable.

## Gate A — drive current

Run the current calibration from the [BIGTREETECH Eddy guide](https://github.com/bigtreetech/Eddy). For the documented Max run, drive current and tap current were both saved at `15`.

Verify with:

```text
PROBE_EDDY_NG_CALIBRATION_STATUS
```

Recorded result: valid height range `0.004`–`4.999 mm`, frequency spread `1.84%`, fit `0.0043`.

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
