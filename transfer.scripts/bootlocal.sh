#!/bin/bash

/transfer/00-mount-all.sh
/transfer/10-find-files.sh
/transfer/15-filter-files.sh
/transfer/20-diff-files.sh
/transfer/20-diff-files.sh
/transfer/30-gen-commands.sh
/diff/transfer.sh

logger -t transfer "syncing the disks"
sync

logger -t transfer "shutting down in 5 seconds"
sleep 5
#shutdown -h now
