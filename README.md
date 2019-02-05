# Raspberry PI wireless speaker

I created this to use a Raspberry Pi Zero W together with a pair of speakers which already contain an USB sound card (Alesis iM1Active 520USB) to playback via both UPNP/DLNA and Bluetooth A2DP.

Manual setup is quite simple, but this somewhat automates it.

I tested this with on the base of `2018-11-13-raspbian-stretch-lite`, and added just as much as necessary.
`gmediarender` is used as UPNP renderer, `pulseaudio` for bluetooth A2DP.
Some additional stuff (pavucontrol...) is installedto allow easy setup via SSH / X-Forwarding.

So just do the following:
   * write `2018-11-13-raspbian-stretch-lite.img` to SD-Card
   * mount partition 1 of the card, `touch /mnt/ssh`, this enables sshd service on first boot.
   * Connect HDMI Display and Keyboard to the PI, boot up the SD card.
   * Log on, `sudo raspi-config`. Configure the following:
      * Wireless Lan
      * Hostname
      * Timezone
      * Keyboard layout

For convenience, copy your ssh key to the pi: `ssh-copy-id pi@raspi`.
Use `make dist` to create the insatllation tarball, then `scp raspi-multimedia.tar.gz pi@raspi:`.

Log on to the Pi, then:
   * `tar xf raspi-multimedia.tar.gz`
   * `cd target`
   * `./deploy.sh`

Note that I have deliberately left enabled the prompts of the `apt` package installer, so you'll have to answer "yes" a few times.

This should end with
```
no errors detected
now reboot and check if everything works
```
hopefully, and afterwards everything should just work :-)

Have a lot of fun...

## Some technical remarks...

* Bluez uses simple pairing, if the adapter supports it. In this case, you do not get prompted for a PIN during pairing. If the adapter does not support it, then the PIN is hard coded to "0000" in mini-agent.py
* The services are running in a session of user "pi", because pulseaudio does not really want to run as root. To achieve this, autologin for "pi" on tty1 is enabled.
* The services started (gmediarender, mini-agent.py for bluez and the automatic volume adjuster for pulseaudio) are managed by systemd in user-mode. This was chosen mainly, so that `restart=always` can be used to respawn failing processes.
--------

The license of all files is WTFPL-2.0, except mini-agent, which, as it is derived from bluez sources, is probably GPL-2.0+.
