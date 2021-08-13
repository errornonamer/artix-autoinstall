#!/bin/bash
# boot options
EFI="YES"
SECURE="NO"
EFI_DRIVE="/dev/sda"
EFI_PART_NUM=""
KERNEL="linux"
MBR_BOOT_DEVICE="/dev/sda"
EFI_BOOT_PARTITION="/boot"
MICROCODE="none"
LUKS_ROOT="NO"

# configuration options
USER="user"
HOSTNAME="artix-linux"
WIRELESS="NO"


# parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --efi)
            EFI="${2}"
            shift
            shift
            ;;
        --secure)
            SECURE="${2}"
            shift
            shift
            ;;
        --efidrive)
            EFI_DRIVE="${2}"
            shift
            shift
            ;;
        --efipartnum)
            EFI_PART_NUM="${2}"
            shift
            shift
            ;;
        -k|--kernel)
            KERNEL="${2}"
            shift
            shift
            ;;
        -b|--boot)
            MBR_BOOT_DEVICE="${2}"
            EFI_BOOT_PARTITION="${2}"
            shift
            shift
            ;;
        --ucode|--microcode)
            MICROCODE="${2}"
            shift
            shift
            ;;
        --luks-root)
            LUKS_ROOT="$2"
            shift
            shift
            ;;
        -u|--user)
            USER="${2}"
            shift
            shift
            ;;
        -n|--hostname)
            HOSTNAME="${2}"
            shift
            shift
            ;;
        -w|--wireless)
            WIRELESS="${2}"
            shift
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "part 2 parsed arguments"
echo "EFI=${EFI}"
echo "SECURE=${SECURE}"
echo "EFI_DRIVE=${EFI_DRIVE}"
echo "EFI_PART_NUM=${EFI_PART_NUM}"
echo "KERNEL=${KERNEL}"
echo "MBR_BOOT_DEVICE=${MBR_BOOT_DEVICE}"
echo "EFI_BOOT_PARTITION=${EFI_BOOT_PARTITION}"
echo "MICROCODE=${MICROCODE}"
echo "LUKS_ROOT=${LUKS_ROOT}"
echo "USER=${USER}"
echo "HOSTNAME=${HOSTNAME}"
echo "WIRELESS=${WIRELESS}"
read -n1 -p "Press any key to continue."


# start install
echo "create initial ramdisk environment"
echo "mkinitcpio -p ${KERNEL}"
mkinitcpio -p ${KERNEL}

echo "install text editor"
echo "pacman -S --noconfirm nano"
pacman -S --noconfirm nano

echo "generate /etc/adjtime"
echo "hwclock --systohc"
hwclock --systohc

echo "setup locale"
echo "nano /etc/locale.gen"
nano /etc/locale.gen

echo "generate locale.conf"
echo "locale-gen"
locale-gen

if [ $MICROCODE != "none" ]
then
    echo "install microcode"
    if [ $MICROCODE = "intel" ]
    then
        echo "pacman -S --noconfirm intel-ucode"
        pacman -S --noconfirm intel-ucode
    else
        if [ $MICROCODE = "amd" ]
        then
            echo "pacman -S --noconfirm amd-ucode"
            pacman -S --noconfirm amd-ucode
        else
            echo "unknown microcode, trying to download anyway.."
            echo "pacman -S --noconfirm ${MICROCODE}"
            pacman -S --noconfirm ${MICROCODE}
        fi
    fi
fi

echo "install bootloader"
echo "pacman -S --noconfirm grub os-prober"
pacman -S --noconfirm grub os-prober

if [ $LUKS_ROOT != "NO" ]
then
    echo "sed -i /GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\\\"cryptdevice=/dev/disk/by-uuid/${LUKS_ROOT}:root\\\" /etc/default/grub"
	sed -i /GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"cryptdevice=/dev/disk/by-uuid/${LUKS_ROOT}:root\" /etc/default/grub
fi

