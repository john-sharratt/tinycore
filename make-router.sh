#!/bin/bash -e

RUNDIR=$(pwd)

# Extract the core
. ./make-base.sh

# Copy the core to transfer iso
cp -r packages.d/nginx.d/* core.gz.d
cp -r packages.d/iptables.d/* core.gz.d
cp -r packages.d/dhcpcd.d/* core.gz.d
cp -r packages.d/dnsmasq.d/* core.gz.d

# Loop through all the systems and VM's
cd blueprints/bank.md.d/systems/
for system in */
do
  system1=$(echo "$system" | sed 's|/||g')
  cd $system1/system.md.d
  for vm in */
  do
    vm1=$(echo "$vm" | sed 's|/||g')

    # Emit all the DHCP configuration
    CFG=$RUNDIR/core.gz.d/etc/dhcpcd.conf
    MAPS=$(cat $vm1/ip.map.list)
    for MAP in $MAPS
    do
      MAC=$(echo "$MAP" | cut -d "|" -f1)
      HOST=$(echo "$MAP" | cut -d "|" -f2)
      IP=$(echo "$MAP" | cut -d "|" -f3)
      ROUTER=$(cat $vm1/ip.router)
      echo "host $HOST.$vm1.$system1 {" >> $CFG
      echo "  hardware ethernet $MAC;" >> $CFG
      echo "  fixed-address $IP;" >> $CFG
      echo "  domain-name-servers $ROUTER;" >> $CFG
      echo "  domain-search \"$vm1.$system1\";" >> $CFG
      echo "  option routers $ROUTER;" >> $CFG
      echo "}" >> $CFG
    done
  done
 cd ../..
done
cd $RUNDIR

# Emit the DNS entries


# Emit the startup script
echo "sudo /sbin/dhcpcd" >> core.gz.d/opt/bootlocal.sh

# Create the ISO
. ./make-iso.sh
