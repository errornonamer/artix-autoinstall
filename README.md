# errors-artix-autoinstall

artix linux autoinstall script for personal use\
does not partition drives automatically, has to be done manually before running\
uses OpenRC init and GRUB bootloader

## how to use

first, boot into live enviroment with artix image and get root\
partition the drives and mount them\
clone this repo and run `bash artix-autoinstall.sh` with correct argument\
reboot and configure the system however you like

## arguments

```
artix-autoinstall-p1.sh
    -a|--automount      : mount partitions automatically, default=NO
    -r|--root           : mounting point of root partition / path to root partition, default=/mnt
    -b|--boot           : boot partition, default=none
    -h|--home           : home partition, default=none
    -s|--swap           : swap partition, default=none
    -k|--kernel         : kernel to install, default=linux
    --luks              : enable drive encryption, default=NO
    --luks-root         : path to raw root partition (if it is encrypted with luks), default="none"
    --luks-swap         : path to raw swap partition (if it is encrypted with luks), default="none"
    --luks-autounlock   : make luks partitions auto unlock on boot using tpm, default=NO
    --nvme              : installing to nvme drive, default=NO
artix-autoinstall-p2.sh
    --efi               : use efi/gpt boot, default=YES
    --secure            : implement secure boot with preloader/shim/shim-key, default=NO
    --efidrive          : source of mounted boot partition used for secure boot, default=/dev/sda
    --efipartnum        : partition number of efi partition, default=""
    -k|--kernel         : installed kernel, default=linux
    -b|--boot           : boot partition mount location, default=/dev/sda(mbr)|/boot(gpt)
    --ucode|--microcode : install microcode, accepted=intel|amd|"", default=""
    --luks              : enable drive encryption, default=NO
    --luks-root         : path to raw root partition (if it is encrypted with luks), default="none"
    --luks-swap         : path to raw swap partition (if it is encrypted with luks), default="none"
    --luks-autounlock   : make luks partitions auto unlock on boot using tpm, default=NO
    -u|--user           : name of a user to be added, default=user
    -n|--hostname       : hostname of the machine, default=artix-linux
    -w|--wireless       : install wpa_supplicant and use networkmanager instead of dhcpcd and connman, default=NO
```

`artix-autoinstall.sh` accepts all arguments listed above.

## installed packages
 * base, base-devel, openrc, elogind-openrc, (kernel), linux-firmware - base system
 * cryptsetup, lvm2 (with --luks) - luks support
 * nano - text editor for locale file
 * intel-ucode / amd-ucode - cpu microcode
 * grub, os-prober - bootloader
 * efibootmgr - efi boot
 * git (with --secure) - for installing AUR package
 * preloader-signed / shim-signed (AUR, with --secure) - secure boot
 * wpa_supplicant, networkmanager-openrc / dhcpcd connman-openrc - network service

## todo

 * support other init systems
 * secrue boot using shim with key
 * better luks support
 * refactor the whole thing when i learn how to write proper shell script and not this horrible pasted garbage
