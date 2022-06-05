#!/bin/bash
# base variables for fdisk
efi=1
swap=2
root=3
size='M'
# get user vars
echo "Welcome to the Arch automated installer!"
echo "----------------------------------------"
sleep 3
clear
echo "Select a drive to install on: "
lsblk
read driveName
clear
echo "Please insert a password for the root user: "
read rootPass
clear
echo "Input the size of the EFI partition in mb"
read efiSize
echo "-------------------------------------------------"
echo "Input the size of the SWAP partition in mb"
read swapSize
echo "-------------------------------------------------"
echo "Input the size of the ROOT partition in mb"
read rootSize
clear
echo "Enter a hostname for your computer: "
read hostname
clear
echo "Please pick a display manager: "
echo "1) GDM"
echo "2) lightDM"
echo "3) SDDM"
echo "0) No Display Manager"
read displayMan
clear
echo "Please pick a desktop environment: "
echo "1) Gnome"
echo "2) KDE Plasma"
echo "3) Xfce4"
echo "4) Cutefish"
echo "5) Budgie"
echo "6) I3-wm"
echo "0) No environment (CLI ONLY!)"
read desktopEnv
# current variables rootPass driveName efiSize swapSize rootSize size hostname displayMan desktopEnv
