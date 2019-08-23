#!/bin/sh

which rsync >/dev/null || pacman -S --noconfirm rsync
which mkimage >/dev/null || pacman -S --noconfirm uboot-tools

echo "Start script to copy /root to only EMMC /dev/mmcblk1p2"

DIR_INSTALL="/ddbr/install"
mkdir -p /ddbr
chmod 777 /ddbr
if [ -d $DIR_INSTALL ] ; then
    rm -rf $DIR_INSTALL
fi
mkdir -p $DIR_INSTALL

DEV_EMMC=/dev/mmcblk1
PART_ROOT="/dev/mmcblk1p2"

if grep -q $PART_ROOT /proc/mounts ; then
    echo "Unmounting ROOT partiton."
    umount -f $PART_ROOT
fi

echo "Formatting ROOT partition..."
mke2fs -F -q -t ext4 -L ROOT_EMMC -m 0 $PART_ROOT
e2fsck -n $PART_ROOT
echo "done."

echo "Copying ROOTFS."

mount -o rw $PART_ROOT $DIR_INSTALL

rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/boot/*","/ddbr","/lost+found"} / "$DIR_INSTALL"

echo "Create new fstab"

cat > "$DIR_INSTALL/etc/fstab" <<'EOF'
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
/dev/mmcblk1p1  /boot   vfat    defaults        0       0
EOF

sync

umount $DIR_INSTALL

echo "*******************************************"
echo "Complete copy root to eMMC partition 2"
echo "*******************************************"

