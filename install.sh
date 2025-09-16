#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# SETUP AND LOGGING
# -----------------------------------------------------------------------------

# Define colors for log messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions for clear, colored output
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

# -----------------------------------------------------------------------------
# PACKAGE INSTALLATION
# -----------------------------------------------------------------------------

# Ensure the script exits if a command fails
set -e

# List of essential packages for the setup
packages=("hyprland" "waybar" "rofi" "mako" "kitty" "unzip" "git")

log_info "Starting the setup process..."
source /etc/os-release
PM=""
INSTALL_CMD=""
CHECK_CMD=""

log_info "Detecting Linux distribution..."
case "${ID,,}" in
    arch|manjaro)
        PM="pacman"
        INSTALL_CMD="sudo pacman -S --needed --noconfirm"
        CHECK_CMD="pacman -Q"
        log_info "Detected Arch-based system (${ID})."
        ;;
    ubuntu|debian)
        PM="apt"
        INSTALL_CMD="sudo apt install -y"
        CHECK_CMD="dpkg-query -W -f='\${Status}'"
        log_info "Detected Ubuntu/Debian-based system (${ID})."
        log_info "Updating package lists..."
        sudo add-apt-repository universe -y >/dev/null 2>&1
        sudo apt update >/dev/null 2>&1
        log_success "Package lists updated."
        ;;
    fedora)
        PM="dnf"
        INSTALL_CMD="sudo dnf install -y"
        CHECK_CMD="rpm -q"
        log_info "Detected Fedora."
        ;;
    *)
        log_error "Unsupported distribution: ${ID}. Please install packages manually."
        exit 1
        ;;
esac

log_info "Checking for and installing required packages..."
for pkg in "${packages[@]}"; do
    is_installed=false
    # Use the appropriate check command for the detected package manager
    case $PM in
        pacman|dnf)
            if ${CHECK_CMD} "${pkg}" &> /dev/null; then is_installed=true; fi
            ;;
        apt)
            if ${CHECK_CMD} "${pkg}" 2>/dev/null | grep -q "ok installed"; then is_installed=true; fi
            ;;
    esac

    if $is_installed; then
        log_info "${pkg} is already installed. Skipping."
    else
        log_info "Installing ${pkg}..."
        if ${INSTALL_CMD} "${pkg}" >/dev/null 2>&1; then
            log_success "${pkg} installed."
        else
            log_error "Failed to install ${pkg}. Please check your repositories."
        fi
    fi
done
log_success "All required packages are installed."

# -----------------------------------------------------------------------------
# CONFIGURATION COPY
# -----------------------------------------------------------------------------

# Enable dotglob to include hidden files in copy operations
shopt -s dotglob nullglob

config_folders=("hypr" "waybar" "rofi" "mako" "kitty")
config_dest_base="$HOME/.config"

log_info "Starting one-way copy of configurations to ${config_dest_base}..."

for folder in "${config_folders[@]}"; do
    source_dir="./${folder}"
    dest_dir="${config_dest_base}/${folder}"

    log_info "Processing '${folder}'..."
    # Check if the source directory exists in the current location
    if [ -d "${source_dir}" ]; then
        # Ensure the destination directory exists
        mkdir -p "${dest_dir}"
        
        # Copy contents from source to destination using archive mode
        log_info "Copying '${source_dir}' to '${dest_dir}'..."
        cp -a "${source_dir}/"* "${dest_dir}/"
        log_success "Successfully copied files for '${folder}'."
    else
        log_warning "Source directory '${source_dir}' not found. Skipping."
    fi
done

# -----------------------------------------------------------------------------
# WALLPAPER SETUP
# -----------------------------------------------------------------------------

zip_file="./wallpapers.zip"
wallpaper_dest_dir="$HOME/Pictures/wallpapers"

log_info "Setting up wallpapers..."
if [ -f "$zip_file" ]; then
    log_info "Found ${zip_file}. Unzipping to ${wallpaper_dest_dir}..."
    mkdir -p "$wallpaper_dest_dir"
    # Unzip, overwriting existing files without prompting (-o)
    unzip -o "$zip_file" -d "$wallpaper_dest_dir" >/dev/null 2>&1
    log_success "Wallpapers have been unzipped successfully."
else
    log_warning "${zip_file} not found in the current directory. Skipping wallpaper setup."
fi

# -----------------------------------------------------------------------------
# FINALIZATION
# -----------------------------------------------------------------------------

# Disable dotglob
shopt -u dotglob nullglob

log_success "Setup script has finished successfully!"
