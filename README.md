# Raspberry PI wireless speaker

I created this to use a Raspberry Pi Zero W together with a pair of speakers
that already contain an USB sound card (Alesis iM1Active 520USB) for audio playback via both UPNP/DLNA and Bluetooth A2DP.

Manual configuration of such a setup is quite simple, but this somewhat automates and documents it.

This was tested on the base of `2020-02-13-raspbian-buster-lite`.
`upmpdcli` is used as UPNP renderer, `mopidy` as media player backend, `pulseaudio` for bluetooth A2DP.
Some additional stuff (pavucontrol...) is installed to allow easy setup via SSH / X-Forwarding.

To apply the configuration, just do the following:
   * write `2020-02-13-raspbian-buster-lite.img` to a SDCard
   * mount partition 1 of the SD card, `touch /mnt/ssh`, this enables sshd on first boot.
   * Connect HDMI Display and Keyboard to the PI, boot up the SD card.
   * Log on, `sudo raspi-config`. Configure the following to your needs:
      * Wireless Lan
      * Hostname (This hostname is used for the Bluetooth name and for the UPNP friendly name)
      * Timezone
      * Keyboard layout

For convenience, copy your ssh key to the pi: `ssh-copy-id pi@raspi`.
Use `make dist` to create the insatllation tarball, then `scp raspi-multimedia.tar.gz pi@raspi:`.

Log on to the Pi, then:
   * `tar xf raspi-multimedia.tar.gz`
   * `cd target`
   * `./deploy.sh`

Note that I have deliberately left enabled the confirmation prompts of the `apt` package installer, so you'll have to answer "yes" a few times.

This should end with
```
no errors detected
now reboot and check if everything works
```
hopefully, and afterwards everything should just work :-)

Note that you might have to log on once with `ssh -Y pi@raspi pavucontrol` and configure your output device. I have, for example, just disabled the internal sound card completely, so that the external USB sound card is always used.

Have a lot of fun...

## Some technical remarks...

* Bluez uses simple pairing, if the adapter supports it. In this case, you do not get prompted for a PIN during pairing. If the adapter does not support it, then the PIN is hard coded to "0000" in mini-agent.py. The bluetooth adapters in Raspi Zero W and Raspberry Pi 3 do support sspmode, but if you build this with an Raspberry Pi with an older USB BT dongle, it might not be supported. Check the output of `hciconfig get sspmode`. If you just get an error, then it is not supported.

* The services are running in a session of user "pi", because pulseaudio does not really want to run as root. To achieve this, autologin for "pi" on tty1 is enabled.
* The services started (mopidy, mini-agent.py for bluez and the automatic volume adjuster for pulseaudio) are managed by systemd in user-mode. This was chosen mainly, so that `restart=always` can be used to respawn failing processes.
* upmpdcli is running with the default setup in system mode, just `friendlyname` is changed.
--------

The license of all files is WTFPL-2.0, except mini-agent, which, as it is derived from bluez sources, is probably GPL-2.0+.
