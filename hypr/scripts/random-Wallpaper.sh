#!/usr/bin/env bash

# Directory containing your wallpapers (adjust as needed)
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Get the path of the currently active wallpaper (assumes single monitor or uniform setup; see notes below)
CURRENT_WALL=$(hyprctl hyprpaper listactive | grep -oP '(?<=path: ).*' | head -1)

# Find a random image that's not the current one (supports common formats; add more if needed)
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    $( [ -n "$CURRENT_WALL" ] && echo ! -path "$CURRENT_WALL" ) | shuf -n 1)

# Apply via IPC (',' targets all monitors; use "<monitor_name>,<path>" for specific ones)
if [ -n "$WALLPAPER" ]; then
    hyprctl hyprpaper reload ",$WALLPAPER"
else
    notify-send "Error" "No wallpapers found in $WALLPAPER_DIR"
fi
