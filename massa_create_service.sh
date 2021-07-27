#!/bin/bash
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh | bash
sudo tee <<EOF >/dev/null /etc/systemd/system/massad.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable massad
sudo systemctl daemon-reload
sudo systemctl start massad
echo -e '\e[40m\e[92mDone!\e[0m'
