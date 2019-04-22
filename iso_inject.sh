#!/bin/bash

set -x

SELECT=$1

if [[ $SELECT == "desktop" ]]; then
    echo "Ubuntu Desktop ISO Injection"
    BASE="http://releases.ubuntu.com/16.04"
    ISO="ubuntu-16.04.6-desktop-amd64.iso"
    CASPER="casper"
elif [[ $SELECT == "server" ]]; then
    echo "Ubuntu Server 16.04 ISO Injection"
    BASE="http://releases.ubuntu.com/16.04"
    ISO="ubuntu-16.04.6-server-amd64.iso"
    CASPER="install"
elif [[ $SELECT == "serv18" ]]; then
    echo "Ubuntu Server 18.04 ISO Injection"
    BASE="http://releases.ubuntu.com/18.04"
    ISO="ubuntu-18.04.2-live-server-amd64.iso"
    CASPER="casper"

else
    echo "Usage ./iso_inject.sh [desktop|server|serv18]"
    exit 1
fi

RESULTISO="custom-$ISO"
URL="$BASE/$ISO"

WORKDIR="custom-img"
EDIT="edit"
EXTRACT="extract"


[ ! -e $ISO ] && wget $URL

mkdir -p $WORKDIR
cp $ISO $WORKDIR
cd $WORKDIR

mkdir -p mnt
sudo mount -o loop $ISO mnt

mkdir $EXTRACT
sudo rsync --exclude=/$CASPER/filesystem.squashfs -a mnt/ $EXTRACT
sudo unsquashfs mnt/$CASPER/filesystem.squashfs
sudo mv squashfs-root $EDIT

sudo cp /etc/resolv.conf $EDIT/etc/
#sudo mount --bind /dev/ $EDIT/dev

# Add StarlingX deb files to rootfs
sudo cp -r ../stxdebs $EDIT/
sudo cp -r ../stxdebs $EDIT/usr/local

# Configure rootfs with config_rootfs.sh script
sudo cp ../config.sh $EDIT
sudo chroot $EDIT "./config.sh"
retcode=$?
if [ $retcode -eq 0 ]; then
    #sudo umount $EDIT/dev
    sudo chmod +w $EXTRACT/$CASPER/filesystem.manifest
    sudo chroot $EDIT dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee $EXTRACT/$CASPER/filesystem.manifest
    sudo cp $EXTRACT/$CASPER/filesystem.manifest $EXTRACT/$CASPER/filesystem.manifest-desktop
    sudo sed -i '/ubiquity/d' $EXTRACT/$CASPER/filesystem.manifest-desktop

    if [[ $SELECT == "desktop" ]]; then
        sudo sed -i '/casper/d' $EXTRACT/$CASPER/filesystem.manifest-desktop
    elif [[ $SELECT == "server" ]]; then
        sudo sed -i '/install/d' $EXTRACT/$CASPER/filesystem.manifest-desktop
    elif [[ $SELECT == "serv18" ]]; then
        sudo sed -i '/casper/d' $EXTRACT/$CASPER/filesystem.manifest-desktop
    fi

    sudo mksquashfs $EDIT $EXTRACT/$CASPER/filesystem.squashfs -b 1048576
    printf $(sudo du -sx --block-size=1 edit | cut -f1) | sudo tee $EXTRACT/$CASPER/filesystem.size
    cd $EXTRACT
    sudo rm md5sum.txt
    find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
    sudo genisoimage -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../../$RESULTISO .
else
    echo "Error in container custom installation"
    exit 1
fi
