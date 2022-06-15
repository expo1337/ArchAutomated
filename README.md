<h1 align="center">
	<br>
	<a href="imagehere"></a>
	<br>
	Arch Automated Installer
	<br>
</h1>

<h4 align="center">Install and Configure as fast as possible.</h4>

<p align="center">
	<a href="#Overview">Overview</a>
	•
	<a href="#Installation">Installation</a>
	•
	<a href="#Features">Features</a>
</p>

# Overview

Fully automated command line script to install and configute arch linux as fast as possible with minimal user input. The installation script is well commented, feel free to edit it to your needs.

# Installation

1) Boot into Arch ISO installer
2) Update your repos using "pacman -Sy"
3) Download git using "pacman -S git"
4) Clone my repo using "git clone https://github.com/exp0420/ArchAutomated.git"
5) Navigate into the folder using "cd ArchAutomated"
6) Make the script executable using "chmod +x install.sh"
7) Finally, ececute the script using "./install.sh"
** The script will walk you through the next steps**

# Features

- selecting the target drive.
- using a custom hostname
- setting the root password and creating a new user
- formatting using fdisk
- automatically installing a desktop environment and a display manager
- decision between proprietary/open source drivers for nvidia gpu's

# Desktop Environments and Display Managers
**Environments available**

- Gnome
- KDE Plasma
- Budgie
- Xfce4
- Cutefish
- I3-wm
- I3-gaps
- Cinnamon

**Display Managers**

- GDM
- LightDM
- SDDM 

