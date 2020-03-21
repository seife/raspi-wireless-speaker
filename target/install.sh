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
wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list

wget -q -O - https://www.lesbonscomptes.com/pages/jf-at-dockes.org.pgp | apt-key add -
echo "deb http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian/ buster main
#deb-src http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian/ buster main" > /etc/apt/sources.list.d/upmpdcli.list

apt update
apt upgrade
apt install pulseaudio-module-bluetooth pavucontrol paman paprefs gstreamer1.0-alsa gstreamer1.0-libav vim bluez-test-scripts bluez-test-tools bluez-tools python-dbus mopidy mopidy-mpd upmpdcli python3-pip

apt remove at-spi2-core
sed -i -e 's/^#Discoverable/Discoverable/' -e 's/^#Class.*/Class = 0x200414/' /etc/bluetooth/main.conf

###### this enables autologin on tty1 for user $SUDO_USER
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF
systemctl set-default multi-user.target
systemctl daemon-reload

### mopidy stuff
python3 -m pip install Mopidy-Mobile
python3 -m pip install Mopidy-MusicBox-Webclient

### upmpdcli
systemctl stop upmpdcli
sed -i -e "/^friendlyname/d;\$a\\\\nfriendlyname = $(hostname)" /etc/upmpdcli.conf
