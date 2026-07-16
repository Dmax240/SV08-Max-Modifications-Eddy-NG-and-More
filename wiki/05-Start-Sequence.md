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

The proven macro heats to 200 °C for its first cleaning stage, cools to 130 °C,
and then performs the washer-raised textured-surface pass. These temperatures
and motion values appear directly in `config/macros.cfg`; the published macro
does not expose them as casual command-line adjustments.

Treat its geometry as specific to the documented Max. A more negative relative
Z move goes closer to the cleaning surface. Test while watching the machine.

## Recovery after a macro edit

1. Restart Klipper.
2. Confirm `Ready`.
3. Run the macro with the toolhead supervised.
4. Test a small first-layer patch.
5. Record the exact values and result.

## Tested second-stage cleaning correction

The second pass originally moved above the textured cleaning surface. The
tested correction combined a mechanical and macro change:

1. Raise the cleaning surface using four identical washers, one at each
   mounting point, so it remains level and supported.
2. Confirm the washer stack does not interfere with bed travel, wiring, or the
   nozzle path.
3. Back up the active macro.
4. In the active relative-motion cleaning stage, change the descent to:

   ```gcode
   G1 Z-5.325
   ```

5. Confirm this stage is actually in `G91` relative mode before using a
   negative Z move. The same line is dangerous in the wrong coordinate state.
6. Run the complete cleaning routine under supervision.
7. Confirm visible contact without nozzle/plate deflection, then verify a small
   first layer.

This exact washer-plus-`Z-5.325` combination was tested successfully on the
documented SV08 Max. Washer thickness and mounting tolerances can change the
required motion on another machine. Do not change global Z offset, Eddy
`tap_adjust_z`, or probe calibration to compensate for cleaning geometry.

See the tested implementation in [`config/macros.cfg`](https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More/blob/main/config/macros.cfg).
