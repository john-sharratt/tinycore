#!/bin/bash -e

# Bundle the core.gz file back together
rm core.gz
cd core.gz.d
find | cpio -o -H newc | gzip -2 > ../core.gz
cd ..

# Copy the core.gz to the base.iso
cp core.gz tc.iso.d/boot

# Make the ISO image
if [ -f tc.iso ]; then
  rm tc.iso
fi
genisoimage -l -J -R -V TC-ING -no-emul-boot -boot-load-size 4\
  -boot-info-table -b boot/isolinux/isolinux.bin \
  -c boot/isolinux/boot.cat -o tc.iso tc.iso.d
