#!/bin/bash

. ../build_cd.conf

ARCH=$1

CD_BUILD_DIR="$CD_BUILD_DIR_BASE-$ARCH"
CD_DEEPIN_DIR=$CD_BUILD_DIR/deepin

test -d $CD_BUILD_DIR || (echo "cd build directory not found."; false) || exit 1
test -d $DATA_DIR  || (echo "data directory not found."; false) || exit 1

cp $DATA_DIR/deepin.seed $CD_BUILD_DIR/preseed/deepin.seed

cp $CD_BUILD_DIR/preseed/deepin.seed $CD_BUILD_DIR/preseed/deepin-auto.seed
cat $DATA_DIR/deepin-auto.seed >> $CD_BUILD_DIR/preseed/deepin-auto.seed

cp $CD_BUILD_DIR/preseed/deepin.seed $CD_BUILD_DIR/preseed/disaster-recovery.seed
sed -i 's/INSTALL_MODE/RECOVER_MODE/g' $CD_BUILD_DIR/preseed/disaster-recovery.seed
cp $CD_BUILD_DIR/preseed/disaster-recovery.seed $CD_BUILD_DIR/preseed/disaster-recovery-auto.seed
cat $DATA_DIR/deepin-auto.seed >> $CD_BUILD_DIR/preseed/disaster-recovery-auto.seed

# deepin
rm -rf $CD_BUILD_DIR/preseed/ubuntu*
echo 'Deepin 2014.1 - Release amd64 (20140919)' > $CD_BUILD_DIR/.disk/info
echo 'http://www.linuxdeepin.com/releasenotes/2014' > $CD_BUILD_DIR/.disk/release_notes_url
sed -i 's/#define DISKNAME.*/#define DISKNAME Deepin 2014.1 - Release amd64/' $CD_BUILD_DIR/README.diskdefines
rm $CD_BUILD_DIR/ubuntu

# UDEB_INCLUDE=$CD_BUILD_DIR/.disk/udeb_include
# if [ "$INCLUDE_REMOTE" == "true" ]
# then
#     if ! grep -q zinstaller-remote $UDEB_INCLUDE
#     then
#         echo zinstaller-remote >> $UDEB_INCLUDE
#     fi
# fi

# if ! grep -q zinstaller-headless $UDEB_INCLUDE
# then
#     echo zinstaller-headless >> $UDEB_INCLUDE
# fi

# Add https apt method to be able to retrieve from QA updates repo
echo apt-transport-https > $CD_BUILD_DIR/.disk/base_include

if [ -f $BASE_DIR/DEBUG_MODE ]
then
    cp $CD_BUILD_DIR/preseed/deepin-auto.seed $CD_BUILD_DIR/preseed/deepin-debug.seed
    cat $DATA_DIR/deepin-debug.seed >> $CD_BUILD_DIR/preseed/deepin-debug.seed

    cp $CD_BUILD_DIR/preseed/deepin-debug.seed $CD_BUILD_DIR/preseed/disaster-recovery-debug.seed
    sed -i 's/INSTALL_MODE/RECOVER_MODE/g' $CD_BUILD_DIR/preseed/disaster-recovery-debug.seed

    cp $DATA_DIR/isolinux-deepin-debug.cfg $CD_BUILD_DIR/isolinux/txt.cfg
else
    sed -e s:VERSION:$VERSION: < $DATA_DIR/isolinux-deepin.cfg.template > $CD_BUILD_DIR/isolinux/txt.cfg
fi

USB_SUPPORT="cdrom-detect\/try-usb=true"
sed -i "s/gz quiet/gz $USB_SUPPORT quiet/g" $CD_BUILD_DIR/isolinux/txt.cfg

if echo $VERSION | grep -q daily
then
    DATE=`date +%Y-%m-%d`
    sed -e s:DATE:$DATE: < $DATA_DIR/isolinux-daily.template >> $CD_BUILD_DIR/isolinux/adtxt.cfg
fi


# not need
# test -d $CD_DEEPIN_DIR || mkdir -p $CD_DEEPIN_DIR

# rm -rf $CD_DEEPIN_DIR/*

# TMPDIR=/tmp/deepin-installer-data-$$
# cp -r $DATA_DIR $TMPDIR

# ./gen_locales.pl $TMPDIR || (echo "locales files autogeneration failed."; false) || exit 1

# cp -r $TMPDIR/* $CD_DEEPIN_DIR/

# rm -rf $TMPDIR
