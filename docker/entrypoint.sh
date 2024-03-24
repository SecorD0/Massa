#!/bin/bash
if [ ! -f /root/massa/massa-node/massa-node ] || ! grep -q $version <<< `cd /root/massa/massa-node; ./massa-node --version 2>&1; cd`; then
	wget -qO massa.tar.gz "https://github.com/massalabs/massa/releases/download/${version}/massa_${version}_release_linux.tar.gz"
	tar -xvf massa.tar.gz
	rm -rf massa.tar.gz
fi
cd /root/massa/massa-node/
./massa-node "$@"
