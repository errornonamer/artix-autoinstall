#!/bin/bash
# install options
AUTOMOUNT="NO"
ROOT="/mnt"
BOOT=""
HOME=""
SWAP=""
KERNEL="linux"

# drive options
ROOT_IS_LUKS="NO"
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
            #ROOT_IS_LUKS="$2"
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
echo "ROOT_IS_LUKS=${ROOT_IS_LUKS}"
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

    if [ -n $BOOT ]
    then
        echo "mount ${BOOT} /mnt/boot"
        mount ${BOOT} /mnt/boot
    fi

    if [ -n $HOME ]
    then
        echo "mount ${HOME} /mnt/home"
        mount ${HOME} /mnt/home
    fi

    if [ -n $SWAP ]
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

#if [ $ROOT_IS_LUKS = "YES" ] then
#fi

if [ $DRIVE_IS_NVME = "YES" ]
then
    echo "sed -i \"s/MODULES=()/MODULES=(nvme)/g\" ${ROOT}/etc/mkinitcpio.conf"
    sed -i "s/MODULES=()/MODULES=(nvme)/g" ${ROOT}/etc/mkinitcpio.conf
fi

echo "base system installation complete."
echo "chroot into root and run artix-autoinstall-p2"
echo "artix-chroot ${ROOT}"
