# 2. Toolhead firmware and Katapult

This procedure depends on the [Katapult bootloader](https://github.com/Arksine/katapult),
the official [Sovol SV08 Max files](https://github.com/Sovol3d/SV08MAX), and
community CAN/Katapult groundwork documented by
[bearclaw92](https://github.com/bearclaw92/Zero_Toolhead_Guide) and
[Rappetor](https://github.com/Rappetor/Sovol-SV08-Mainline). Their projects do
not claim these exact Max steps; this guide adapted and verified the relevant
ideas on an SV08 Max.

The documented SV08 Max toolhead used Katapult with the Klipper application beginning at `0x08002000`.

If the terms on this page are unfamiliar, stop and use the
[beginner walkthrough](00-Beginner-Walkthrough.md). It includes the full-backup
size check, where commands are entered, and green checkpoints.

## Build settings

The important settings were:

```ini
CONFIG_FLASH_APPLICATION_ADDRESS=0x8002000
CONFIG_STM32_FLASH_START_2000=y
```

A direct `0x08000000` image is not the same layout. Do not flash an image until the bootloader and application address are confirmed.

Check the saved Klipper build configuration:

```bash
grep -E 'CONFIG_MCU=|CONFIG_FLASH_APPLICATION_ADDRESS=|CONFIG_STM32_FLASH_START_2000=|CONFIG_CANBUS_FREQUENCY=' ~/klipper/.config
```

Expected layout for the documented board:

```text
CONFIG_MCU="stm32f103xe"
CONFIG_FLASH_APPLICATION_ADDRESS=0x8002000
CONFIG_STM32_FLASH_START_2000=y
CONFIG_CANBUS_FREQUENCY=1000000
```

Build and verify the artifact:

```bash
cd ~/klipper
make clean
make
ls -lh ~/klipper/out/klipper.bin
sha256sum ~/klipper/out/klipper.bin
```

Expected result: `klipper.bin` exists and has a nonzero size. Record its exact
size and SHA-256. The build log alone is not verification.

## ST-Link application programming boundary

When using ST-Link to preserve the existing 8 KiB Katapult bootloader, program
the verified Klipper binary at `0x08002000`. Do not perform a full-chip erase
and do not start the application binary at `0x08000000`. The complete original
128 KiB backup must already exist before this operation.

After programming, disconnect ST-Link, restore normal printer wiring,
power-cycle, and confirm the toolhead MCU returns before attempting Z motion.

## Safe sequence

1. Save the current build configuration and current firmware image.
2. Confirm the ST-Link recovery backup exists and is readable.
3. Build the image with the confirmed offset.
4. Verify the real binary’s filename, size, and SHA-256.
5. Stop Klipper before flashing.
6. Confirm `can0` is configured for 1 Mbps and has no bus errors.
7. Use a Katapult-aware method. If the helper tries to jump from an application that is already in Katapult, use the direct Katapult path.
8. Confirm the toolhead MCU returns on CAN.
9. Restart Klipper and confirm `Ready`.

## Stop conditions

Stop immediately if the toolhead disappears, the address is uncertain, the CAN bus reports errors, or the backup is missing. Repeating flash attempts without a confirmed layout can make recovery harder.

## Failure that is easy to misread

The factory helper first sends an application-to-bootloader jump. If the MCU
is already running Katapult, that extra jump can lead to:

```text
FlashError: Error sending command [CONNECT] to Device
FlashError: Error sending command [COMPLETE] to Device
```

First query the bus and inspect what is actually running:

```bash
python3 ~/printer_data/build/flash_can.py -i can0 -q
ip -details -statistics link show can0
```

If the query reports `Application: Katapult`, do not repeatedly send jump
commands. Confirm the current upstream Katapult flashing procedure or use
ST-Link recovery. Never invent a modified flasher without understanding the
CAN node-ID sequence.

Example placeholders:

```bash
sudo systemctl stop klipper
python3 ~/printer_data/build/flash_can.py -i can0 \
  -f ~/klipper/out/klipper.bin -u YOUR_TOOLHEAD_CAN_UUID
sudo systemctl start klipper
```

Replace `YOUR_TOOLHEAD_CAN_UUID` with the UUID reported by your own printer.
