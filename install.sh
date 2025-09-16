#!/bin/bash

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
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

# Detect distribution and handle package installation
source /etc/os-release

packages=("hyprland" "waybar" "rofi" "mako" "kitty")
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
        log_info "Updating system packages..."
        sudo pacman -Syu --noconfirm &> /dev/null
        log_success "System packages updated."
        ;;
    ubuntu|debian)
        PM="apt"
        INSTALL_CMD="sudo apt install -y"
        CHECK_CMD="dpkg-query -W -f='\${Status}'"
        log_info "Detected Ubuntu/Debian-based system (${ID})."
        log_info "Adding universe repository and updating package lists..."
        sudo add-apt-repository universe -y &> /dev/null
        sudo apt update &> /dev/null
        log_success "Package lists updated."

        log_info "Installing non-Hyprland packages..."
        for pkg in waybar rofi mako kitty; do
            if ! ${CHECK_CMD} "${pkg}" 2>/dev/null | grep -q "ok installed"; then
                log_info "Installing ${pkg}..."
                if ${INSTALL_CMD} "${pkg}" &> /dev/null; then
                    log_success "${pkg} installed."
                else
                    log_error "Failed to install ${pkg}."
                fi
            else
                log_info "${pkg} is already installed. Skipping."
            fi
        done
        
        if ! ${CHECK_CMD} "hyprland" 2>/dev/null | grep -q "ok installed"; then
            log_info "Hyprland not found. Installing with automated script from GitHub..."
            cd /tmp || { log_error "Failed to change to /tmp directory. Aborting Hyprland install."; exit 1; }
            git clone https://github.com/JaKooLit/Ubuntu-Hyprland.git &> /dev/null
            if [ $? -eq 0 ]; then
                log_info "Hyprland repository cloned successfully."
                cd Ubuntu-Hyprland || { log_error "Failed to change to Ubuntu-Hyprland directory. Aborting."; exit 1; }
                chmod +x install.sh
                log_info "Running Hyprland install script. This may take a while..."
                ./install.sh
                cd - &> /dev/null
                log_success "Hyprland install script completed."
            else
                log_error "Failed to clone Hyprland repository. Aborting Hyprland install."
            fi
            cd - &> /dev/null
        else
            log_info "Hyprland is already installed. Skipping."
        fi
        ;;
    fedora)
        PM="dnf"
        INSTALL_CMD="sudo dnf install -y"
        CHECK_CMD="rpm -q"
        log_info "Detected Fedora."
        log_info "Updating system packages..."
        sudo dnf update -y &> /dev/null
        log_success "System packages updated."
        ;;
    *)
        log_error "Unsupported distribution: ${ID}. Please install packages manually."
        exit 1
        ;;
esac

log_info "Checking for and installing remaining packages..."
for pkg in "${packages[@]}"; do
    case $PM in
        pacman|dnf)
            if ! ${CHECK_CMD} "${pkg}" &> /dev/null; then
                log_info "Installing ${pkg}..."
                if ${INSTALL_CMD} "${pkg}" &> /dev/null; then
                    log_success "${pkg} installed."
                else
                    log_error "Failed to install ${pkg}. Check your repositories and internet connection."
                fi
            else
                log_info "${pkg} is already installed. Skipping."
            fi
            ;;
        apt)
            # Already handled in the case block, skip re-check
            ;;
    esac
done

log_success "Package installation and setup complete."
log_info "Proceeding with configuration directory management."

# Create directories in ~/.config if they don't exist
folders=("hypr" "waybar" "rofi" "mako" "kitty")
config_base="$HOME/.config"

for folder in "${folders[@]}"; do
    if [ ! -d "${config_base}/${folder}" ]; then
        log_info "Creating directory: ${config_base}/${folder}"
        mkdir -p "${config_base}/${folder}"
        log_success "Directory created."
    else
        log_info "Directory ${config_base}/${folder} already exists. Skipping."
    fi
done

log_success "All required directories exist in ~/.config."

# Swap contents between CWD and ~/.config
shopt -s dotglob nullglob

log_info "Starting configuration file swap. This will move files between your current directory and ~/.config."

for folder in "${folders[@]}"; do
    config_dir="${config_base}/${folder}"
    cwd_dir="./${folder}"
    temp_dir=$(mktemp -d "/tmp/swap_${folder}_XXXXXX")

    log_info "Processing configuration for: ${folder}"

    # Swap: move config to temp
    if [ "$(ls -A "$config_dir" 2>/dev/null)" ]; then
        log_info "Moving existing ${folder} config to temporary directory..."
        mv "$config_dir"/* "$temp_dir"/ &> /dev/null || true
    else
        log_warning "No existing config found in ${config_dir}. Nothing to move."
    fi

    # Move CWD to config
    if [ "$(ls -A "$cwd_dir" 2>/dev/null)" ]; then
        log_info "Moving local ${folder} files to ${config_dir}..."
        mv "$cwd_dir"/* "$config_dir"/ &> /dev/null || true
    else
        log_warning "No local files found in ${cwd_dir}. Nothing to move."
    fi

    # Move temp to CWD
    if [ "$(ls -A "$temp_dir" 2>/dev/null)" ]; then
        log_info "Restoring old config from temporary directory to ${cwd_dir}..."
        mv "$temp_dir"/* "$cwd_dir"/ &> /dev/null || true
        log_success "Config restored to ${cwd_dir}."
    fi

    # Cleanup
    rmdir "$temp_dir" &> /dev/null || true
    log_info "Temporary directory for ${folder} cleaned up."
done

shopt -u dotglob nullglob

log_success "Configuration swap completed successfully."
log_info "Setup script finished."
