#!/bin/bash
#
# Installs the VMware HGFS kernel module from the VMware Tools ISO.
# Required when open-vm-tools does not provide HGFS support.
#
# Usage: bash install_vmhgfs.sh [/path/to/linux.iso]
#   Defaults to ~/Desktop/linux.iso if no argument is given.
#

set -e
LOG=/tmp/install_vmhgfs.log
touch "$LOG"

# shellcheck source=/dev/null
if [[ -e ~/utils/bin/utils.sh ]]; then
    . ~/utils/bin/utils.sh
else
    echo "Cant find utils.sh."
    exit 1
fi

if [[ -f "$1" ]]; then
    LINUX_ISO="$1"
else
    LINUX_ISO="$HOME/Desktop/linux.iso"
fi

if [[ ! -f "$LINUX_ISO" ]]; then
    print_status "INFO" "You have to copy linux.iso from your VMware installation to ~/Desktop/linux.iso or pass the pass as the first argument."
    exit 1
fi

print_status "INFO" "Starting installation of VMware vmhgfs module."
print_status "INFO" "Details logged to $LOG."

TMP_DIR=$(mktemp -d)
CURRENT_DIR=$PWD
print_status "INFO" "Created TMP_DIR: $TMP_DIR"

print_status "INFO" "Mount linux.iso"
[[ ! -d /mnt/cdrom ]] && sudo mkdir -p /mnt/cdrom
sudo mount --read-only "$LINUX_ISO" /mnt/cdrom
cd "$TMP_DIR" || error-exit-message "Couldn't cd to $TMP_DIR"
print_status "INFO" "Extract VMwareTools."
tar zxf /mnt/cdrom/VMwareTools*.tar.gz
print_status "INFO" "Umount linux.iso"
sudo umount /mnt/cdrom
cd vmware-tools-distrib || error-exit-message "Couldn't cd to vmware-tools-distrib."

print_status "INFO" "Start vmware-install.pl."
# shellcheck disable=SC2024
sudo ./vmware-install.pl -d >> "$LOG" 2>&1
print_status "INFO" "Installation completed."

print_status "INFO" "Remove TMP_DIR: $TMP_DIR"
cd "$CURRENT_DIR"
rm -rf "$TMP_DIR"

if [[ "$(vmware-hgfsclient)" != "" ]]; then
    print_status "INFO" "Run the following command to mount your share on /cases:"
    print_status "INFO" "sudo mount -t vmhgfs .host:/$(vmware-hgfsclient) /cases"
fi

print_status "INFO" "Stopping open-vm-tools."
# shellcheck disable=SC2024
sudo service open-vm-tools stop >> "$LOG" 2>&1
print_status "INFO" "Starting open-vm-tools."
# shellcheck disable=SC2024
sudo service open-vm-tools start >> "$LOG" 2>&1
print_status "INFO" "You still might need to reboot to get copy and paste to work."
print_status "INFO" "Installation of vmhgfs completed."
