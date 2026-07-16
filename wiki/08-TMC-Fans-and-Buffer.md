# 8. TMC Autotune, motors, fans, and filament buffer

## TMC Autotune

[`klipper_tmc_autotune`](https://github.com/andrewmcgr/klipper_tmc_autotune),
maintained by Andrew (`andrewmcgr`) and its contributors, calculates deterministic TMC register settings at
Klipper startup from motor electrical constants. It does not randomly retune
the printer and does not replace `run_current`.

The Max-specific motors recorded during this project were:

| Axis | Motor | Recorded current |
| --- | --- | --- |
| X/Y | Shengyang `42BYGH3025-4M-25D` | 3.0 A |
| Z/Z1/Z2/Z3 | Shengyang `42BYGH2265-A-26DNT` | 1.2 A |
| Extruder | Shengyang `28BYGH2008-M-11bQ` | 0.8 A |

Do not substitute the standard SV08 Z-motor entry. The official Max config
uses 1.2 A on all four Z drivers; lowering them to 0.8 A caused poor behavior
on the documented machine.

See the cleaned [`config/tmc_autotune.cfg`](https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More/blob/main/config/tmc_autotune.cfg).

After installation, restart Klipper, confirm `Ready`, inspect the log for TMC
errors, and rerun input shaper because changed driver waveforms can alter the
measured resonance response.

## Filament buffer

The auxiliary feeder shredded filament on the documented printer and was
gutted. During troubleshooting, removing only `push_pin` broke configuration
loading. The old buffer implementation could be disabled while retaining its
required fields with:

```ini
variable_is_push_buffer: False
```

The final cleaned configuration instead removes the entire old buffer include
and loads [`runout_only.cfg`](https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More/blob/main/config/runout_only.cfg).
That file keeps the PA10 presence switch and omits the feeder motor, push-pin
jam logic, and feeder LEDs. Choose one approach; never load both.

Do not splice a BTT SFS V2.0 into the buffer's four-wire stepper connector.
The SFS needs supply, ground, runout signal, and a separate motion/encoder
signal connected to suitable GPIOs. Verify board voltage and pinout first.

## Fans

The bed-fan shutdown threshold was raised from 35 C to 45 C so it could stop
after cooldown at the user's normal 45 C bed setting. A fan still audible at
room temperature may be a directly powered PSU/electronics fan and cannot be
disabled by a Klipper fan macro. Identify the physical fan before rewiring or
adding relays.
