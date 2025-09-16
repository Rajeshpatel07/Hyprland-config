#!/usr/bin/env bash

# List of folders to copy from ~/.config
folders=("hypr" "waybar" "rofi" "mako" "kitty")

# Enable dotglob to include hidden files (like .git) in the copy.
# nullglob prevents errors if a source directory is empty.
shopt -s dotglob nullglob

echo "Starting configuration copy process..."
echo "-------------------------------------"

for folder in "${folders[@]}"; do
    # Define the source and destination directories
    source_dir="$HOME/.config/$folder"
    dest_dir="./$folder"

    # Check if the source directory exists and is not empty
    if [ -d "$source_dir" ] && [ "$(ls -A "$source_dir")" ]; then
        # Ensure the destination directory exists
        mkdir -p "$dest_dir"

        # Copy all contents from source to destination.
        # The -a flag (archive mode) is recursive, preserves file attributes, and is perfect for this.
        cp -a "$source_dir"/* "$dest_dir"/

        # Log a success message
        echo "✅ Copied: '$source_dir' -> '$dest_dir'"
    else
        # Log a warning if the source directory doesn't exist or is empty
        echo "⚠️  Skipped: '$source_dir' (not found or is empty)."
    fi
done

# Reset shell options for good practice
shopt -u dotglob nullglob

echo "-------------------------------------"
echo "Configuration copy process finished."
