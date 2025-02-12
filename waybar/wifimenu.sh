

#!/bin/bash

# List available Wi-Fi networks (SSID and BARS) using nmcli, ensuring SSIDs with spaces are captured correctly
networks=$(nmcli -t -f SSID,BARS device wifi list | grep -v '^--' | uniq)

# Use Wofi to display networks and allow selection
selected_network=$(echo "$networks" | wofi --dmenu --prompt "Select a Wi-Fi Network:" | cut -d ':' -f 1)

# If no network was selected, exit
if [ -z "$selected_network" ]; then
    echo "No network selected. Exiting..."
    exit 1
fi

# Use Wofi to ask for the Wi-Fi password
wifi_password=$(echo "" | wofi --dmenu --password --prompt "Enter password for $selected_network:")

# If no password was entered, exit
if [ -z "$wifi_password" ]; then
    echo "No password entered. Exiting..."
    exit 1
fi

# Connect to the selected network using nmcli
nmcli device wifi connect "$selected_network" password "$wifi_password"


# Check if the connection was successful
if [ $? -eq 0 ]; then
    notify-send -t 3000 "Connected" "Successfully connected to $selected_network"
else
    notify-send -t 3000 "Failed" "Failed to connect to $selected_network"
fi

