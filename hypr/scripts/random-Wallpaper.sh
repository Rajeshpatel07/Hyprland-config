#!/bin/bash

# Path to the folder containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Ensure the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Select a random image from the folder (excluding the current one if possible to avoid no-change)
CURRENT_WALL=$(hyprctl hyprpaper listactive | awk '{print $NF}' | head -n1 | xargs basename 2>/dev/null || echo "")
if [ -n "$CURRENT_WALL" ]; then
    RANDOM_IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) ! -name "$CURRENT_WALL" | shuf -n 1)
fi
# Fallback if no exclusion or empty
if [ -z "$RANDOM_IMAGE" ]; then
    RANDOM_IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)
fi

# Check if a random image was found
if [ -z "$RANDOM_IMAGE" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR."
    exit 1
fi

# Ensure hyprpaper is running (start if not)
if ! pgrep -x hyprpaper > /dev/null; then
    hyprpaper &
    sleep 0.5  # Brief wait for startup
fi

# Preload and set the wallpaper dynamically via hyprctl (applies to all monitors; unloads old automatically)
hyprctl hyprpaper preload "$RANDOM_IMAGE"
hyprctl hyprpaper wallpaper ,"$RANDOM_IMAGE"

# Print success message
echo "Wallpaper updated to: $RANDOM_IMAGE"
