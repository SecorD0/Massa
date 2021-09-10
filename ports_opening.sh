#!/bin/bash
systemctl stop massad
if sudo ufw status | grep -q "Status: active"; then
	sudo ufw allow 31244
	sudo ufw allow 31245
else
	sudo iptables -I INPUT -p tcp --dport 31244 -j ACCEPT
	sudo iptables -I INPUT -p tcp --dport 31245 -j ACCEPT
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
	sudo apt install iptables-persistent -y
	sudo netfilter-persistent save
fi
sed -i "s%.*# routable_ip *=.*%routable_ip=\"$(wget -qO- eth0.me)\"%" "$HOME/massa/massa-node/config/config.toml"
sudo apt install net-tools -y
netstat -ntlp | grep "massa-node"
systemctl restart massad
