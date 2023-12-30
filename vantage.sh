#!/bin/sh

#Requirement: zenity, xinput, networkmanager, pulseaudio or pipewire-pulse
#Authors: Nizam (nizam@europe.com), Lanchon (https://github.com/Lanchon)

vpc="/sys/bus/platform/devices/VPC2004\:*"

get_wifi_status() {
    nmcli radio wifi | awk '{print ($1 == "enabled") ? "Status: On" : "Status: Off"}'
}

get_conserv_mode_status() {
    cat $vpc/conservation_mode | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_usb_charging_status() {
    cat $vpc/usb_charging | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_camera_status() {
    lsmod | grep -q 'uvcvideo' && echo "Status: On" || echo "Status: Off"
}

get_fan_mode_status() {
    cat $vpc/fan_mode | awk '{
        if ($1 == "133" || $1 == "0") print "Status: Super Silent";
        else if ($1 == "1") print "Status: Standard";
        else if ($1 == "2") print "Status: Dust Cleaning";
        else if ($1 == "4") print "Status: Efficient Thermal Dissipation";
    }'
}

get_touchpad_status() {
    string="$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')"
    xinput --list-props "$string" | grep "Device Enabled" | cut -d ':' -f2 | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_fn_lock_status() {
    cat $vpc/fn_lock | awk '{print ($1 == "1") ? "Status: Off" : "Status: On"}'
}

get_microphone_status() {
    pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print ($2 == "yes") ? "Status: Muted" : "Status: Active"}'
}

filter_status() {
    cut -d ' ' -f1 --complement
}

while :; do

file=$(zenity --height 350 --width 350 --list --title "Lenovo Vantage" --text "Select function:" --column "Function" --column "Status" \
    "Conservation Mode" "$(get_conserv_mode_status | filter_status)" \
    "Always-On USB" "$(get_usb_charging_status | filter_status)" \
    "Fan Mode" "$(get_fan_mode_status | filter_status)" \
    "FN Lock" "$(get_fn_lock_status | filter_status)" \
    "Camera" "$(get_camera_status | filter_status)" \
    "Microphone" "$(get_microphone_status | filter_status)" \
    "Touchpad" "$(get_touchpad_status | filter_status)" \
    "WiFi" "$(get_wifi_status | filter_status)" \
)

case "$file" in
    "Conservation Mode")
        choice=$(zenity --list --title "Conservation Mode" --text "$(get_conserv_mode_status)" --column Menu "Activate" "Deactivate")
        case "$choice" in
            "Activate") echo "1" | pkexec tee $vpc/conservation_mode ;;
            "Deactivate") echo "0" | pkexec tee $vpc/conservation_mode ;;
        esac
        ;;
    "Always-On USB")
        choice=$(zenity --list --title "Always-On USB" --text "$(get_usb_charging_status)" --column Menu "Activate" "Deactivate")
        case "$choice" in
            "Activate") echo "1" | pkexec tee $vpc/usb_charging ;;
            "Deactivate") echo "0" | pkexec tee $vpc/usb_charging ;;
        esac
        ;;
    "Camera")
        choice=$(zenity --list --title "Camera" --text "$(get_camera_status)" --column Menu "Activate" "Deactivate")
        case "$choice" in
            "Activate") pkexec modprobe uvcvideo ;;
            "Deactivate") pkexec modprobe -r uvcvideo ;;
        esac
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
        string="$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')"
        case "$choice" in
            "Activate") xinput enable "$string" ;;
            "Deactivate") xinput disable "$string" ;;
        esac
        ;;
    "FN Lock")
        choice=$(zenity --list --title "FN Lock" --text "$(get_fn_lock_status)" --column Menu "Activate" "Deactivate")
        case "$choice" in
            "Activate") echo "0" | pkexec tee $vpc/fn_lock ;;
            "Deactivate") echo "1" | pkexec tee $vpc/fn_lock ;;
        esac
        ;;
    "Microphone")
        choice=$(zenity --list --title "Microphone" --text "$(get_microphone_status)" --column Menu "Mute" "Unmute")
        case "$choice" in
            "Mute") pactl set-source-mute @DEFAULT_SOURCE@ 1 ;;
            "Unmute") pactl set-source-mute @DEFAULT_SOURCE@ 0 ;;
        esac
        ;;
    "WiFi")
        choice=$(zenity --list --title "WiFi" --text "$(get_wifi_status)" --column Menu "Activate" "Deactivate")
        case "$choice" in
            "Activate") nmcli radio wifi on ;;
            "Deactivate") nmcli radio wifi off ;;
        esac
        ;;
    *)
        exit
        ;;
esac

done
