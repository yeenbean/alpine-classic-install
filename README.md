**At this time, this script has only found success with the aarch64 variant of
Alpine Linux. armhf failed entirely and armv7 has not been tested. Your mileage
may vary. Please do not use this in production.**

# alpine-sys-install
Simple script for installing Alpine in sys mode on a Raspberry Pi

*This README file will be updated with a better explanation once the script reaches a working state.*

## SD Card Preparation

### Formatting

Using Rufus, wipe the card and create an empty FAT32 partition. This script only
accounts for the FAT partition starting at sector 2048 so **you must use Rufus
for the time being** to accurately format the card. Alternatively, you can use
`fdisk` and manually create a FAT32 LBA partition starting at 2048 and format it
with `mkfs.vfat`.

### Prepping Alpine

Download the RPi archive of Alpine. Make sure you grab the version that is
correct for your board's architecture. Extract the archive directly to the SD
card--no need to use Etcher! Refer to Alpine's Wiki for more information.

## Usage Instructions

Online instructions will come soon.

For an offline installation, use the following guide:

1. Copy `install.sh` to the root of the SD card, where the Alpine archive was
extracted.
1. Eject the SD card and insert it into your Raspberry Pi.
1. Power it on and get a keyboard ready. Login as root (no password).
1. Execute `/media/mmcblk0p1/install.sh`. The Raspberry Pi will reboot.
1. Login and execute `/media/mmcblk0p1/install.sh` again. The script will begin
installation of the system and will reboot once finished. *You can safely ignore
the warning about syslinux missing.*

At this stage, Alpine is installed in a persistent state. You may have to run
`setup-interfaces` to get networking up. If you plan on using the Wi-Fi module
on compatible boards, you will need to add wpa_supplicant to the boot process:

```
# rc-update add wpa_supplicant boot
```