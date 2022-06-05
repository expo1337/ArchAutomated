#!/bin/bash
source setup.sh
ls /sys/firmware/efi/efivars || { echo "You are not installing on EFI compatible hardware!" ; exit 1; }
clear
echo "Installing on EFI compatible hardware"
nc -z 1.1.1.1 53
net="$?"
if [ "$net" != "0" ]
then
	echo "No internet connection detected, installation can't proceed"
	exit 1
 fi
echo "Internet Connection Detected!"
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
    +$rootSize$size
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
pacstrap /mnt base linux linux-firmware sof-firmware neofetch vim nano neofetch base-devel networkmanager grub efibootmgr

#Gen fstab
genfstab -U /mnt >> /mnt/etc/fstab
clear

#Begin chroot installation

cp chroot.sh /mnt/chroot.sh
#rm /mnt/etc/locale.gen
#cp src/locale.gen /mnt/etc/locale.gen
echo "Please execute the second file with"
echo "chmod +x chroot.sh"
echo "./chroot.sh"
arch-chroot /mnt
# current variables ===== rootPass driveName efiSize swapSize rootSize size hostname displayMan desktopEnv efi swap root