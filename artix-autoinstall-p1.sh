#!/bin/bash
# install options
AUTOMOUNT="NO"
ROOT="/mnt"
BOOT="none"
HOME="none"
SWAP="none"
KERNEL="linux"

# drive options
LUKS_ROOT="NO"
DRIVE_IS_NVME="NO"


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
            LUKS_ROOT="$2"
            shift
            shift
            ;;
        --nvme)
            DRIVE_IS_NVME="$2"
            shift
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "part 1 parsed arguments"
echo "AUTOMOUNT=${AUTOMOUNT}"
echo "ROOT=${ROOT}"
echo "BOOT=${BOOT}"
echo "HOME=${HOME}"
echo "SWAP=${SWAP}"
echo "KERNEL=${KERNEL}"
echo "LUKS_ROOT=${LUKS_ROOT}"
echo "DRIVE_IS_NVME=${DRIVE_IS_NVME}"
read -n1 -p "Press any key to continue."

if [ $AUTOMOUNT = "YES" ]
then
    echo "mounting pattitions"
    echo "mount ${ROOT} /mnt"
    mount ${ROOT} /mnt
    echo "mkdir /mnt/boot"
    mkdir /mnt/boot
    echo "mkdir /mnt/home"
    mkdir /mnt/home

    if [ $BOOT != "none" ]
    then
        echo "mount ${BOOT} /mnt/boot"
        mount ${BOOT} /mnt/boot
    fi

    if [ $HOME != "none" ]
    then
        echo "mount ${HOME} /mnt/home"
        mount ${HOME} /mnt/home
    fi

    if [ $SWAP != "none" ]
    then
        echo "swapon ${SWAP}"
        swapon ${SWAP}
    fi

    ROOT="/mnt"
fi

# start install
echo "install base system and kernel"
echo "basestrap ${ROOT} base base-devel openrc elogind-openrc ${KERNEL} linux-firmware"
basestrap ${ROOT} base base-devel openrc elogind-openrc ${KERNEL} linux-firmware

echo "generate fstab"
echo "fstabgen -L -p ${ROOT} > ${ROOT}/etc/fstab"
fstabgen -L -p ${ROOT} > ${ROOT}/etc/fstab

# {2} = drivepath
# {1} = label

if [ $DRIVE_IS_NVME = "YES" ]
then
    echo "sed -i \"s/MODULES=()/MODULES=(nvme)/g\" ${ROOT}/etc/mkinitcpio.conf"
    sed -i "s/MODULES=()/MODULES=(nvme)/g" ${ROOT}/etc/mkinitcpio.conf
fi

if [ $LUKS_ROOT != "NO" ]
then
    echo "sed -i \"s/block filesystems/block encrypt filesystems/g\" ${ROOT}/etc/mkinitcpio.conf"
	sed -i "s/block filesystems/block encrypt filesystems/g" ${ROOT}/etc/mkinitcpio.conf
fi

echo "base system installation complete."
echo "chroot into root and run artix-autoinstall-p2"
echo "artix-chroot ${ROOT}"
