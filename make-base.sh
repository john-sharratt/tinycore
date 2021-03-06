#!/bin/bash -e

# Download and extra the ISO
TC="http://tinycorelinux.net/7.x/x86"
if [ -d "base.iso.d" ]; then
  rm -r base.iso.d
fi
mkdir -p base.iso.d
if [ ! -f "base.iso" ]; then
  wget -v $TC/release/Core-7.0.iso -O base.iso
fi
xorriso -osirrox on -indev base.iso -extract / base.iso.d
dd if=base.iso of=base.iso.boot bs=2048 skip=28 count=1

# Copy the ISO
if [ -d "tc.iso.d" ]; then
  rm -r tc.iso.d
fi
cp -r base.iso.d tc.iso.d

# Make the login instant by modifying the boot menu
sed -i '/prompt/d' tc.iso.d/boot/isolinux/isolinux.cfg
echo "prompt 0" >> tc.iso.d/boot/isolinux/isolinux.cfg

# Extract the core file system
if [ -d "core.gz.d" ]; then
  rm -r core.gz.d
fi
mkdir -p core.gz.d
cp tc.iso.d/boot/core.gz core.gz
cd core.gz.d
zcat ../core.gz | cpio -i -H newc -d
cd ..

# Download all the packages we need
mkdir -p packages.d
if [ ! -f "packages.d/openssl.tcz" ]; then
  wget -v $TC/tcz/openssl.tcz -O packages.d/openssl.tcz
fi
if [ ! -f "packages.d/pcre.tcz" ]; then
  wget -v $TC/tcz/pcre.tcz -O packages.d/pcre.tcz
fi
if [ ! -f "packages.d/nginx.tcz" ]; then
  wget -v $TC/tcz/nginx.tcz -O packages.d/nginx.tcz
fi
if [ ! -f "packages.d/iptables.tcz" ]; then
  wget -v $TC/tcz/iptables.tcz -O packages.d/iptables.tcz
fi
if [ ! -f "packages.d/dhcp.tcz" ]; then
  wget -v $TC/tcz/dhcp.tcz -O packages.d/dhcp.tcz
fi
if [ ! -f "packages.d/dnsmasq.tcz" ]; then
  wget -v $TC/tcz/dnsmasq.tcz -O packages.d/dnsmasq.tcz
fi

# Extract all the packages
if [ ! -d "packages.d/openssl.d" ]; then
  unsquashfs -f packages.d/openssl.tcz
  mv squashfs-root packages.d/openssl.d
fi

if [ ! -d "packages.d/pcre.d" ]; then
  unsquashfs -f packages.d/pcre.tcz
  mv squashfs-root packages.d/pcre.d
fi

if [ ! -d "packages.d/nginx.d" ]; then
  unsquashfs -f packages.d/nginx.tcz
  mv squashfs-root packages.d/nginx.d
fi

if [ ! -d "packages.d/iptables.d" ]; then
  unsquashfs -f packages.d/iptables.tcz
  mv squashfs-root packages.d/iptables.d
fi

if [ ! -d "packages.d/dhcp.d" ]; then
  unsquashfs -f packages.d/dhcp.tcz
  mv squashfs-root packages.d/dhcp.d
fi

if [ ! -d "packages.d/dnsmasq.d" ]; then
  unsquashfs -f packages.d/dnsmasq.tcz
  mv squashfs-root packages.d/dnsmasq.d
fi
