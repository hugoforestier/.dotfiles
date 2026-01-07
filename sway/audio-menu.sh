#!/bin/bash

# Audio output menu selector using rofi
audio_menu() {
    # Get list of available sinks (stop at "Sink endpoints:")
    SINKS=$(wpctl status 2>/dev/null | sed -n '/Sinks:/,/Sink endpoints:/p' | grep "│.*[0-9]\." | grep -v "Sink endpoints")

    # Build menu options with current sink marked
    OPTIONS=""
    SINK_IDS=()

    while IFS= read -r sink; do
        # Skip empty lines
        [[ -z "$sink" ]] && continue

        # Extract sink ID and name
        SINK_ID=$(echo "$sink" | grep -oP '\s*[*\s]*\K[0-9]+(?=\.)')
        SINK_NAME=$(echo "$sink" | sed -E 's/.*[0-9]+\.\s+(.*)\s+\[vol:.*/\1/' | xargs)

        # Skip if no ID or name found
        [[ -z "$SINK_ID" || -z "$SINK_NAME" ]] && continue

        # Check if this is the default sink (marked with *)
        if echo "$sink" | grep -q "│.*\*"; then
            OPTIONS="$OPTIONS✓ $SINK_NAME
"
        else
            OPTIONS="$OPTIONS  $SINK_NAME
"
        fi
        SINK_IDS+=("$SINK_ID:$SINK_NAME")
    done <<< "$SINKS"

    # Show menu
    if command -v rofi &> /dev/null; then
        SELECTED=$(echo -n "$OPTIONS" | rofi -dmenu -i -p "Audio Output")
    else
        SELECTED=$(echo -n "$OPTIONS" | dmenu -i -p "Audio Output")
    fi

    if [[ -z "$SELECTED" ]]; then
        exit 0
    fi

    # Remove the checkmark/spaces prefix
    SELECTED_NAME=$(echo "$SELECTED" | sed 's/^[✓ ]*//')

    # Find the sink ID for the selected device
    for entry in "${SINK_IDS[@]}"; do
        ID="${entry%%:*}"
        NAME="${entry#*:}"
        if [[ "$NAME" == "$SELECTED_NAME" ]]; then
            # Set as default sink
            wpctl set-default "$ID"
            break
        fi
    done
}

audio_menu
