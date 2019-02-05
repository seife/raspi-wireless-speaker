## (C) 2019 Stefan Seyfried
## License: WTFPL-2.0
## This program is free software. It comes without any warranty, to
## the extent permitted by applicable law. You can redistribute it
## and/or modify it under the terms of the Do What The Fuck You Want
## To Public License, Version 2, as published by Sam Hocevar. See
## http://www.wtfpl.net/ for more details. */

default:
	@echo "call 'make dist' to create a tarball"

dist: raspi-multimedia.tar.gz
	@echo
	@echo "copy $< over to the target raspi, unpack, then run"
	@echo "cd target; ./deploy.sh"
	@echo

raspi-multimedia.tar.gz: target/tools/bluez-volume-ng.sh target/tools/mini-agent.py target/systemd/user/gmediarender.service target/systemd/user/mini-agent.service target/systemd/user/bluez-volume.service target/install.sh target/deploy.sh
	tar cvzf $@ target

.PHONY: dist
