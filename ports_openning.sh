#!/bin/bash
iptables -I INPUT -p tcp --dport 31244 -j ACCEPT
iptables -I INPUT -p tcp --dport 31245 -j ACCEPT
IP=$(wget -qO- eth0.me)
sed -i "/\[network\]/a routable_ip=\"$IP\"" "$HOME/massa/massa-node/config/config.toml"
systemctl restart massad
