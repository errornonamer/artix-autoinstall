#!/bin/bash

# p1 options
# install options
AUTOMOUNT="NO"
ROOT="/mnt"
BOOT="none"
HOME="none"
SWAP="none"
KERNEL="linux"

# drive options
ROOT_IS_LUKS="NO"
DRIVE_IS_NVME="NO"


# p2 options
# boot options
EFI="YES"
SECURE="NO"
BOOT_PARTITION="/boot"
MICROCODE=""

# configuration options
USER="user"
HOSTNAME="artix-linux"
WIRELESS="NO"


# parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -a|--automount)
            AUTOMOUNT="$2"
            shift
            shift
            ;;
        -r|--root)
            ROOT="$2"
            shift
            shift
            ;;
        -b|--boot)
            BOOT="$2"
            BOOT_PARTITION="${2}"
            shift
            shift
            ;;
        -h|--home)
            HOME="$2"
            shift
            shift
            ;;
        -s|--swap)
            SWAP="$2"
            shift
            shift
            ;;
        -k|--kernel)
            KERNEL="$2"
            shift
            shift
            ;;
        --luks-root)
            #ROOT_IS_LUKS="$2"
            shift
            shift
            ;;
        --nvme)
            DRIVE_IS_NVME="$2"
            shift
            shift
            ;;
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
        --ucode|--microcode)
            MICROCODE="${2}"
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

echo "parsed arguments"
echo "AUTOMOUNT=${AUTOMOUNT}"
echo "ROOT=${ROOT}"
echo "BOOT=${BOOT}"
echo "HOME=${HOME}"
echo "SWAP=${SWAP}"
echo "KERNEL=${KERNEL}"
echo "ROOT_IS_LUKS=${ROOT_IS_LUKS}"
echo "DRIVE_IS_NVME=${DRIVE_IS_NVME}"
echo "EFI=${EFI}"
echo "BOOT_PARTITION=${BOOT_PARTITION}"
echo "MICROCODE=${MICROCODE}"
echo "USER=${USER}"
echo "HOSTNAME=${HOSTNAME}"
echo "WIRELESS=${WIRELESS}"
read -n1 -p "Press any key to continue."

# installer 1
bash artix-autoinstall-p1.sh -a ${AUTOMOUNT} -r ${ROOT} -b ${BOOT} -h ${HOME} -s ${SWAP} -k ${KERNEL} --luks-root ${ROOT_IS_LUKS} --nvme ${DRIVE_IS_NVME}

if [ $AUTOMOUNT = "YES" ]
then
    ROOT="/mnt"
    BOOT_PARTITION="/boot"
fi

# copy installer to chroot enviroment
cp artix-autoinstall-p2.sh ${ROOT}
chmod 755 ${ROOT}/artix-autoinstall-p2.sh

# launch installer 2: electric boogaloo
artix-chroot ${ROOT} bash artix-autoinstall-p2.sh --efi ${EFI} -k ${KERNEL} -b ${BOOT_PARTITION} --ucode ${MICROCODE} -u ${USER} -n ${HOSTNAME} -w ${WIRELESS}

# delete copied installer
rm ${ROOT}/artix-autoinstall-p2.sh
