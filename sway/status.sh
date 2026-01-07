#!/bin/bash

# Handle clicks on different status bar elements
handle_click() {
    local element=$1
    local button=$2

    if [[ "$element" == "wifi" ]]; then
        case $button in
            1) # Left click on wifi - open wifi menu
                wifi_menu
                ;;
            3) # Right click on wifi - toggle wifi
                WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE device | grep wifi | cut -d: -f1 | head -1)
                if [[ -n "$WIFI_DEVICE" ]]; then
                    nmcli radio wifi toggle
                fi
                ;;
        esac
    elif [[ "$element" == "volume" ]]; then
        case $button in
            1) # Left click - toggle mute
                amixer set Master toggle > /dev/null
                ;;
            3) # Right click - open volume control (if available)
                if command -v pavucontrol &> /dev/null; then
                    pavucontrol &
                elif command -v alsamixer &> /dev/null; then
                    $TERMINAL -e alsamixer &
                fi
                ;;
            4) # Scroll up - increase volume
                amixer set Master 5%+ > /dev/null
                ;;
            5) # Scroll down - decrease volume
                amixer set Master 5%- > /dev/null
                ;;
        esac
    fi
}

# WiFi menu selector using rofi
wifi_menu() {
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
                password=$(dmenu -p "Enter password for $ssid" </dev/null)
            fi

            if [[ -n "$password" ]]; then
                nmcli device wifi connect "$ssid" password "$password"
            fi
        else
            # Open network, no password needed
            nmcli device wifi connect "$ssid"
        fi
    fi
}

# Check if we're being called to handle a click
# Note: For sway bar to support clicks, we need i3bar protocol
# This section is kept for potential i3blocks compatibility
if [[ -n "$BLOCK_BUTTON" ]]; then
    # Determine which element was clicked based on BLOCK_NAME
    handle_click "${BLOCK_NAME:-volume}" "$BLOCK_BUTTON"
    exit 0
fi

