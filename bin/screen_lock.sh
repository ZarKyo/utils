#!/bin/bash
#
# ./screen_lock.sh lock    - Enables screen locking
# ./screen_lock.sh no-lock - Disables screen locking
#

# Function to configure screen locking
configure_locking() {
    local mode=$1

    if [[ "$mode" == "lock" ]]; then
        echo "Enabling screen lock..."
        # Enable screen locking
        gsettings set org.gnome.desktop.screensaver lock-enabled true
        # Enable screen lock when suspending the system
        gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend true
        # Set idle timeout to 5 minutes (300 seconds)
        gsettings set org.gnome.desktop.session idle-delay 300
    elif [[ "$mode" == "no-lock" ]]; then
        echo "Disabling screen lock..."
        # Disable screen locking
        gsettings set org.gnome.desktop.screensaver lock-enabled false
        # Disable screen lock when suspending the system
        gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
        # Disable idle timeout (never blank)
        gsettings set org.gnome.desktop.session idle-delay 0
    else
        echo "Usage: $0 [lock|no-lock]"
        exit 1
    fi
}

# Check if we are running GNOME
if [[ "$XDG_CURRENT_DESKTOP" != *GNOME* ]]; then
    echo "Error: This script only works on GNOME desktop environments."
    exit 1
fi

# Call the function with the first argument
configure_locking "$1"
