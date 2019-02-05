#!/bin/bash
## (C) 2019 Stefan Seyfried
## License: WTFPL-2.0
## This program is free software. It comes without any warranty, to
## the extent permitted by applicable law. You can redistribute it
## and/or modify it under the terms of the Do What The Fuck You Want
## To Public License, Version 2, as published by Sam Hocevar. See
## http://www.wtfpl.net/ for more details. */
#
# I experienced hard clipping with bluez / pulse a2dp sink, so this script
# sets the volume of all bluez sources to -3db.
# TODO: rewrite in some language with PA bindings, maybe python?
# Note: "pactl list sources" takes significantly longer than
#       "pacmd list-sources", so I changed it to use pacmd.

while ! pidof pulseaudio; do
	echo "waiting for pulseaudio"
	sleep 1;
done

#pactl list sources| sed -n '/Source #19$/,/^$/{/^[[:space:]]*Volume:/{s#^.*Volume:[^0-9]*\([0-9]\+\) / \+[0-9]\+%.*$#\1#;p}}'
## => show Volume after "Source #19" sed magic
set_volume() {
	local LONG NUM VOL BLUEZ
	#LONG="$(pactl list sources)"		# contains volume
	# Source #33
	#  State: RUNNING
	#  Name: bluez_source.XX_XX_XX_XX_XX_XX.a2dp_source
	#  Description: My Phone
	#  Driver: module-bluez5-device.c
	#  Sample Specification: s16le 2ch 44100Hz
	#  Channel Map: front-left,front-right
	#  Owner Module: 47
	#  Mute: no
	#  Volume: front-left: 58404 /  89% / -3.00 dB,   front-right: 58404 /  89% / -3.00 dB
	LONG="$(pacmd list-sources)"		# contains volume
	# index: 38
	#  name: <bluez_source.00_00_00_00_5A_AD.a2dp_source>
	#  driver: <module-bluez5-device.c>
	#  flags: HARDWARE DECIBEL_VOLUME LATENCY 
	#  state: RUNNING
	#  suspend cause: 
	#  priority: 9030
	#  volume: front-left: 58404 /  89% / -3.00 dB,   front-right: 58404 /  89% / -3.00 dB
	#          balance 0.00
	#BLUEZ=$(sed -n '/^Source #[0-9]\+/{s/^.*#//;h}; /Name: bluez/{x;p}' <<< "$LONG")
	BLUEZ=$(sed -n '/ index: [0-9]\+/{s/^.* //;h}; /name: <bluez/{x;p}' <<< "$LONG")
	for NUM in $BLUEZ; do
		#VOL=$(sed -n '/Source #'$NUM'$/,/^$/{/^[[:space:]]*Volume:/{s#^.*Volume:[^0-9]*\([0-9]\+\) / \+[0-9]\+%.*$#\1#;p}}' <<< "$LONG")
		VOL=$(sed -n '/ index: '$NUM'$/,/^$/{/^[[:space:]]*volume:/{s#^.*volume:[^0-9]*\([0-9]\+\) / \+[0-9]\+%.*$#\1#;p}}' <<< "$LONG")
		if [ "$VOL" != 58404 ]; then
			echo "adjust sink #$NUM from $VOL to 58404"
			pactl set-source-volume $NUM 58404 # -3db
		else
			echo "sink $NUM already at $VOL"
		fi
	done
}

## listen to PA events
# "pactl subscribe" output
#Event 'remove' on source #28
#Event 'change' on source #29
#Event 'new' on source #29
LAST=""
while read dummy EV dummy WHAT NUM dummy; do
	case $WHAT in
		source) ;;
		*) continue ;;
	esac
	case $EV in
		"'new'"|"'change'") ;;
		*) continue ;;
	esac
	if [ "$LAST" = "$NUM" ]; then
		printf "%-10s %-10s %-5s skipped\n" $EV $WHAT $NUM
		continue
	fi
	printf "%-10s %-10s %-5s\n" $EV $WHAT $NUM
	set_volume
	LAST="$NUM"
done < <(pactl subscribe)
