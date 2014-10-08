#!/bin/bash

. ../build_cd.conf

ARCH=$1

CD_BUILD_DIR="$CD_BUILD_DIR_BASE-$ARCH"

# Rebrand newt palette
pushd $CD_BUILD_DIR/install
mkdir tmp
cd tmp
gunzip < ../initrd.gz | cpio --extract --preserve
mkdir -p etc/newt
cp $DATA_DIR/palette.deepin etc/newt/palette.ubuntu
mkdir -p deepin
cp ../../../sources.list deepin/
for i in ../../../deepin/*
do
    cp -a $i deepin/
done
mkdir -p etc/apt/
cp deepin/sources.list etc/apt/sources.list
find . | cpio --create --'format=newc' | gzip > ../initrd.gz
cd ..
rm -rf tmp
popd

# Change default hostname
pushd $CD_BUILD_DIR/pool/main/n/netcfg/
NET_UDEB=`ls netcfg_*.udeb`
mkdir tmp
cd tmp
dpkg-deb -e ../$NET_UDEB
dpkg-deb -x ../$NET_UDEB .
sed -i "s/ubuntu/deepin/g" DEBIAN/templates
dpkg-deb -b . ../$NET_UDEB
cd ..
rm -rf tmp
popd

# Disable tasksel
# pushd $CD_BUILD_DIR/pool/main/p/pkgsel/
# PKG_UDEB=`ls pkgsel_*.udeb`
# mkdir tmp
# cd tmp
# dpkg-deb -e ../$PKG_UDEB
# dpkg-deb -x ../$PKG_UDEB .
# sed -i "s/.*install tasksel.*/true/g" DEBIAN/postinst
# sed -i "s/.*tasksel --new-install.*/true/g" DEBIAN/postinst
# dpkg-deb -b . ../$PKG_UDEB
# cd ..
# rm -rf tmp
# popd

# add deepin tasksel tasks
pushd $CD_BUILD_DIR/pool/main/t/tasksel/
DATA_DEB=`ls tasksel-data*.deb`
mkdir tmp
cd tmp
dpkg-deb -e ../$DATA_DEB
dpkg-deb -x ../$DATA_DEB .
cp -f $CD_BUILD_DIR/../deepin/deepin-tasks.desc usr/share/tasksel/
dpkg-deb -b . ../$DATA_DEB
cd ..
rm -rf tmp
popd

# Fix apt-setup because it ignores the key-error preseed
pushd $CD_BUILD_DIR/pool/main/a/apt-setup/
APT_UDEB=`ls apt-setup-udeb_*.udeb`
mkdir tmp
cd tmp
dpkg-deb -e ../$APT_UDEB
dpkg-deb -x ../$APT_UDEB .
sed -i "s/Retry/Ignore/g" usr/lib/apt-setup/generators/60local
dpkg-deb -b . ../$APT_UDEB
cd ..
rm -rf tmp
popd

