#!/bin/bash

# WiFi menu selector using rofi
# Scan for networks
nmcli device wifi rescan 2>/dev/null
sleep 1

# Get list of available networks
networks=$(nmcli -f SSID,SECURITY,SIGNAL device wifi list | tail -n +2)

# Use rofi to select network (or dmenu as fallback)
if command -v rofi &> /dev/null; then
    selected=$(echo "$networks" | rofi -dmenu -i -p "Select WiFi Network")
else
    selected=$(echo "$networks" | dmenu -i -p "Select WiFi Network")
fi

if [[ -n "$selected" ]]; then
    # Extract SSID (first column)
    ssid=$(echo "$selected" | awk '{print $1}')

    # Check if network requires password
    security=$(echo "$selected" | awk '{print $2}')

    if [[ "$security" != "--" ]]; then
        # Network requires password
        if command -v rofi &> /dev/null; then
            password=$(rofi -dmenu -password -p "Enter password for $ssid")
        else
            password=$(echo "" | dmenu -p "Enter password for $ssid")
        fi

        if [[ -n "$password" ]]; then
            nmcli device wifi connect "$ssid" password "$password"
            if [[ $? -eq 0 ]]; then
                notify-send "WiFi" "Connected to $ssid"
            else
                notify-send "WiFi" "Failed to connect to $ssid"
            fi
        fi
    else
        # Open network, no password needed
        nmcli device wifi connect "$ssid"
        if [[ $? -eq 0 ]]; then
            notify-send "WiFi" "Connected to $ssid"
        else
            notify-send "WiFi" "Failed to connect to $ssid"
        fi
    fi
fi
