# 4. Eddy NG calibration sequence

Do not change drive current, tap target, live Z, mesh, and pressure advance in one session. Each result must be observable.

## Gate A — automatic setup first

Current Eddy-NG documentation recommends automatic setup first. With the bed
at 50–60 °C, home X/Y, move over the center of the plate, and run:

```text
G28 X Y
G90
G0 X271 Y251 F9000
PROBE_EDDY_NG_SETUP
```

Follow the temporary paper-test helper. If setup succeeds, continue to the
static-probe and homing checks below. Do not force current 15 simply because it
worked on the documented toolhead.

## Gate B — manual drive-current calibration when setup fails

Use the manual flow from the
[Eddy-NG calibration documentation](https://github.com/vvuk/eddy-ng/wiki/Calibration)
only when automatic setup fails or a deliberate second drive current is
needed. Cross-check relevant hardware details with the
[BIGTREETECH Eddy guide](https://github.com/bigtreetech/Eddy). On the documented
Max, the resulting drive and tap current happened to be `15`.

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

Do not save immediately. First run:

```text
PROBE_EDDY_NG_PROBE_STATIC
```

Then perform a supervised `G28 Z`, move to Z=2 mm, and confirm another static
probe is close to 2.0 mm. Only after those checks pass, run `SAVE_CONFIG` and
verify status after Klipper restarts.

## Gate C — reading-to-height mapping

Complete the mapping procedure from the current Eddy-NG instructions. Do not assume the mapping from another printer or probe.

## Gate D — tap behavior

1. Heat and clean the nozzle as appropriate.
2. Confirm the bed and toolhead are clear.
3. Home only under supervision.
4. Begin with one conservative sample:

   ```text
   PROBE_EDDY_NG_TAP SAMPLES=1 TARGET_Z=-0.100
   ```

5. Run the normal Eddy tap test only after the conservative test works.
6. If it triggers too close to the target, change `tap_target_z` in a small, documented step.
7. Restart and repeat the test.

The documented Max correction changed the target from `-0.30` to `-0.40` after an early-trigger failure.

## Gate E — first layer

Run a small first-layer patch. Make one small live-Z change at a time. Do not persist a value until the patch is repeatable.

## Gate F — mesh

Create and save the mesh only after tap behavior and first-layer height are stable. Follow [Klipper bed mesh documentation](https://www.klipper3d.org/Bed_Mesh.html) for command behavior.

## Thermal consistency

Use the same nozzle/bed heat-soak state for calibration and first-layer tests.
An inductive coil can drift with temperature. If the installed Eddy-NG version
supports drift compensation, follow that version's calibration instructions;
do not copy coefficients from another probe.
