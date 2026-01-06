#!/bin/bash

# Handle volume control clicks
handle_click() {
    case $1 in
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
}

# Check if we're being called to handle a click
if [[ -n "$BLOCK_BUTTON" ]]; then
    handle_click "$BLOCK_BUTTON"
    exit 0
fi

while true; do
    # Get volume information
    VOLUME_INFO=$(amixer get Master 2>/dev/null)
    VOLUME=$(echo "$VOLUME_INFO" | grep -o '\[[0-9]*%\]' | head -1 | tr -d '[]%')
    MUTED=$(echo "$VOLUME_INFO" | grep -o '\[off\]')
    
    # Choose volume icon based on level and mute status
    if [[ -n "$MUTED" ]]; then
        VOLUME_ICON="🔇"  # Muted
        VOLUME_TEXT="MUTE"
    elif [[ "$VOLUME" -ge 70 ]]; then
        VOLUME_ICON="🔊"  # High volume
        VOLUME_TEXT="$VOLUME%"
    elif [[ "$VOLUME" -ge 30 ]]; then
        VOLUME_ICON="🔉"  # Medium volume
        VOLUME_TEXT="$VOLUME%"
    else
        VOLUME_ICON="🔈"  # Low volume
        VOLUME_TEXT="$VOLUME%"
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
    
    echo "$VOLUME_ICON $VOLUME_TEXT  $BATTERY_ICON $BATTERY%  📅 $(date +'%Y-%m-%d %H:%M')"
    sleep 1
done
