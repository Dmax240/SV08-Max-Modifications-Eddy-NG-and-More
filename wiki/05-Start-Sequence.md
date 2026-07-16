# 5. Cleaning macro and print start

The start sequence must match Eddy-NG behavior. A working probe can still fail when an old macro calls an unsupported command.

## Recommended order

1. Heat as required.
2. Home X/Y/Z.
3. Run QGL.
4. Home Z again.
5. Clean the nozzle.
6. Run Eddy tap.
7. Create the adaptive mesh.
8. Begin the print only after all checks pass.

## Remove unsupported behavior

`RUN_PROBE_VIR_CONTACT` is unsupported with Eddy-NG. Remove it from the cleaning path and use explicit, supervised Z motion instead.

The documented Max cleaning test used values near:

```text
CLEAN_NOZZLE CLEAN_TEMP=200 COOL_TEMP=130 BRUSH_Z=0.79 BED_RUB_Z=0.05
```

Treat these as starting values for this documented Max—not universal settings. A smaller Z value moves the nozzle closer to the brush or bed. Test while watching the machine.

## Recovery after a macro edit

1. Restart Klipper.
2. Confirm `Ready`.
3. Run the macro with the toolhead supervised.
4. Test a small first-layer patch.
5. Record the exact values and result.
