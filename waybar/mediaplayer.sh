
#!/bin/bash

# Get currently playing track information using playerctl
title=$(playerctl metadata title 2>/dev/null | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
player=$(playerctl -l | grep -m 1 '') # Gets the first available player

# Check if there’s a song playing
if [[ -z "$title" ]]; then
    echo "{\"text\": \"󰝛 No music playing\", \"class\": \"no-music\"}"
else
    # Output JSON with song title and player icon for Waybar
    echo "{\"text\": \"󰝚  $title\"}"
fi

