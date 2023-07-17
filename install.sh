#!/bin/bash

# check for the distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID
fi

case $distro in
  "arch" | "manjaro")
    echo "Installing on Arch Linux or derivative"
    pacman -Qi zenity xorg-xinput networkmanager &> /dev/null || sudo pacman -S zenity xorg-xinput networkmanager
    ;;

  "ubuntu" | "debian" | "linuxmint" | "pop" | "elementary")
    echo "Installing on Debian or derivative"
    dpkg -s zenity xinput &> /dev/null || sudo apt install zenity xinput
    ;;

  "fedora")
    echo "Installing on Fedora"
    rpm -q zenity xinput NetworkManager pipewire-pulseaudio &> /dev/null || sudo dnf install zenity xinput NetworkManager pipewire-pulseaudio
    ;;

  *)
    echo "Unknown Distro, exiting."
    exit 1
    ;;
esac

echo "Requirements are installed"
