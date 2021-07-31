#!/bin/bash
# install options
ROOT_MOUNT="/mnt"
KERNEL="linux"

# drive options
ROOT_IS_LUKS="NO"
DRIVE_IS_NVME="NO"


# parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -r|--root)
            ROOT_MOUNT="$2"
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
echo "ROOT_MOUNT=${ROOT_MOUNT}"
echo "KERNEL=${KERNEL}"
echo "ROOT_IS_LUKS=${ROOT_IS_LUKS}"
echo "DRIVE_IS_NVME=${DRIVE_IS_NVME}"
read -n1 -p "Press any key to continue."

# start install
echo "install base system"
echo "basestrap ${ROOT_MOUNT} base base-devel openrc elogind-openrc"
basestrap ${ROOT_MOUNT} base base-devel openrc elogind-openrc

echo "install kernel"
echo "basestrap ${ROOT_MOUNT} ${KERNEL} linux-firmware"
basestrap ${ROOT_MOUNT} ${KERNEL} linux-firmware

echo "generate fstab"
echo "fstabgen -L -p ${ROOT_MOUNT} > ${ROOT_MOUNT}/etc/fstab"
fstabgen -L -p ${ROOT_MOUNT} > ${ROOT_MOUNT}/etc/fstab

# {2} = drivepath
# {1} = label

#if [ $ROOT_IS_LUKS = "YES" ] then
#fi

if [ $DRIVE_IS_NVME = "YES" ] then
    echo "sed -i \"s/MODULES=()/MODULES=(nvme)/g\" ${ROOT_MOUNT}/etc/mkinitcpio.conf"
    sed -i "s/MODULES=()/MODULES=(nvme)/g" ${ROOT_MOUNT}/etc/mkinitcpio.conf
fi

echo "base system installation complete."
echo "chroot into root and run artix-autoinstall-p2"
echo "artix-chroot ${ROOT_MOUNT}"
