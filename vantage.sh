#!/bin/sh

#Requirement: zenity, xinput, networkmanager, pulseaudio or pipewire-pulse
#Authors: Nizam (nizam@europe.com), Lanchon (https://github.com/Lanchon)

vpc="/sys/bus/platform/devices/VPC2004\:*"

get_conserv_mode_status() {
    cat $vpc/conservation_mode | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_usb_charging_status() {
    cat $vpc/usb_charging | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_fan_mode_status() {
    cat $vpc/fan_mode | awk '{
        if ($1 == "133" || $1 == "0") print "Status: Super Silent";
        else if ($1 == "1") print "Status: Standard";
        else if ($1 == "2") print "Status: Dust Cleaning";
        else if ($1 == "4") print "Status: Efficient Thermal Dissipation";
    }'
}

get_fn_lock_status() {
    cat $vpc/fn_lock | awk '{print ($1 == "1") ? "Status: Off" : "Status: On"}'
}

get_camera_status() {
    lsmod | grep -q 'uvcvideo' && echo "Status: On" || echo "Status: Off"
}

get_microphone_status() {
    pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print ($2 == "yes") ? "Status: Muted" : "Status: Active"}'
}

get_touchpad_status() {
    string="$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')"
    xinput --list-props "$string" | grep "Device Enabled" | cut -d ':' -f2 | awk '{print ($1 == "1") ? "Status: On" : "Status: Off"}'
}

get_wifi_status() {
    nmcli radio wifi | awk '{print ($1 == "enabled") ? "Status: On" : "Status: Off"}'
}

filter_status() {
    cut -d ' ' -f1 --complement
}

SUBMENU_ON="Activate"
SUBMENU_OFF="Deactivate"

show_submenu() {
    local title="$1"
    local status="$2"
    shift 2
    zenity --list --title "$title" --text "$status" --column "Menu" "$@"
}

show_submenu_on_off() {
    show_submenu "$@" "$SUBMENU_ON" "$SUBMENU_OFF"
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
        choice=$(show_submenu_on_off "Conservation Mode" "$(get_conserv_mode_status)")
        case "$choice" in
            "$SUBMENU_ON") echo "1" | pkexec tee $vpc/conservation_mode ;;
            "$SUBMENU_OFF") echo "0" | pkexec tee $vpc/conservation_mode ;;
        esac
        ;;
    "Always-On USB")
        choice=$(show_submenu_on_off "Always-On USB" "$(get_usb_charging_status)")
        case "$choice" in
            "$SUBMENU_ON") echo "1" | pkexec tee $vpc/usb_charging ;;
            "$SUBMENU_OFF") echo "0" | pkexec tee $vpc/usb_charging ;;
        esac
        ;;
    "Fan Mode")
        choice=$(show_submenu "Fan Mode" "$(get_fan_mode_status)" "Super Silent" "Standard" "Dust Cleaning" "Efficient Thermal Dissipation")
        case "$choice" in
            "Super Silent") echo "0" | pkexec tee $vpc/fan_mode ;;
            "Standard") echo "1" | pkexec tee $vpc/fan_mode ;;
            "Dust Cleaning") echo "2" | pkexec tee $vpc/fan_mode ;;
            "Efficient Thermal Dissipation") echo "4" | pkexec tee $vpc/fan_mode ;;
        esac
        ;;
    "FN Lock")
        choice=$(show_submenu_on_off "FN Lock" "$(get_fn_lock_status)")
        case "$choice" in
            "$SUBMENU_ON") echo "0" | pkexec tee $vpc/fn_lock ;;
            "$SUBMENU_OFF") echo "1" | pkexec tee $vpc/fn_lock ;;
        esac
        ;;
    "Camera")
        choice=$(show_submenu_on_off "Camera" "$(get_camera_status)")
        case "$choice" in
            "$SUBMENU_ON") pkexec modprobe uvcvideo ;;
            "$SUBMENU_OFF") pkexec modprobe -r uvcvideo ;;
        esac
        ;;
    "Microphone")
        choice=$(show_submenu "Microphone" "$(get_microphone_status)" "Mute" "Unmute")
        case "$choice" in
            "Mute") pactl set-source-mute @DEFAULT_SOURCE@ 1 ;;
            "Unmute") pactl set-source-mute @DEFAULT_SOURCE@ 0 ;;
        esac
        ;;
    "Touchpad")
        choice=$(show_submenu_on_off "Touchpad" "$(get_touchpad_status)")
        string="$(xinput list | grep Touchpad | cut -d '=' -f2 | awk '{print $1}')"
        case "$choice" in
            "$SUBMENU_ON") xinput enable "$string" ;;
            "$SUBMENU_OFF") xinput disable "$string" ;;
        esac
        ;;
    "WiFi")
        choice=$(show_submenu_on_off "WiFi" "$(get_wifi_status)")
        case "$choice" in
            "$SUBMENU_ON") nmcli radio wifi on ;;
            "$SUBMENU_OFF") nmcli radio wifi off ;;
        esac
        ;;
    *)
        exit
        ;;
esac

done
