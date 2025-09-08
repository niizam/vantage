#!/bin/bash

# Function to detect package manager
detect_package_manager() {
    if command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

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
  
  # Entry for Linux Mint 21.3 Edge
  "ubuntu debian")
    echo "Installing on Linux Mint Edge"
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
    echo "Unknown Distro, attempting package manager detection..."
    package_manager=$(detect_package_manager)
    
    case $package_manager in
        "pacman")
            echo "Detected pacman package manager"
            pacman -Qi zenity xorg-xinput networkmanager &> /dev/null || sudo pacman -S zenity xorg-xinput networkmanager
            ;;
        "apt")
            echo "Detected apt package manager"
            dpkg -s zenity xinput &> /dev/null || sudo apt install zenity xinput
            ;;
        "dnf")
            echo "Detected dnf package manager"
            rpm -q zenity xinput NetworkManager pipewire-pulseaudio &> /dev/null || sudo dnf install zenity xinput NetworkManager pipewire-pulseaudio
            ;;
        "zypper")
            echo "Detected zypper package manager"
            rpm -q zenity xinput NetworkManager pipewire-pulseaudio &> /dev/null || sudo zypper install zenity xinput NetworkManager pipewire-pulseaudio
            ;;
        *)
            echo "Unable to detect compatible package manager, exiting."
            exit 1
            ;;
    esac
    ;;
esac

echo "Requirements are installed"
