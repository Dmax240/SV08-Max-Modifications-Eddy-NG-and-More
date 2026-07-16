# 0. Beginner walkthrough: start here

This page is the shortest safe path through the project. It assumes you have
never used SSH, compiled Klipper, queried CAN, or edited a generated Klipper
configuration.

Do not skip a green checkpoint. If your result does not match the expected
result, stop on that step and use the linked troubleshooting entry. Do not keep
typing later commands and hope the problem fixes itself.

## What this guide changes

The stock SV08 Max toolhead already contains an LDC1612 inductive sensor. This
project installs Eddy-NG support in Klipper, builds compatible toolhead
firmware, and configures that existing sensor for coarse homing, accurate
contact tapping, QGL, and rapid bed meshing.

It does **not** turn a standard SV08 into an SV08 Max. It does not install a
BTT Eddy. It does not provide a universal Z offset or a calibration model.

## The two places where commands are entered

| A guide says | Where to type it |
| --- | --- |
| **SSH terminal** | A Terminal window connected to the printer |
| **Mainsail Console** | Mainsail → Dashboard → Console → `Send code...` |

Never type Linux commands such as `cd`, `grep`, or `sudo` into Mainsail.
Never type Klipper commands such as `G28` or `SAVE_CONFIG` into the SSH shell.

## Words used in this guide

- **Host**: the Linux computer inside the printer.
- **MCU**: a microcontroller that runs Klipper firmware.
- **Toolhead MCU / `extra_mcu`**: the board beside the extruder and LDC1612.
- **CAN UUID**: the 12-character address that identifies one MCU on CAN.
- **Katapult**: the small bootloader stored at the beginning of toolhead flash.
- **Application offset**: where the Klipper application begins after Katapult.
- **Eddy-NG model**: calibration data measured from your own sensor and plate.
- **`SAVE_CONFIG` boundary**: the generated block at the bottom of
  `printer.cfg`. Manual sections never go below it.

## Before touching the printer

You need:

- A Sovol **SV08 Max**, powered and reachable on the same network as your PC.
- The printer's IP address, shown here as `YOUR_PRINTER_IP`.
- A spring-steel build plate installed on the bed.
- An ST-Link and four correctly identified SWD connections available for
  recovery before any toolhead flash.
- STM32CubeProgrammer installed if you may need to flash or recover the board.
- A clean nozzle, a sheet of ordinary printer paper, and access to emergency
  stop or printer power during first motion.

If you do not have a complete 128 KiB toolhead backup, do not flash yet.

---

## Step 1 — Prove the printer is healthy before changing it

Open Mainsail at:

```text
http://YOUR_PRINTER_IP/
```

Expected result: the top of Mainsail shows **Ready**.

Stop if it shows `Error`, `Shutdown`, or `Disconnected`. Record the complete
existing error and repair that baseline first.

### Connect an SSH terminal

On macOS or Linux, open Terminal and type:

```bash
ssh YOUR_PRINTER_USERNAME@YOUR_PRINTER_IP
```

Type the printer password when prompted. The password will not be displayed.

Expected result: the prompt changes to something similar to:

```text
YOUR_PRINTER_USERNAME@PRINTER:~$
```

Everything through Step 6 marked **SSH terminal** is typed in this window.

---

## Step 2 — Make a dated configuration backup

In the **SSH terminal**:

```bash
BACKUP="$HOME/printer-config-backup-$(date +%Y%m%d-%H%M%S)"
cp -a "$HOME/printer_data/config" "$BACKUP"
printf 'Backup created at: %s\n' "$BACKUP"
```

Expected result: one path ending in a date and time is printed.

Confirm the important files exist inside it:

```bash
find "$BACKUP" -maxdepth 1 -type f -print | sort
```

You should see `printer.cfg` and the macro files used by your printer. Copy
this entire backup off the printer before firmware work. Do not rename it to
`config` and do not edit it.

### Check the generated boundary now

```bash
grep -n 'SAVE_CONFIG' ~/printer_data/config/printer.cfg
```

Expected result: zero or one generated header. More than one means the current
file is already damaged; stop and repair it before continuing.

---

## Step 3 — Make a complete ST-Link recovery backup

Skip this step only if you already possess a verified **131,072-byte** backup
from this exact toolhead MCU.

