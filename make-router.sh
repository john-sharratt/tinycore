#!/bin/bash -e

RUNDIR=$(pwd)

# Extract the core
. ./make-base.sh

# Copy the core to transfer iso
cp -r packages.d/openssl.d/* core.gz.d
cp -r packages.d/pcre.d/* core.gz.d
cp -r packages.d/nginx.d/* core.gz.d
cp -r packages.d/iptables.d/* core.gz.d
cp -r packages.d/dhcp.d/* core.gz.d
cp -r packages.d/dnsmasq.d/* core.gz.d

# Reset the DHCP configuration
CFG=$RUNDIR/core.gz.d/usr/local/etc/dhcpd.conf
if [ -f "core.gz.d/usr/local/etc/dhcpd.conf" ]; then
  rm core.gz.d/usr/local/etc/dhcpd.conf
fi
echo "default-lease-time 600;" >> $CFG
echo "max-lease-time 7200;" >> $CFG
echo "" >> $CFG

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
    MAPS=$(cat $vm1/ip.map.list)
    for MAP in $MAPS
    do
      MAC=$(echo "$MAP" | cut -d "|" -f1)
      HOST=$(echo "$MAP" | cut -d "|" -f2)
      IP=$(echo "$MAP" | cut -d "|" -f3)
      ROUTER=$(cat $vm1/ip.router)
      echo "host ${HOST}.${vm1}.${system1}" >> $CFG
      echo "{" >> $CFG
      echo "  hardware ethernet $MAC;" >> $CFG
      echo "  fixed-address $IP;" >> $CFG
      echo "  server-name \"${HOST}.${vm1}.${system1}\";" >> $CFG
      echo "  option domain-name-servers $ROUTER;" >> $CFG
      echo "  option domain-search \"$vm1.$system1\";" >> $CFG
      echo "  option host-name \"${HOST}.${vm1}.${system1}\";" >> $CFG
      echo "  option routers $ROUTER;" >> $CFG
      echo "}" >> $CFG
    done
  done
 cd ../..
done
cd $RUNDIR

# Emit the startup script
BOOT="core.gz.d/opt/bootlocal.sh"
echo "sudo /usr/local/sbin/basic-firewall" >> $BOOT
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> $BOOT
echo "sudo /usr/local/sbin/dhcpd" >> $BOOT
echo "sudo /usr/local/sbin/dnsmasq" >> $BOOT
echo "sudo /usr/local/etc/init.d/nginx start" >> $BOOT

# Create the ISO
. ./make-iso.sh
