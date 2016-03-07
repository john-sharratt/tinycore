#!/bin/bash

TARGET_PARTITIONS=$(awk '{print $4}' /proc/partitions | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d')

if [ -f "/diff/transfer.sh" ];
then
  rm /diff/transfer.sh
fi
touch /diff/transfer.sh
chmod +x /diff/transfer.sh

echo "#!/bin/sh -e" >> /diff/transfer.sh
echo "" >> /diff/transfer.sh

for b in $TARGET_PARTITIONS
do
  if [[ "$b" == "sdb"* ]]
  then
    c=${b/sdb/sdc}
    d=${b/sdb/sdd}

    logger -t transfer "generating create directory commands"
    while read x; do
      echo "logger -t transfer 'creating missing directory in target [${x}]'" >> /diff/transfer.sh
      echo "mkdir -p '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chown --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chmod --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
    done < /diff/$c.dirs.copy

    logger -t transfer "generating chmod directory commands"
    while read x; do
      echo "logger -t transfer 'updating modified directory in target [${x}]'" >> /diff/transfer.sh
      echo "mkdir -p '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chown --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chmod --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
    done < /diff/$c.dirs.mod

    logger -t transfer "generating update file commands"
    while read x; do
      echo "logger -t transfer 'updating modified file in target [${x}]'" >> /diff/transfer.sh
      echo "cp '/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chown --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
      echo "chmod --reference='/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
    done < /diff/$c.files.mod

    logger -t transfer "generating copy file commands"
    while read x; do
      echo "logger -t transfer 'copying missing file in target [${x}]'" >> /diff/transfer.sh
      echo "cp '/mnt/${c}/${x}' '/mnt/${d}/${x}'" >> /diff/transfer.sh
    done < /diff/$c.files.copy

  fi
done
