# 2. Toolhead firmware and Katapult

The documented SV08 Max toolhead used Katapult with the Klipper application beginning at `0x08002000`.

## Build settings

The important settings were:

```ini
CONFIG_FLASH_APPLICATION_ADDRESS=0x8002000
CONFIG_STM32_FLASH_START_2000=y
```

A direct `0x08000000` image is not the same layout. Do not flash an image until the bootloader and application address are confirmed.

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
