# Lenovo Vantage for Linux
This shell script helps you to provide [Lenovo Vantage](https://www.lenovo.com/us/en/software/vantage) in GNU/Linux operating system.

## :rocket: Features
* Battery Conservation Mode (Charge battery to 60%)
* ~Rapid Charge~
* Thermal Mode (Quiet, Balanced and Performance mode)
  * ~GPU Overclocking in Performance Mode~
* ~Hybrid Mode (Disable integrated graphics)~
* FN Button
* Camera privacy switch
* Microphone privacy switch
* Touchpad Lock
* Wi-Fi switch

## :warning: Requirements
* `zenity`
* `xorg-xinput` or `xinput`
* `networkmanager`
* `pulseaudio` or `pipewire-pulse`


if they are not already installed, you can install them using your package manager.

For Arch Linux:
```bash
sudo pacman -S zenity xorg-xinput networkmanager
``` 
For Debian derivatives (Ubuntu, Mint, Pop!_OS, etc):
```bash
sudo apt install zenity xinput
```
For Fedora:
```bash
sudo dnf install zenity xinput NetworkManager pipewire-pulseaudio
```
## :computer: Installation

First of all, you need to clone the repository with this command:
```bash
git clone https://github.com/niizam/vantage.git
cd vantage
```
Then you can easily run this command:

```bash
chmod +x ./install.sh
sudo sh ./install.sh
```

## :hotsprings: Uninstall
To uninstall Lenovo Vantage, you can just run this:

```bash
chmod +x ./uninstall.sh
sudo sh ./uninstall.sh
```

---