1. Power the printer off.
2. Connect ST-Link `SWDIO`, `SWCLK`, `GND`, and the correct target voltage
   reference to the labelled toolhead SWD pads. Verify the board pinout before
   applying power. Do not guess by wire color.
3. Open STM32CubeProgrammer and select **ST-LINK** with **SWD**.
4. Connect at a low frequency such as 100 kHz if the default fails.
5. Confirm the target is an STM32F101/F102/F103 family device with **128 KB**
   flash.
6. In Device Memory, set address `0x08000000` and size `0x20000`.
7. Read the complete range and save it as a `.bin` file.

On your Mac, verify the saved file in Terminal:

```bash
wc -c "/path/to/YOUR_TOOLHEAD_FULL_BACKUP.bin"
shasum -a 256 "/path/to/YOUR_TOOLHEAD_FULL_BACKUP.bin"
```

Expected size:

```text
131072
```

An 8 KiB or 8192-byte file is only the displayed bootloader region. It is not
a full recovery backup. Do not erase flash or alter option bytes.

Disconnect ST-Link before returning to normal printer power unless your exact
programmer and wiring procedure explicitly requires it to remain attached.

---

## Step 4 — Record all CAN UUIDs before flashing

Boot the printer normally. In the **SSH terminal**:

```bash
grep -Rns '^[[:space:]]*canbus_uuid:' ~/printer_data/config
```

Copy the active main, toolhead/extra, and buffer UUIDs into a private note.
Never publish them and never copy UUIDs from this repository.

To query unassigned Klipper nodes safely:

```bash
sudo systemctl stop klipper
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
sudo systemctl start klipper
```

Expected result may be zero UUIDs when all healthy nodes already have IDs.
That is not proof a board is missing. The active configuration remains the
authoritative record of its assigned UUIDs.

Confirm Mainsail returns to **Ready** before continuing.

---

## Step 5 — Install Eddy-NG on the host

These are the current official upstream installation commands. In the
**SSH terminal**:

```bash
cd ~
git clone https://github.com/vvuk/eddy-ng
cd ~/eddy-ng
./install.sh
```

If `~/eddy-ng` already exists, update instead:

```bash
cd ~/eddy-ng
git pull
./install.sh
```

Expected result: the installer links or installs the Eddy-NG MCU and Klipper
files and finishes without an error.

Recommended diagnostic packages from upstream:

```bash
~/klippy-env/bin/pip3 install plotly==5.24.1 scipy
```

Plotly newer than 5.24.1 is not recommended by the current Eddy-NG Wiki.

This beginner sequence was cross-checked on July 16, 2026 against Eddy-NG
source commit `1ed056b` and Wiki commit `ade8664`. If upstream changes later,
follow its current installation and calibration pages and open an issue here
so this walkthrough can be updated.

Do not restart and print yet. Eddy-NG support must also be compiled into the
toolhead firmware.

---

## Step 6 — Build the correct toolhead firmware

In the **SSH terminal**:

```bash
cd ~/klipper
make menuconfig
```

Select the SV08 Max toolhead values that produce:

```text
Micro-controller Architecture: STMicroelectronics STM32
Processor model: STM32F103
Bootloader offset: 8KiB bootloader
Clock Reference: 8 MHz crystal
Communication interface: CAN bus
CAN bus speed: 1000000
```

Enable the Eddy-NG/LDC1612 firmware support installed by Eddy-NG when the menu
offers it. Save and exit.

Verify the saved configuration:

```bash
grep -E 'CONFIG_MCU=|CONFIG_FLASH_APPLICATION_ADDRESS=|CONFIG_STM32_FLASH_START_2000=|CONFIG_CANBUS_FREQUENCY=' ~/klipper/.config
```

For the documented Max toolhead, the important lines are:

```text
CONFIG_MCU="stm32f103xe"
CONFIG_FLASH_APPLICATION_ADDRESS=0x8002000
CONFIG_STM32_FLASH_START_2000=y
CONFIG_CANBUS_FREQUENCY=1000000
```

Stop if the application address is `0x8000000`. That would place Klipper over
Katapult instead of after its 8 KiB region.

Build and verify the actual file:

