#!/bin/sh
#Requirement: zenity, xinput, networkmanager, pulseaudio or pipewire-pulse
#Author: Nizam (nizam@europe.com)
export vpc="/sys/bus/platform/devices/VPC2004:*"

get_wifi_status() {
    nmcli radio wifi | awk '{print ($1 == "enabled") ? "Status: On" : "Status: Off"}'
}

get_conserv_mode_status() {
    cat $vpc/conservation_mode | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_camera_power_status() {
    lsmod | grep -q 'uvcvideo' && echo "Status: On" || echo "Status: Off"
}

get_fan_mode_status() {
    cat $vpc/fan_mode | awk '{
        if ($1 == "133" || $1 == "0") print "Status: Super Silent";
        else if ($1 == "1") print "Status: Standard";
        else if ($1 == "2") print "Status: Dust Cleaning";
        else if ($1 == "3") print "Status: Efficient Thermal Dissipation";
    }'
}

get_touchpad_status() {
    string=$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')
    xinput --list-props $string | grep "Device Enabled" | awk '{print ($3 == "1") ? "Status: On" : "Status: Off"}'
}

get_fn_lock_status() {
    cat $vpc/fn_lock | awk '{print ($1 == "1") ? "Status: Off" : "Status: On"}'
}

get_microphone_status() {
    pactl list | awk '/^Source/,/^$/{if ($1 == "Mute:" && $2 == "yes") print "Status: Muted"}' || echo "Status: Active"
}

file=$(zenity --height 350 --width 250 --list --title "Lenovo Vantage" --text "Choose one" \
--column Menu "Conservation Mode" "Touchpad" "FN Lock" "Camera Power" "Fan Mode" "Microphone" "WiFi" )

case "$file" in
    "Conservation Mode")
        choice=$(zenity --list --title "Conservation Mode" --text "$(get_conserv_mode_status)" --column Menu "Activate" "Deactivate")
        if [ "$choice" = "Activate" ]; then echo "1" | pkexec tee $vpc/conservation_mode
        else echo "0" | pkexec tee $vpc/conservation_mode; fi
        ;;
    "Camera Power")
        choice=$(zenity --list --title "Camera Power" --text "$(get_camera_power_status)" --column Menu "Activate" "Deactivate")
        if [ "$choice" = "Activate" ]; then pkexec modprobe uvcvideo
        else pkexec modprobe -r uvcvideo; fi
        ;;
    "Fan Mode")
        choice=$(zenity --list --title "Fan Mode" --text "$(get_fan_mode_status)" --column Menu "Super Silent" "Standard" "Dust Cleaning" "Efficient Thermal Dissipation")
        case "$choice" in
            "Super Silent") echo "0" | pkexec tee $vpc/fan_mode ;;
            "Standard") echo "1" | pkexec tee $vpc/fan_mode ;;
            "Dust Cleaning") echo "2" | pkexec tee $vpc/fan_mode ;;
            "Efficient Thermal Dissipation") echo "4" | pkexec tee $vpc/fan_mode ;;
        esac
        ;;
    "Touchpad")
        choice=$(zenity --list --title "Touchpad" --text "$(get_touchpad_status)" --column Menu "Activate" "Deactivate")
        string=$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')
        if [ "$choice" = "Activate" ]; then xinput enable $string
        else xinput disable $string; fi
        ;;
    "FN Lock")
        choice=$(zenity --list --title "FN Lock" --text "$(get_fn_lock_status)" --column Menu "Activate" "Deactivate")
        if [ "$choice" = "Activate" ]; then echo "0" | pkexec tee $vpc/fn_lock
        else echo "1" | pkexec tee $vpc/fn_lock; fi
        ;;
    "Microphone")
        choice=$(zenity --list --title "Microphone" --text "$(get_microphone_status)" --column Menu "Mute" "Unmute")
        if [ "$choice" = "Mute" ]; then pactl set-source-mute @DEFAULT_SOURCE@ 1
        else pactl set-source-mute @DEFAULT_SOURCE@ 0; fi
        ;;
    "WiFi")
        choice=$(zenity --list --title "WiFi" --text "$(get_wifi_status)" --column Menu "Activate" "Deactivate")
        if [ "$choice" = "Activate" ]; then nmcli radio wifi on
        else nmcli radio wifi off; fi
        ;;
esac
