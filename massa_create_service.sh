#!/bin/bash
sudo tee <<EOF >/dev/null /etc/systemd/system/massa.service
[Unit]
Description=Massa Node

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
sudo systemctl enable massa
sudo systemctl daemon-reload
sudo systemctl start massa