
#!/bin/bash

# Check if yaak-app is already running
if pgrep -x "$1" > /dev/null; then
    # App is already running -> just move to workspace 4
    hyprctl dispatch workspace $2
else
    # App is NOT running -> launch and wait
    $1 &

    # Wait until yaak window appears
    while ! hyprctl clients | grep -i "$1" > /dev/null; do
        sleep 0.1
    done

    # (Optional) Move window to workspace 4 if needed
    hyprctl dispatch movetoworkspace $2
fi

