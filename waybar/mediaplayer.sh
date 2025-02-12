

#!/bin/bash

# Get metadata using playerctl
title=$(playerctl metadata title 2>/dev/null | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
artUrl=$(playerctl metadata 2>/dev/null | grep "mpris:artUrl" | sed 's/mpris:artUrl\s*//' | sed 's/^brave\s*//')

# Truncate the title to a maximum length
max_length=30
truncated_title="${title:0:$max_length}"
if [[ ${#title} -gt $max_length ]]; then
    truncated_title+="…"
fi

# Determine the icon and color based on playback status
if [[ -z "$title" ]]; then
    icon="󰝛 "  # Music note icon for off state
    color="#cccccc"
    truncated_title="no music"
    artPath="/path/to/default/image.png"  # Fallback image
else
    icon=" "  # Music note icon for on state
    color="#666666"

    # Use the artUrl as the image path
    if [[ -n "$artUrl" ]]; then
        artPath="$artUrl"
    else
        artPath="/path/to/default/image.png"  # Fallback image if artUrl is empty
    fi
fi

# Output JSON with image, text, and color for Waybar
echo "{\"img\":\"$artPath\", \"text\": \"$icon $truncated_title\"}"

