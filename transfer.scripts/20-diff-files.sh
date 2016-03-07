#!/bin/bash

TARGET_PARTITIONS=$(awk '{print $4}' /proc/partitions | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d')

for i in $TARGET_PARTITIONS
do
  if [[ "$i" == "sdb"* ]];
  then
    logger -t transfer "trim all the files from /dev/$i"
    cat  /diff/$i.dirs  | cut -d '"' -f2 > /diff/$i.dirs.trimmed
    cat  /diff/$i.files | cut -d '"' -f2 > /diff/$i.files.trimmed
  elif [[ "$i" == "sdc"* ]] || [[ "$i" == "sdd"* ]];
  then
    o=${i/sdc/sdb}
    o=${o/sdd/sdb}

    if [ -f "/diff/$i.files" ]; then
      logger -t transfer "trim all the files have have not changed from /dev/$o to /dev/$i"
      comm -3 -1 --nocheck-order /diff/$o.dirs  /diff/$i.dirs  | sed 's/^\t//' | cut -d '"' -f2 > /diff/$i.dirs.trimmed
      comm -3 -1 --nocheck-order /diff/$o.files /diff/$i.files | sed 's/^\t//' | cut -d '"' -f2 > /diff/$i.files.trimmed

      logger -t transfer "computing the diffs from /dev/$o to /dev/$i"
      comm -2 -1 --nocheck-order /diff/$o.dirs.trimmed  /diff/$i.dirs.trimmed  | sed 's/^\t/-/' > /diff/$i.dirs.mod
      comm -3 -1 --nocheck-order /diff/$o.dirs.trimmed  /diff/$i.dirs.trimmed  | sed 's/^\t/-/' > /diff/$i.dirs.copy
      comm -2 -1 --nocheck-order /diff/$o.files.trimmed /diff/$i.files.trimmed | sed 's/^\t/-/' > /diff/$i.files.mod
      comm -3 -1 --nocheck-order /diff/$o.files.trimmed /diff/$i.files.trimmed | sed 's/^\t/-/' > /diff/$i.files.copy
    else
      touch /diff/$i.dirs.trimmed
      touch /diff/$i.files.trimmed
      touch /diff/$i.dirs.mod
      touch /diff/$i.files.mod
      touch /diff/$i.dirs.copy
      touch /diff/$i.files.copy
    fi
  fi
done
