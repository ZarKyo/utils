#!/bin/bash
#
# Mounts all VMware shared folders to ~/shares/ using vmhgfs-fuse.
# Creates ~/shares/ if it does not exist.
#
# Usage: bash vmware-mount-shared.sh
#

[[ ! -e "${HOME}/shares" ]] && mkdir "${HOME}/shares"

sudo /usr/bin/vmhgfs-fuse .host:/ "${HOME}/shares" -o subtype=vmhgfs-fuse,allow_other