```bash
cd ~/klipper
make clean
make
ls -lh ~/klipper/out/klipper.bin
sha256sum ~/klipper/out/klipper.bin
```

Expected result: `out/klipper.bin` exists, is nonzero, and has a SHA-256 value.
Save the size and hash in your notes.

---

## Step 7 — Flash only with a proven recovery path

This is the highest-risk step. Read [Toolhead firmware and
Katapult](02-Toolhead-Firmware.md) completely before choosing CAN or ST-Link.

### Do not flash when

- The full 128 KiB backup is missing.
- The build does not show `0x8002000`.
- CAN is not `ERROR-ACTIVE` at 1,000,000 bit/s with zero bus errors.
- You are unsure which UUID belongs to the toolhead.
- The board pinout or ST-Link wiring is uncertain.

If the toolhead is already in Katapult and an old Sovol helper repeatedly
fails at `CONNECT`, do not loop the same command. Use the supported upstream
Katapult flow or program the verified application through ST-Link at
`0x08002000`, preserving the bootloader at `0x08000000`–`0x08001fff`.

After flashing, disconnect ST-Link, restore normal wiring, power-cycle the
printer, and confirm the toolhead MCU reconnects. Mainsail may show a config
error until Eddy-NG configuration is installed; it must not report a missing
toolhead MCU.

---

## Step 8 — Stage the community configuration without losing recovery

In the **SSH terminal**:

```bash
cd ~
git clone https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More.git sv08max-eddy-guide
cd ~/sv08max-eddy-guide
grep -Rns 'YOUR_' config
```

Expected result: only the three CAN UUID placeholders are listed.

Open the repository's `config/printer.cfg`, `config/eddy_ng.cfg`,
`config/macros.cfg`, `config/runout_only.cfg`, and optional
`config/tmc_autotune.cfg` in a text editor. Replace:

- `YOUR_MAIN_MCU_CAN_UUID`
- `YOUR_TOOLHEAD_CAN_UUID`
- `YOUR_BUFFER_MCU_CAN_UUID`

For example, in the SSH terminal:

```bash
nano ~/sv08max-eddy-guide/config/printer.cfg
nano ~/sv08max-eddy-guide/config/runout_only.cfg
```

In `nano`, use the arrow keys, save with `Control+O`, press `Return` to confirm
the filename, and exit with `Control+X`.

Do not copy another machine's generated Eddy model, mesh, PID, shaper, or Z
offset. Do not place any manual section below a generated `SAVE_CONFIG` line.

