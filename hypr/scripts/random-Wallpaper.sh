
#!/bin/bash

# Path to the folder containing wallpapers
WALLPAPER_DIR="$HOME/Downloads/Wallpaper-Bank/wallpapers"

# Path to Hyprpaper config file
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

# Ensure the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Ensure the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Hyprpaper config file not found: $CONFIG_FILE"
    exit 1
fi

# Select a random image from the folder
RANDOM_IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n 1)

# Check if a random image was found
if [ -z "$RANDOM_IMAGE" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR."
    exit 1
fi

# Update the Hyprpaper configuration
sed -i "s|^preload = .*|preload = $RANDOM_IMAGE|" "$CONFIG_FILE"
sed -i "s|^wallpaper = ,.*|wallpaper = ,$RANDOM_IMAGE|" "$CONFIG_FILE"

# Print success message
echo "Wallpaper updated to: $RANDOM_IMAGE"

# Reload Hyprland (optional if needed to apply changes immediately)
killall hyprpaper

hyprpaper
