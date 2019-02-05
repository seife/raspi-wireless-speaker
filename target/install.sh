#!/bin/bash
## (C) 2019 Stefan Seyfried
## License: WTFPL-2.0
## This program is free software. It comes without any warranty, to
## the extent permitted by applicable law. You can redistribute it
## and/or modify it under the terms of the Do What The Fuck You Want
## To Public License, Version 2, as published by Sam Hocevar. See
## http://www.wtfpl.net/ for more details. */
#
# all the things that need root access...

if test -z "$SUDO_USER"; then
	echo
	echo "needs to be called via sudo..."
	echo
	exit 1
fi
set -e # exit on any error
apt update
apt upgrade
apt install pulseaudio-module-bluetooth gmediarender pavucontrol paman paprefs gstreamer1.0-alsa gstreamer1.0-libav vim bluez-test-scripts bluez-test-tools bluez-tools python-dbus
apt remove at-spi2-core
sed -i -e 's/^#Discoverable/Discoverable/' -e 's/^#Class.*/Class = 0x200414/' /etc/bluetooth/main.conf

###### this enables autologin on tty1 for user $SUDO_USER
# borrowed from raspi-config
systemctl set-default multi-user.target
sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin $SUDO_USER#"
ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
# end raspi-config
