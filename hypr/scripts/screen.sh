#!/bin/bash

# Simple script to toggle the laptop's built-in screen on/off in Hyprland
# Assumes your laptop screen is named "eDP-1" (most common)
# If it's different (check with `hyprctl monitors`), change the LAPTOP variable below
# When enabling, it uses the preferred resolution/rate, auto position (Hyprland places it intelligently, usually to the right), and scale 1

LAPTOP="eDP-1"

# Check if the laptop screen is currently active
if hyprctl monitors | grep -q "^Monitor $LAPTOP"; then
    # It's on → disable it (workspaces will move to external monitor)
    hyprctl keyword monitor "$LAPTOP,disable"
    # Optional: add a notification
    # notify-send "Laptop screen" "Disabled"
else
    # It's off → enable it
    hyprctl keyword monitor "$LAPTOP,preferred,auto,1"
    # Optional: add a notification
    # notify-send "Laptop screen" "Enabled"
fi
