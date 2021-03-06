#!/bin/bash
# base variables for fdisk
efi=1
swap=2
root=3
size='M'
# get user vars
echo "----------------------------------------"
echo "Welcome to the Arch automated installer!"
echo "----------------------------------------"
sleep 3
clear
echo "Input the name of the drive to install on: "
lsblk
echo "-------------------------------------------"
read driveName
clear
echo "Please enter a hostname for the computer: "
read hostname
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
echo "7) I3-gaps"
echo "8) Cinnamon"
echo "0) No environment (CLI ONLY!)"
read desktopEnv
clear
echo "Use proprietary drivers? (NVIDIA ONLY) y/n"
read drivers
clear
echo "Please enter an username for the new user: "
read username
clear
echo "Please enter a password for the new user: "
read password
# Check for EFI Variables - determine the system efi support
ls /sys/firmware/efi/efivars || { echo "You are not installing on EFI compatible hardware!" ; exit 1; }
clear
echo "Installing on EFI compatible hardware"
# Test internet connection
nc -z 1.1.1.1 53
net="$?"
if [ "$net" != "0" ]
then
	echo "No internet connection detected, installation can't proceed"
	exit 1
 fi
echo "Internet Connection Detected!"
#Sync time
timedatectl set-ntp true

#Fdisk Autopart
partition() {
	wipefs --all --force /dev/$driveName
	clear
	fdisk /dev/$driveName << EOF
	g
	n
	1
	
	+$efiSize$size
	n
	2
	
	+$swapSize$size
	n
	3
    

	t
	1
	1
	t
	2
	19
	w
EOF
}
partition

#Formatting
mkfs.fat -F 32 /dev/$driveName$efi
mkswap /dev/$driveName$swap
mkfs.ext4 /dev/$driveName$root

#Mounting Partitions
mount /dev/$driveName$root /mnt
mkdir -p /mnt/boot/efi
mount /dev/$driveName$efi /mnt/boot/efi
swapon /dev/$driveName$swap

#Base package install
pacstrap /mnt base linux linux-firmware sof-firmware neofetch vim nano neofetch base-devel networkmanager grub efibootmgr git

#Get desktop env
case $desktopEnv in

  1)
    echo -n "Gnome"
    installDE="gnome.sh"
    cp desktopInstall/gnome.sh /mnt
	;;

  2)
    echo -n "KDE Plasma"
	installDE="kde.sh"
    cp desktopInstall/kde.sh /mnt
    ;;

  3)
    echo -n "Xfce"
	installDE="xfce4.sh"
    cp desktopInstall/xfce4.sh /mnt
    ;;
  
  4)
    echo -n "Cutefish"
	installDE="cutefish.sh"
    cp desktopInstall/cutefish.sh /mnt
    ;;
  
  5)
    echo -n "Budgie"
	installDE="budgie.sh"
	cp desktopInstall/budgie.sh /mnt
    ;;
  6)
    echo -n "i3-wm"
	installDE="i3wm.sh"
	cp desktopInstall/i3wm.sh /mnt
	;;
  7)
    echo -n "i3-gaps"
	installDE="i3gaps.sh"
	cp desktopInstall/i3gaps.sh /mnt
	;;
  8)
    echo -n "Cinnamon"
	installDE="cinnamon.sh"
	cp desktopInstall/cinnamon.sh /mnt
	;;
  *)
    echo -n "No DE installed"
    ;;
esac
# Get Display manager
case $displayMan in

	1)
	  echo -n "GDM"
	  pacstrap /mnt gdm
	  dpMan='gdm'
	  ;;
	
	2)
	  echo -n "LightDM"
	  pacstrap /mnt lightdm-gtk-greeter lightdm
	  dpMan='lightdm'
	  ;;

	3)
	  echo -n "SDDM"
	  pacstrap /mnt sddm
	  dpMan='sddm'
	  ;;
	*)
	  echo -n "No Display Manager installed"
esac

# Copy utils
if [ "$drivers" == "y" ]; then
	cp desktopInstall/nvidia.sh /mnt/nvidia.sh
else 
	echo "Using Open Source drivers!"
fi
#Gen fstab
genfstab -U /mnt >> /mnt/etc/fstab
clear

#Begin chroot installation
arch-chroot /mnt << EOF
	chmod +x $installDE
	./$installDE
	ln -sf /usr/share/zoneinfo/Europe/Bratislava /etc/localtime
	echo 'LANG=en_US.UTF-8' >> /etc/locale.conf
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	hwclock --systohc
	useradd -m -G wheel -s /bin/bash $username
	sh -c 'echo $username:'$password' | chpasswd'
	echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
	systemctl enable NetworkManager
	systemctl enable $dpMan
	grub-install /dev/$driveName
	grub-mkconfig -o /boot/grub/grub.cfg
	mkdir /boot/efi/EFI/BOOT
	cp /boot/efi/EFI/arch/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
	echo "LANG=en_US.UTF-8" >> /etc/locale.conf
	echo $hostname >> /etc/hostname
	sh -c 'echo root:'$rootPass' | chpasswd'
	chmod +x nvidia.sh
	./nvidia.sh
	rm nvidia.sh
	clear
	neofetch
EOF
if [ "$hostname" == "nyarch" ]; then
	mkdir /mnt/home/$username/.wallpapers
	cp desktopInstall/wallpaper.png /mnt/home/$username/.wallpapers/wallpaper.png
fi

umount -a
reboot
# current variables ===== rootPass driveName efiSize swapSize rootSize size hostname displayMan desktopEnv efi swap root
