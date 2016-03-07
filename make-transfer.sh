#!/bin/bash -e

# Extract the core
. ./make-base.sh

# Copy the core to transfer iso
touch core.gz.d/TEST.TEST

# Create the ISO
. ./make-iso.sh