if [ $EFI == "YES" ]
then
    echo "pacman -S --noconfirm efibootmgr"
    pacman -S --noconfirm efibootmgr

    echo "grub-install --target=x86_64-efi --efi-directory=${EFI_BOOT_PARTITION} --bootloader-id=grub"
    grub-install --target=x86_64-efi --efi-directory=${EFI_BOOT_PARTITION} --bootloader-id=grub

    echo "grub-mkconfig -o ${EFI_BOOT_PARTITION}/grub/grub.cfg"
    grub-mkconfig -o ${EFI_BOOT_PARTITION}/grub/grub.cfg

    if [ $SECURE == "YES" ]
    then
        echo "build standalone grub image for secure boot"
        echo "echo 'configfile \${cmdpath}/grub.cfg' > /tmp/grub.cfg"
        echo 'configfile ${cmdpath}/grub.cfg' > /tmp/grub.cfg

        echo "grub-mkstandalone -O x86_64-efi --modules=\"part_gpt part_msdos tpm\" --disable-shim-lock \
                                              --locales=\"en@quot\" -o \"${EFI_BOOT_PARTITION}/EFI/grub/loader.efi\" \"boot/grub/grub.cfg=/tmp/grub.cfg\" -v"
        grub-mkstandalone -O x86_64-efi --modules="part_gpt part_msdos tpm" --disable-shim-lock \
                                        --locales="en@quot" -o "${EFI_BOOT_PARTITION}/EFI/grub/loader.efi" "boot/grub/grub.cfg=/tmp/grub.cfg" -v

        echo "cp ${EFI_BOOT_PARTITION}/grub/grub.cfg ${EFI_BOOT_PARTITION}/EFI/grub/grub.cfg"
        cp ${EFI_BOOT_PARTITION}/grub/grub.cfg ${EFI_BOOT_PARTITION}/EFI/grub/grub.cfg

        echo "install and setup preloader"
        echo "pacman -S --noconfirm git"
        pacman -S --noconfirm git

        echo "cd /tmp"
        cd /tmp

        echo "git clone https://aur.archlinux.org/preloader-signed.git"
        git clone https://aur.archlinux.org/preloader-signed.git

        echo "cd preloader-signed"
        cd predloader-signed

        echo "makepkg -sri"
        makepkg -sri

        echo "cp /usr/share/preloader-signed/{PreLoader,HashTool}.efi ${EFI_BOOT_PARTITION}/EFI/grub"
        cp /usr/share/preloader-signed/{PreLoader,HashTool}.efi ${EFI_BOOT_PARTITION}/EFI/grub

        echo "create NVRAM entry for preloader and hashtool"
        echo "efibootmgr --verbose --disk ${EFI_DRIVE} --part ${EFI_PART_NUM} --create --label \"PreLoader\" --loader /EFI/grub/PreLoader.efi"
        efibootmgr --verbose --disk ${EFI_DRIVE} --part ${EFI_PART_NUM} --create --label "PreLoader" --loader /EFI/grub/PreLoader.efi
        echo "efibootmgr --verbose --disk ${EFI_DRIVE} --part ${EFI_PART_NUM} --create --label \"HashTool\" --loader /EFI/grub/HashTool.efi"
        efibootmgr --verbose --disk ${EFI_DRIVE} --part ${EFI_PART_NUM} --create --label "HashTool" --loader /EFI/grub/HashTool.efi
    fi
else
    echo "grub-install --recheck ${MBR_BOOT_DEVICE}"
    grub-install --recheck ${MBR_BOOT_DEVICE}

    echo "grub-mkconfig -o ${MBR_BOOT_DEVICE}/grub/grub.cfg"
    grub-mkconfig -o ${MBR_BOOT_DEVICE}/grub/grub.cfg
fi

echo "set root password"
echo "passwd"
passwd

echo "add user"
echo "useradd -m ${USER}"
useradd -m ${USER}

echo "passwd ${USER}"
passwd ${USER}

echo "set hostname"
echo "echo ${HOSTNAME} > /etc/hostname"
echo ${HOSTNAME} > /etc/hostname
echo "sed -i \"s/hostname=\"localhost\"/hostname=\"${HOSTNAME}\"/g\" /etc/conf.d/hostname"
sed -i "s/hostname=\"localhost\"/hostname=\"${HOSTNAME}\"/g" /etc/conf.d/hostname

echo "add host entries"
echo "echo \"127.0.0.1 localhost\" > /etc/hosts"
echo "127.0.0.1 localhost" > /etc/hosts
echo "echo \"::1 localhost\" > /etc/hosts"
echo "::1 localhost" > /etc/hosts
echo "echo \"127.0.0.1 ${HOSTNAME}.localdomain ${HOSTNAME}\" > /etc/hosts"
echo "127.0.0.1 ${HOSTNAME}.localdomain ${HOSTNAME}" > /etc/hosts

echo "install network services"
if [ ${WIRELESS} == "YES" ]
then
    echo "pacman -S --noconfirm wpa_supplicant networkmanager-openrc"
    pacman -S --noconfirm wpa_supplicant networkmanager-openrc
    echo "rc-update add networkmanager"
    rc-update add NetworkManager
else
    echo "pacman -S --noconfirm dhcpcd connman-openrc"
    pacman -S --noconfirm dhcpcd connman-openrc
    echo "rc-update add connmand"
    rc-update add connmand
fi

echo "done. exit chroot, unmount root and reboot."
echo "exit"
echo "umount -R /mnt"
echo "reboot"
