#!/bin/bash

TARGET_PARTITIONS=$(awk '{print $4}' /proc/partitions | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d')

if [ -d "/diff" ]; then
  rm -r /diff
fi
mkdir -p /diff

for i in $TARGET_PARTITIONS
do
  logger -t transfer "listing files and dirs in /dev/$i"
  find /mnt/$i -type d -printf '"%P"\t [%TD-%TI:%TM%Tp]\n' > /diff/$i.dirs
  find /mnt/$i -type f -printf '"%P"\t [%TD-%TI:%TM%Tp]\n' > /diff/$i.files
  sort /diff/$i.dirs  -o /diff/$i.dirs
  sort /diff/$i.files -o /diff/$i.files
done
