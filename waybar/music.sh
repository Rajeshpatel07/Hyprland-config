
#!/bin/bash

# Retrieve the current song metadata
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
album=$(playerctl metadata album 2>/dev/null)
album_art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
status=$(playerctl status 2>/dev/null)

# Temporary directory for album art
temp_dir="/tmp/music_control"
mkdir -p "$temp_dir"

# If album art URL is available, download it to the temp folder
if [ -n "$album_art_url" ]; then
    wget -q -O "$temp_dir/album_art.jpg" "$album_art_url"
fi

# Function to display the album art (if available)
display_album_art() {
    if [ -f "$temp_dir/album_art.jpg" ]; then
        feh --scale-down --geometry 200x200 "$temp_dir/album_art.jpg" &
    else
        echo "No album art available."
    fi
}

# Display the album art in the background
display_album_art

# Prepare the Wofi menu with the current music status and options
menu=$(cat <<EOF
Now Playing: $artist - $title
Album: $album
Status: $status
---
Play
Pause
Stop
Next
Previous
Quit
EOF
)

# Show Wofi menu and capture the user's choice
choice=$(echo "$menu" | wofi --dmenu --prompt "Music Control")

# Handle the user input for controlling the music
case "$choice" in
    "Play")
        playerctl play
        ;;
    "Pause")
        playerctl pause
        ;;
    "Stop")
        playerctl stop
        ;;
    "Next")
        playerctl next
        ;;
    "Previous")
        playerctl previous
        ;;
    "Quit")
        echo "Exiting..."
        ;;
    *)
        echo "Invalid choice. Exiting..."
        ;;
esac

# Clean up temporary files
rm -rf "$temp_dir"

