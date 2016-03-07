#!/bin/bash

TARGET_PARTITIONS=$(awk '{print $4}' /proc/partitions | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d')

for i in $TARGET_PARTITIONS
do
  if [[ "$i" == "sda"* ]]
  then
    logger -t transfer "skipping /dev/$i"
  elif [[ "$i" == "sdb"* ]]
  then
    logger -t transfer "found a [base] partition /dev/$i"
    mkdir -p /mnt/$i
    mount -o ro /dev/$i /mnt/$i
    logger -t transfer "successfully mounted /dev/$i on /mnt/$i for read-only"
  elif [[ "$i" == "sdc"* ]]
  then
    logger -t transfer "found a [source] partition /dev/$i"
    mkdir -p /mnt/$i
    mount -o ro /dev/$i /mnt/$i
    logger -t transfer "successfully mounted /dev/$i on /mnt/$i for read-only"
  elif [[ "$i" == "sdd"* ]]
  then
    logger -t transfer "found a [destination] partition /dev/$i"
    mkdir -p /mnt/$i
    mount -o rw /dev/$i /mnt/$i
    logger -t transfer "successfully mounted /dev/$i on /mnt/$i for writing"
  fi
done
