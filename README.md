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
    -r|--root           : mounting point of root partition / dev path of root partition, default=/mnt
    -b|--boot           : boot partition, default=none
    -h|--home           : home partition, default=none
    -s|--swap           : swap partition, default=none
    -k|--kernel         : kernel to install, default=linux
    --luks-root         : root partition is encrypted with luks, default=NO
    --nvme              : installing to nvme drive, default=NO
artix-autoinstall-p2.sh
    --efi               : use efi/gpt boot, default=YES
    --secure            : implement secure boot with preloader, default=NO
    --efidrive          : source of mounted boot partition used for secure boot, default=/dev/sda
    --efipartnum        : partition number of efi partition, default=""
    -k|--kernel         : installed kernel, default=linux
    -b|--boot           : boot partition mount location, default=/dev/sda(mbr)|/boot(gpt)
    --ucode|--microcode : install microcode, accepted=intel|amd|"", default=""
    -u|--user           : name of a user to be added, default=user
    -n|--hostname       : hostname of the machine, default=artix-linux
    -w|--wireless       : install wpa_supplicant and use networkmanager instead of dhcpcd and connman, default=NO
```

`artix-autoinstall.sh` accepts all arguments listed above.

## todo

 * autodetection of nvme drives
 * luks encrypted drive support
