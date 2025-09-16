#!/usr/bin/env bash

# --- Color Definitions & Logging Functions ---
# Provides a clear, colorful output for script progress.
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# --- Main Script Logic ---

# Enable dotglob to include hidden files (like .git) and nullglob to prevent errors if a source is empty.
shopt -s dotglob nullglob

log_info "Starting one-way configuration copy..."
echo "--------------------------------------------------"

# --- Part 1: Copy configuration folders to ~/.config ---
config_folders=("hypr" "waybar" "rofi" "mako" "kitty")
config_dest_base="$HOME/.config"

for folder in "${config_folders[@]}"; do
    source_dir="./${folder}"
    dest_dir="${config_dest_base}/${folder}"

    log_info "Processing: ${folder}"
    
    # Check if the source directory exists in the current location
    if [ -d "$source_dir" ]; then
        log_info "  -> Source:      '${source_dir}'"
        log_info "  -> Destination: '${dest_dir}'"
        
        # Ensure the destination directory exists
        mkdir -p "$dest_dir"

        # Copy all contents from source to destination using archive mode (-a)
        if cp -a "$source_dir"/* "$dest_dir"/; then
            log_success "Successfully copied contents of '${folder}'."
        else
            log_error "An error occurred while copying '${folder}'."
        fi
    else
        log_warning "Source directory '${source_dir}' not found. Skipping."
    fi
    echo # Add a blank line for readability
done

# --- Part 2: Copy wallpapers to ~/Pictures ---
wallpaper_source="./wallpapers"
wallpaper_dest="$HOME/Pictures"

log_info "Processing: wallpapers"

if [ -d "$wallpaper_source" ]; then
    log_info "  -> Source:      '${wallpaper_source}'"
    log_info "  -> Destination: '${wallpaper_dest}'"

    # Ensure the destination ~/Pictures directory exists
    mkdir -p "$wallpaper_dest"
    
    # Copy the entire 'wallpapers' folder into ~/Pictures
    if cp -a "$wallpaper_source" "$wallpaper_dest"/; then
        log_success "Successfully copied wallpapers."
    else
        log_error "An error occurred while copying wallpapers."
    fi
else
    log_warning "Source directory '${wallpaper_source}' not found. Skipping."
fi
echo # Add a blank line for readability

# --- Cleanup ---
shopt -u dotglob nullglob
echo "--------------------------------------------------"
log_success "Script finished. All configurations have been copied."
