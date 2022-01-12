#!/bin/sh
#Requirement: zenity, xinput, networkmanager, pulseaudio or pipewire-pulse
#Author: Nizam (nizam@europe.com)

export vpc="/sys/bus/platform/devices/VPC2004:*"
file=$(zenity --height 350 --width 250 --list --title "Lenovo Vantage" --text "Choose one" \
--column Menu "Conservation Mode" "Touchpad" "FN Lock" "Camera Power" "Fan Mode" "Microphone" "WiFi" )

rdio=$(nmcli radio wifi)
rdstatus=$(if [ "$rdio" = "enabled" ]; then
    echo "Status: On"
else
    echo "Status: Off"
fi
)

cm=$(cat $vpc/conservation_mode)
cmstatus=$(if [ "$cm" = "1" ]; then
    echo "Status: On"
else
    echo "Status: Off"
fi
)

cpwr=$(lsmod | grep 'uvcvideo')
cpstatus=$(if [ "$cpwr" = "" ]; then
    echo "Status: Off"
else
    echo "Status: On"
fi
)

fanmd=$(cat $vpc/fan_mode)
fmstatus=$(if [ "$fanmd" = "133" ]; then
    echo "Status: Super Silent"
elif [ "$fanmd" = "0" ]; then
    echo "Status: Super Silent"
elif [ "$fanmd" = "1" ]; then
    echo "Status: Standard"
elif [ "$fanmd" = "2" ]; then
    echo "Status: Dust Cleaning"
elif [ "$fanmd" = "3" ]; then
    echo "Status: Efficient Thermal Dissipation"
fi
)

string=$(xinput list | grep Touchpad | cut -d '=' -f2 | awk  '{print $1}')
toupd=$(xinput --list-props $string | grep "Device Enabled" | cut -d ":" -f2 | awk '{print $1}')
tpstatus=$(if [ "$toupd" = "1" ]; then
    echo "Status: On"
else
    echo "Status: Off"
fi
)

fnlc=$(cat $vpc/fn_lock)
fnstatus=$(if [ "$fnlc" = "1" ]; then
    echo "Status: Off"
else
    echo "Status: On"
fi
)

mcphn=$(pactl list | sed -n '/^Source/,/^$/p' | grep "Mute: yes" | cut -d ":" -f2 | awk '{print $1}')
micstatus=$(if [ "$mcphn" = "yes" ]; then
    echo "Status: Muted"
else
    echo "Status: Active"
fi
)

if [ "$file" = "Conservation Mode" ]; then
    conservation=$(zenity --list --title "Conservation Mode" --text "$cmstatus" --column Menu "Activate" "Deactivate")
elif [ "$file" = "Camera Power" ]; then
    camerapwr=$(zenity --list --title "Camera Power" --text "$cpstatus" --column Menu "Activate" "Deactivate")
elif [ "$file" = "Fan Mode" ]; then
    fanmode=$(zenity --list --title "Fan Mode" --text "$fmstatus" --column Menu "Super Silent" "Standard" "Dust Cleaning" "Efficient Thermal Dissipation")
elif [ "$file" = "Touchpad" ]; then
    tcpd=$(zenity --list --title "Touchpad" --text "$tpstatus" --column Menu "Activate" "Deactivate")
elif [ "$file" = "FN Lock" ]; then
    fnlck=$(zenity --list --title "FN Lock" --text "$fnstatus" --column Menu "Activate" "Deactivate")
elif [ "$file" = "Microphone" ]; then
    mcrph=$(zenity --list --title "Microphone" --text "$micstatus" --column Menu "Mute" "Unmute")
elif [ "$file" = "WiFi" ]; then
    wfi=$(zenity --list --title "FN Lock" --text "$rdstatus" --column Menu "Activate" "Deactivate")
fi

if [ "$conservation" = "Activate" ]; then
    echo "1" | pkexec tee $vpc/conservation_mode
elif [ "$conservation" = "Deactivate" ]; then
    echo "0" | pkexec tee $vpc/conservation_mode
fi

if [ "$camerapwr" = "Activate" ]; then
    echo "1" | pkexec modprobe uvcvideo
elif [ "$camerapwr" = "Deactivate" ]; then
    echo "0" | pkexec modprobe -r uvcvideo
fi

if [ "$fanmode" = "Super Silent" ]; then
    echo "0" | pkexec tee $vpc/fan_mode
elif [ "$fanmode" = "Standard" ]; then
    echo "1" | pkexec tee $vpc/fan_mode
elif [ "$fanmode" = "Dust Cleaning" ]; then
    echo "2" | pkexec tee $vpc/fan_mode
elif [ "$fanmode" = "Efficient Thermal Dissipation" ]; then
    echo "4" | pkexec tee $vpc/fan_mode
fi

if [ "$tcpd" = "Activate" ]; then
    xinput enable $string
elif [ "$tcpd" = "Deactivate" ]; then
    xinput disable $string
fi

if [ "$fnlck" = "Deactivate" ]; then
    echo "1" | pkexec tee $vpc/fn_lock
elif [ "$fnlck" = "Activate" ]; then
    echo "0" | pkexec tee $vpc/fn_lock
fi

if [ "$mcrph" = "Mute" ]; then
    pactl set-source-mute @DEFAULT_SOURCE@ 1
elif [ "$mcrph" = "Unmute" ]; then
    pactl set-source-mute @DEFAULT_SOURCE@ 0
fi

if [ "$wfi" = "Activate" ]; then
    nmcli radio wifi on
elif [ "$wfi" = "Deactivate" ]; then
    nmcli radio wifi off
fi

clear