while true; do
    # Get wifi information
    WIFI_DEVICE=$(nmcli -t -f DEVICE,TYPE device | grep ':wifi$' | cut -d: -f1 | head -1)
    if [[ -n "$WIFI_DEVICE" ]]; then
        WIFI_STATE=$(nmcli -t -f DEVICE,STATE device | grep "^$WIFI_DEVICE:" | cut -d: -f2)
        if [[ "$WIFI_STATE" == "connected" ]]; then
            WIFI_SSID=$(nmcli -t -f ACTIVE,SSID device wifi | grep '^yes:' | cut -d: -f2)
            WIFI_SIGNAL=$(nmcli -t -f ACTIVE,SIGNAL device wifi | grep '^yes:' | cut -d: -f2)
            if [[ -n "$WIFI_SSID" ]]; then
                if [[ "$WIFI_SIGNAL" -ge 75 ]]; then
                    WIFI_ICON="📶"  # Strong signal
                elif [[ "$WIFI_SIGNAL" -ge 50 ]]; then
                    WIFI_ICON="📶"  # Medium signal
                elif [[ "$WIFI_SIGNAL" -ge 25 ]]; then
                    WIFI_ICON="📶"  # Weak signal
                else
                    WIFI_ICON="📶"  # Very weak signal
                fi
                WIFI_TEXT="$WIFI_ICON $WIFI_SSID"
            else
                WIFI_TEXT="📡 Disconnected"
            fi
        else
            WIFI_TEXT="📡 Disconnected"
        fi
    else
        WIFI_TEXT="📡 N/A"
    fi

    # Get bluetooth information
    if command -v bluetoothctl &> /dev/null; then
        BT_POWER=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
        if [[ "$BT_POWER" == "yes" ]]; then
            # Check if any device is connected
            BT_CONNECTED=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
            if [[ "$BT_CONNECTED" -gt 0 ]]; then
                BT_TEXT="🔵"  # Connected
            else
                BT_TEXT="🔵"  # On but not connected
            fi
        else
            BT_TEXT="⚫"  # Off
        fi
    else
        BT_TEXT=""  # Bluetooth not available
    fi

    # Get volume and audio output information
    VOLUME_INFO=$(amixer get Master 2>/dev/null)
    VOLUME=$(echo "$VOLUME_INFO" | grep -o '\[[0-9]*%\]' | head -1 | tr -d '[]%')
    MUTED=$(echo "$VOLUME_INFO" | grep -o '\[off\]')

    # Get current audio output device (PipeWire)
    if command -v wpctl &> /dev/null; then
        AUDIO_SINK=$(wpctl status 2>/dev/null | grep -A 20 "Sinks:" | grep "│.*\*" | head -1 | sed -E 's/.*\*\s+[0-9]+\.\s+(.*)\s+\[vol:.*/\1/' | xargs)
        # Shorten common device names for display
        case "$AUDIO_SINK" in
            *"HDMI"*|*"DisplayPort"*)
                AUDIO_OUTPUT="HDMI"
                ;;
            *"Analog Stereo"*)
                # Extract device name before "Analog Stereo"
                DEVICE_NAME=$(echo "$AUDIO_SINK" | sed 's/ Analog Stereo//')
                AUDIO_OUTPUT="$DEVICE_NAME"
                ;;
            *"Headphones"*)
                AUDIO_OUTPUT="HP"
                ;;
            *"Speaker"*)
                AUDIO_OUTPUT="SPK"
                ;;
            *"AirPods"*)
                AUDIO_OUTPUT="AirPods"
                ;;
            *"fifine"*)
                AUDIO_OUTPUT="fifine"
                ;;
            *)
                # Truncate long names to first 12 chars
                AUDIO_OUTPUT=$(echo "$AUDIO_SINK" | cut -c1-12)
                ;;
        esac
    else
        AUDIO_OUTPUT=""
    fi

    # Choose volume icon based on level and mute status
    if [[ -n "$MUTED" ]]; then
        VOLUME_ICON="🔇"  # Muted
        if [[ -n "$AUDIO_OUTPUT" ]]; then
            VOLUME_TEXT="MUTE ($AUDIO_OUTPUT)"
        else
            VOLUME_TEXT="MUTE"
        fi
    elif [[ "$VOLUME" -ge 70 ]]; then
        VOLUME_ICON="🔊"  # High volume
        if [[ -n "$AUDIO_OUTPUT" ]]; then
            VOLUME_TEXT="$VOLUME% ($AUDIO_OUTPUT)"
        else
            VOLUME_TEXT="$VOLUME%"
        fi
    elif [[ "$VOLUME" -ge 30 ]]; then
        VOLUME_ICON="🔉"  # Medium volume
        if [[ -n "$AUDIO_OUTPUT" ]]; then
            VOLUME_TEXT="$VOLUME% ($AUDIO_OUTPUT)"
        else
            VOLUME_TEXT="$VOLUME%"
        fi
    else
        VOLUME_ICON="🔈"  # Low volume
        if [[ -n "$AUDIO_OUTPUT" ]]; then
            VOLUME_TEXT="$VOLUME% ($AUDIO_OUTPUT)"
        else
            VOLUME_TEXT="$VOLUME%"
        fi
    fi

    BATTERY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
    STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "")

    # Choose battery icon based on level and status
    if [[ "$STATUS" == "Charging" ]]; then
        BATTERY_ICON="🔌"  # Charging icon
    elif [[ "$BATTERY" -ge 90 ]]; then
        BATTERY_ICON="🔋"  # Full battery
    elif [[ "$BATTERY" -ge 70 ]]; then
        BATTERY_ICON="🔋"  # 70-90%
    elif [[ "$BATTERY" -ge 50 ]]; then
        BATTERY_ICON="🔋"  # 50-70%
    elif [[ "$BATTERY" -ge 30 ]]; then
        BATTERY_ICON="🔋"  # 30-50%
    elif [[ "$BATTERY" -ge 10 ]]; then
        BATTERY_ICON="🪫"  # 10-30%
    else
        BATTERY_ICON="🪫"  # <10% (critical)
    fi

    echo "$WIFI_TEXT  $BT_TEXT  $VOLUME_ICON $VOLUME_TEXT  $BATTERY_ICON $BATTERY%  📅 $(date +'%Y-%m-%d %H:%M')"
    sleep 1
done
