#!/bin/bash
systemctl stop massad
if sudo ufw status | grep "Status: active"; then
	sudo ufw allow 31244
	sudo ufw allow 31245
else
	sudo iptables -I INPUT -p tcp --dport 31244 -j ACCEPT
	sudo iptables -I INPUT -p tcp --dport 31245 -j ACCEPT
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
	sudo apt -y install iptables-persistent
	sudo netfilter-persistent save
fi
if ! sudo grep -q "routable_ip" "$HOME/massa/massa-node/config/config.toml"; then
	IP=$(wget -qO- eth0.me)
	sed -i "/\[network\]/a routable_ip=\"$IP\"" "$HOME/massa/massa-node/config/config.toml"
fi
systemctl restart massad