Before activation, read [the bundle README](https://github.com/Dmax240/SV08-Max-Modifications-Eddy-NG-and-More/blob/main/config/README.md).
> **Important:** the complete bundle matches the documented modified machine,
> whose auxiliary feeder was gutted. It intentionally replaces that feeder
> with runout-only behavior. If your stock feeder is intact and wanted, do not
> activate the complete bundle. Keep your backed-up buffer configuration and
> merge only the Eddy-NG sections after comparing names and includes. Loading
> both buffer implementations creates duplicate sections.

### Activate the staged files

Confirm the Step 2 backup path still exists. Then:

```bash
cp ~/sv08max-eddy-guide/config/printer.cfg ~/printer_data/config/printer.cfg
cp ~/sv08max-eddy-guide/config/eddy_ng.cfg ~/printer_data/config/eddy_ng.cfg
cp ~/sv08max-eddy-guide/config/macros.cfg ~/printer_data/config/macros.cfg
cp ~/sv08max-eddy-guide/config/runout_only.cfg ~/printer_data/config/runout_only.cfg
test -e ~/printer_data/config/saved_variables.cfg || cp ~/sv08max-eddy-guide/config/saved_variables.cfg ~/printer_data/config/saved_variables.cfg
```

The last command creates `saved_variables.cfg` only when it does not already
exist. Never replace an existing persistent-variable file just to make it
match this repository.

If TMC Autotune is already installed, also copy:

```bash
cp ~/sv08max-eddy-guide/config/tmc_autotune.cfg ~/printer_data/config/tmc_autotune.cfg
```

If TMC Autotune is not installed, comment out this line in the new
`printer.cfg` before restart:

```ini
#[include tmc_autotune.cfg]
```

Check for forgotten placeholders:

```bash
grep -Rns 'YOUR_' ~/printer_data/config/*.cfg
```

Expected result: no output.

Restart from the **Mainsail Console**:

```text
RESTART
```

Expected result: Mainsail shows **Ready**. If not, do not edit randomly. Copy
the exact first error and use [the beginner failure map](09-Beginner-Failure-Map.md).

---

## Step 9 — Verify sensor communication before moving Z

In the **Mainsail Console**, run this two or three times:

```text
PROBE_EDDY_NG_STATUS
```

Before calibration, a normal response contains a changing coil value and may
say `Not calibrated`. A response such as `0xffffffff` indicates a sensor/I2C
communication problem. Stop and check firmware, `i2c_mcu`, `i2c_bus`, and the
toolhead connection.

Do not home Z until status returns real readings.

---

## Step 10 — Run automatic Eddy-NG setup

Install the spring-steel plate. Remove tools and debris from the bed. Heat the
bed to 50–60 °C.

In the **Mainsail Console**:

```text
G28 X Y
G90
G0 X271 Y251 F9000
PROBE_EDDY_NG_SETUP
```

Follow the paper-test controls shown by Mainsail. The goal is ordinary paper
friction; this setup paper test does not need micron-level perfection.

Expected result: Eddy-NG searches for working parameters and reports a
successful calibration. If automatic setup fails, stop and follow the manual
calibration branch on [page 4](04-Calibration.md). Do not assume drive current
15 is correct merely because it worked on the documented printer.

Do **not** run `SAVE_CONFIG` yet.

---

## Step 11 — Test static probing and supervised Z homing

In the **Mainsail Console**:

```text
PROBE_EDDY_NG_PROBE_STATIC
```

Expected result: a plausible height, not an I2C/sensor error.

With a hand on emergency stop, run:

```text
G28 Z
```

The nozzle must stop above the plate. If it keeps descending, stop the printer
immediately.

Move to 2 mm and check the reading:

```text
G90
G0 Z2 F600
PROBE_EDDY_NG_PROBE_STATIC
```

Expected result: approximately 2.0 mm, normally within about ±0.025 mm in the
most accurate range according to upstream Eddy-NG guidance.

Only after these tests pass:

```text
SAVE_CONFIG
```

Wait for Klipper to restart and confirm **Ready**.

---

## Step 12 — Verify QGL, tapping, and mesh in that order

Run one command at a time in the **Mainsail Console**. Watch every motion.

```text
G28
QUAD_GANTRY_LEVEL
G28 Z
```

Expected result: QGL completes and the printer remains `Ready`.

Clean and warm the nozzle exactly as your start macro requires. Then:

```text
PROBE_EDDY_NG_TAP SAMPLES=1 TARGET_Z=-0.100
```

This conservative first test reduces contact travel. If it succeeds, follow
[the tap tuning page](04-Calibration.md) before using the documented
`tap_target_z: -0.40`; that value is specific to one Max.

After repeatable tap success:

```text
BED_MESH_CALIBRATE METHOD=rapid_scan
```

Expected result: a completed mesh without sensor errors.

---

## Step 13 — Run the first real print safely

1. Verify the nozzle is clean.
2. Run the complete start sequence under supervision.
3. Keep emergency stop available during cleaning, QGL, tap, and the first
   mesh.
4. Print a small single-layer patch, not a long model.
5. Change only one first-layer variable at a time.
6. Do not copy the historical `tap_adjust_z: 0.170`; it was superseded.

Once the first layer repeats after both a cold start and a warm restart, move
on to [print-quality tuning](06-Print-Quality.md).

## You are finished when all boxes are true

- [ ] Mainsail returns to `Ready` after restart.
- [ ] `PROBE_EDDY_NG_STATUS` returns real coil values.
- [ ] Static probing reports plausible heights.
- [ ] Supervised `G28 Z` stops safely.
- [ ] QGL completes.
- [ ] Tap completes repeatedly with a clean nozzle.
- [ ] Rapid bed mesh completes.
- [ ] A small first-layer patch is repeatable cold and warm.
- [ ] The original config backup and full 128 KiB ST-Link backup exist off the
      printer.

If any box is false, the conversion is not finished. Use the
[beginner failure map](09-Beginner-Failure-Map.md) instead of changing several
settings at once.
