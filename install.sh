#!/bin/bash

# check for the distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID_LIKE

    # Some distros like Fedora doesn't have "ID_LIKE" in their /etc/os-release file, sadly
    if [ -z "$distro" ]; then
        distro=$ID
    fi
fi

case $distro in
  # Now Vantage can be installed on Cachy OS, ArcoLinux... you name it!
  "arch")
    echo "Installing on Arch Linux or derivative"
    pacman -Qi zenity xorg-xinput networkmanager &> /dev/null || sudo pacman -S zenity xorg-xinput networkmanager
    ;;

  # Now Vantage can not only be installed on Ubuntu or POP OS but also Kubuntu, KDE Neon, Xubuntu...
  "debian")
    echo "Installing on Debian or derivative"
    dpkg -s zenity xinput &> /dev/null || sudo apt install zenity xinput
    ;;

  "fedora")
    echo "Installing on Fedora"
    rpm -q zenity xinput NetworkManager pipewire-pulseaudio &> /dev/null || sudo dnf install zenity xinput NetworkManager pipewire-pulseaudio
    ;;

    "opensuse-tumbleweed")
    echo "Installing on OpenSuse"
    rpm -q zenity xinput NetworkManager pipewire-pulseaudio &> /dev/null || sudo zypper install zenity xinput NetworkManager pipewire-pulseaudio
    ;;

  *)
    echo "Unknown Distro, exiting."
    exit 1
    ;;
esac

echo "Requirements are installed"
