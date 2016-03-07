#!/bin/bash -e

# Extract the core
. ./make-base.sh

# Copy the core to transfer iso
cp -r transfer.scripts/* core.gz.d/opt

# Create the ISO
. ./make-iso.sh
