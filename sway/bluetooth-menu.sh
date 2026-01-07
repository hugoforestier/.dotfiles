#!/bin/bash

# Bluetooth menu selector using rofi
bluetooth_menu() {
    # Check if bluetooth is powered on
    POWER_STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

    # Get list of paired devices
    PAIRED_DEVICES=$(bluetoothctl devices Paired | sed 's/Device //')

    # Build menu options
    OPTIONS="Toggle Power (Currently: $POWER_STATUS)
Scan for Devices
---"

    if [[ -n "$PAIRED_DEVICES" ]]; then
        while IFS= read -r device; do
            MAC=$(echo "$device" | awk '{print $1}')
            NAME=$(echo "$device" | cut -d' ' -f2-)

            # Check if device is connected
            CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected:" | awk '{print $2}')

            if [[ "$CONNECTED" == "yes" ]]; then
                OPTIONS="$OPTIONS
✓ $NAME (Disconnect)"
            else
                OPTIONS="$OPTIONS
  $NAME (Connect)"
            fi
        done <<< "$PAIRED_DEVICES"
    fi

    # Show menu
    if command -v rofi &> /dev/null; then
        SELECTED=$(echo "$OPTIONS" | rofi -dmenu -i -p "Bluetooth")
    else
        SELECTED=$(echo "$OPTIONS" | dmenu -i -p "Bluetooth")
    fi

    if [[ -z "$SELECTED" || "$SELECTED" == "---" ]]; then
        exit 0
    fi

    # Handle selection
    if [[ "$SELECTED" =~ "Toggle Power" ]]; then
        if [[ "$POWER_STATUS" == "yes" ]]; then
            bluetoothctl power off
        else
            bluetoothctl power on
        fi
    elif [[ "$SELECTED" == "Scan for Devices" ]]; then
        # Start scan and show available devices
        bluetoothctl --timeout 10 scan on &
        sleep 3

        AVAILABLE=$(bluetoothctl devices | sed 's/Device //')

        if command -v rofi &> /dev/null; then
            DEVICE_SELECTED=$(echo "$AVAILABLE" | rofi -dmenu -i -p "Select Device to Pair")
        else
            DEVICE_SELECTED=$(echo "$AVAILABLE" | dmenu -i -p "Select Device to Pair")
        fi

        if [[ -n "$DEVICE_SELECTED" ]]; then
            MAC=$(echo "$DEVICE_SELECTED" | awk '{print $1}')
            bluetoothctl pair "$MAC"
            bluetoothctl trust "$MAC"
            bluetoothctl connect "$MAC"
        fi
    else
        # Extract device name and determine action
        DEVICE_NAME=$(echo "$SELECTED" | sed -E 's/^[✓ ]*//' | sed 's/ (Connect)//' | sed 's/ (Disconnect)//')

        # Find MAC address for this device
        MAC=$(echo "$PAIRED_DEVICES" | grep "$DEVICE_NAME" | awk '{print $1}')

        if [[ "$SELECTED" =~ "Disconnect" ]]; then
            bluetoothctl disconnect "$MAC"
        else
            bluetoothctl connect "$MAC"
        fi
    fi
}

bluetooth_menu
