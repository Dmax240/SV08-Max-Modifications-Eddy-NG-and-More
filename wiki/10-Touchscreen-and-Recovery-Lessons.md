# 10. Touchscreen behavior and recovery lessons

Special thanks to **Roar Ree (3DPrintDemon)** for extensive Sovol/Klipper
community work and the [Demon Klipper Essentials Unified
project](https://github.com/3DPrintDemon/Demon_Klipper_Essentials_Unified).
That ecosystem and Roar's shared experience helped frame the touchscreen,
macro, and recovery work recorded here. The local touchscreen behavior change
described below is a separate field modification; this guide does not claim it
as an upstream DKEU patch.

## Blocking “Sure” messages

The factory touchscreen displayed routine `!!` responses as blocking “Sure”
dialogs. A dialog could remain onscreen and prevent OrcaSlicer or Mainsail from
starting a print until manually dismissed. The UI was rebuilt so routine
responses did not create blocking modals while genuine dangerous operations
still required confirmation.

This was a touchscreen source/build change, not a Klipper motion macro. Do not
paper over the problem by adding macros that automatically acknowledge every
warning; doing so can hide real shutdowns.

## What the fix must preserve

The goal is not to suppress Klipper errors. It is to stop routine console
responses from owning a modal dialog that blocks the touchscreen's command
path. The corrected UI behavior must:

1. Continue displaying the message in a non-blocking notification/history
   area.
2. Release the command/communication state immediately after displaying it.
3. Allow Mainsail, Moonraker, and OrcaSlicer to submit work while the message
   remains visible.
4. Keep confirmations for genuinely destructive actions such as shutdown,
   restart, factory reset, or emergency operations.
5. Avoid replaying stale `ACCEPT`, `ABORT`, or `Sure` actions after the Klipper
   helper that created the message has already ended.

## Reproducing the source change

The exact touchscreen source filename varies by Sovol image/UI release, so do
not apply a guessed filename. On a backed-up source tree:

```bash
rg -n 'Sure|sure|modal|dialog|!!|confirm' .
```

Trace the handler that receives Moonraker/Klipper `!!` or response messages.
The unsafe pattern is conceptually:

```text
every !! response -> open blocking confirmation -> hold UI/command state
```

The intended pattern is:

```text
routine response -> non-blocking notification -> command state remains free
dangerous local action -> blocking confirmation
```

Keep the response visible if desired, but decouple visibility from the lock or
pending-confirmation flag. Do not globally convert every modal into a toast.

## Build and verification checklist

1. Make a complete copy of the original touchscreen source and built assets.
2. Change only the response-to-dialog routing and pending-confirmation cleanup.
3. Rebuild using the same toolchain/version as the factory UI.
4. Inspect the produced files rather than trusting the build log.
5. Install with a rollback copy available.
6. Trigger a harmless routine `!!` response and leave it visible.
7. While it remains visible, send a harmless command from Mainsail.
8. Confirm OrcaSlicer can upload/select a file without touching `Sure`.
9. Confirm shutdown/restart still asks for confirmation.
10. Reboot the screen and printer, then repeat the communication test.

The documented machine passed the functional goal: routine messages no longer
locked out external print submission. The patched source tree was not included
in this repository, so this page records the behavior, search method, safety
boundary, and verification procedure without inventing a version-specific
filename or patch.

## Recovery lessons from this conversion

- A successful build log is not proof of a safe firmware artifact. Verify the
  binary, application offset, size, and SHA-256.
- An 8 KiB ST-Link export is not a full 128 KiB MCU backup.
- `Application: Katapult` means the bootloader is already running; repeated
  jump commands can make flashing diagnostics misleading.
- Do not place manual config beneath Klipper's generated `SAVE_CONFIG` header.
- Do not change probe target, live Z, cleaning height, mesh, flow, and pressure
  advance together. Make one change and test one small patch.
- A cancel-time `Nozzle not hot enough` message may be a retract safety result,
  not the original print failure.
- A reported fix is not complete until the live configuration and `Ready`
  state are verified.
