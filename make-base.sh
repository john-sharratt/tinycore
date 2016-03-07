#!/bin/bash -e

# Download and extra the ISO
TC="http://tinycorelinux.net/7.x/x86"
if [ -d "base.iso.d" ]; then
  rm -r base.iso.d
fi
mkdir -p base.iso.d
wget -v $TC/release/Core-7.0.iso -O base.iso
xorriso -osirrox on -indev base.iso -extract / base.iso.d
dd if=base.iso of=base.iso.boot bs=2048 skip=28 count=1

# Extract the core file system
if [ -d "core.gz.d" ]; then
  rm -r core.gz.d
fi
mkdir -p core.gz.d
cp base.iso.d/boot/core.gz core.gz
cd core.gz.d
zcat ../core.gz | cpio -i -H newc -d
cd ..

# Download all the packages we need
if [ -d "packages.d" ]; then
  rm -r packages.d
fi
mkdir packages.d
wget -v $TC/tcz/nginx.tcz -O packages.d/nginx.tcz
wget -v $TC/tcz/iptables.tcz -O packages.d/iptables.tcz
wget -v $TC/tcz/dhcpcd.tcz -O packages.d/dhcpcd.tcz
wget -v $TC/tcz/dnsmasq.tcz -O packages.d/dnsmasq.tcz

# Extract all the packages
unsquashfs -f packages.d/nginx.tcz
mv squashfs-root/usr/local packages.d/nginx.d
rm -r squashfs-root

unsquashfs -f packages.d/iptables.tcz
mv squashfs-root/usr/local packages.d/iptables.d
rm -r squashfs-root

unsquashfs -f packages.d/dhcpcd.tcz
mv squashfs-root/usr/local packages.d/dhcpcd.d
rm -r squashfs-root

unsquashfs -f packages.d/dnsmasq.tcz
mv squashfs-root/usr/local packages.d/dnsmasq.d
rm -r squashfs-root

# Copy all the files to the core
cp -r packages.d/nginx.d/* core.gz.d
cp -r packages.d/iptables.d/* core.gz.d
cp -r packages.d/dhcpcd.d/* core.gz.d
cp -r packages.d/dnsmasq.d/* core.gz.d
