#!/bin/bash

# List of folders to swap (without trailing slashes)
folders=("hypr" "waybar" "rofi" "mako" "kitty")

# Enable dotglob to include hidden files in *
shopt -s dotglob nullglob

for folder in "${folders[@]}"; do
    config_dir="$HOME/.config/$folder"
    cwd_dir="./$folder"
    temp_dir=$(mktemp -d "/tmp/swap_${folder}_XXXXXX")

    # Create directories if they don't exist
    mkdir -p "$config_dir"
    mkdir -p "$cwd_dir"
    mkdir -p "$temp_dir"

    # Swap contents using temp:
    # Move config_dir contents to temp
    mv "$config_dir"/* "$temp_dir"/ 2>/dev/null || true

    # Move cwd_dir contents to config_dir
    mv "$cwd_dir"/* "$config_dir"/ 2>/dev/null || true

    # Move temp contents to cwd_dir
    mv "$temp_dir"/* "$cwd_dir"/ 2>/dev/null || true

    # Clean up temp
    rmdir "$temp_dir" 2>/dev/null || true
done

# Reset shopt if needed (though script ends here)
shopt -u dotglob nullglob

echo "Swapped contents of the specified folders between ~/.config and the current working directory."
