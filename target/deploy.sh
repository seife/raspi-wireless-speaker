#!/bin/bash
## (C) 2019 Stefan Seyfried
## License: WTFPL-2.0
## This program is free software. It comes without any warranty, to
## the extent permitted by applicable law. You can redistribute it
## and/or modify it under the terms of the Do What The Fuck You Want
## To Public License, Version 2, as published by Sam Hocevar. See
## http://www.wtfpl.net/ for more details. */

set -e
ex_hook() {
        [ $? = 0 ] && exit 0
        echo "**********************"
        echo "SOMETHING WENT WRONG!!"
}
trap ex_hook EXIT

sudo ./install.sh
mkdir ~/.config || true
cp -avu systemd ~/.config/
cp -avu tools ~/
systemctl --user enable pulseaudio
#systemctl --user enable gmediarender
systemctl --user enable mopidy
systemctl --user enable mini-agent.service
systemctl --user enable bluez-volume.service

mopidy config
mv ~/.config/mopidy/mopidy.conf ~/.config/mopidy/mopidy.conf.default
cat > ~/.config/mopidy/mopidy.conf <<EOF
[audio]
mixer_volume = 33

[http]
hostname = 0.0.0.0

[m3u]
playlists_dir = ~/mopidy-playlists
EOF
mkdir ~/mopidy-playlists || true

## on machines without bluetooth this will take forever
timeout 10 bluetoothctl discoverable on || true
echo
echo
echo "no errors detected"
echo "now reboot and check if everything works"
echo
