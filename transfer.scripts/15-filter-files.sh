#!/bin/bash

TARGET_PARTITIONS=$(awk '{print $4}' /proc/partitions | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d')

for i in $TARGET_PARTITIONS
do
  logger -t transfer "filtering out the ignore rules [/dev/$i]"
  while read x; do
    cp /diff/$i.dirs /diff/$i.dirs.temp
    cp /diff/$i.files /diff/$i.files.temp
    grep -v "^${x}" /diff/$i.dirs.temp  > /diff/$i.dirs
    grep -v "^${x}" /diff/$i.files.temp > /diff/$i.files
    rm /diff/$i.dirs.temp
    rm /diff/$i.files.temp
  done < /transfer/ignore.list
done
