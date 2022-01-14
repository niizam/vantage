# Lenovo Vantage for Linux
This shell script helps you to provide Lenovo Vantage in GNU/Linux operating system.

## :rocket: Features
* Camera power
* Battery conservation mode
* Fan Mode
* FN Button
* Microphone
* Touchpad
* WiFi

## :warning: Requirements
* `zenity`
* `xorg-xinput` or `xinput`
* `networkmanager`
* `pulseaudio` or `pipewire-pulse`


if they are not already installed you can install them using your package manager for example in arch Linux
```bash
sudo pacman -S zenity xorg-xinput networkmanager
``` 

## :computer: Installation

first of all, you need to clone the repository with this command:
```bash
git clone https://github.com/niizam/vantage.git
cd vantage
```
then you can give `vantage.sh` permission and copy the script to your bin directory

```bash
sudo cp ./vantage.sh /usr/bin/vantage
sudo chmod a+rx /usr/bin/vantage
```

## :hotsprings: Uninstall
to uninstall vantage you can easily delete the script

```bash
sudo rm /usr/bin/vantage
```

---
