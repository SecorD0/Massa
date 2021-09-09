#!/bin/bash
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
sudo apt update
sudo apt upgrade -y
sudo apt install wget jq unzip git build-essential pkg-config libssl-dev -y
echo -e '\e[40m\e[92mNode installation...\e[0m'
wget -qO massa.zip https://gitlab.com/massalabs/massa/-/jobs/1566540813/artifacts/download
unzip massa.zip
rm -rf massa.zip
sudo tee <<EOF >/dev/null /etc/systemd/system/massad.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/massa-node/massa-node
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable massad
sudo systemctl daemon-reload
sudo systemctl restart massad
cd $HOME/massa/massa-client/
./massa-client wallet_new_privkey
wallet_address="null"
while [ "$wallet_address" = "null" ]
do
	wallet_address=$(./massa-client --cli true wallet_info | jq -r ".balances | keys[-1]")
	continue
done
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_address" $wallet_address
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_log" "sudo journalctl -f -n 100 -u massad" true "massa_status"
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_client" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU client" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_info" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU wallet_info" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_buy_rolls" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU buy_rolls" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_peers" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU peers" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_version" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU version" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_next_draws" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU next_draws" true
cd
mkdir $HOME/massa_backup
sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
echo -e '\e[40m\e[92mDone!\e[0m'
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m!\n'
echo -e 'Remember to save files in this directory:'
echo -e "\033[0;31m$HOME/massa_backup/\e[0m\n\n"
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To start a client: \e[40m\e[92mmassa_client\e[0m'
echo -e 'To view a wallet info: \e[40m\e[92mmassa_wallet_info\e[0m'
echo -e 'To view peers: \e[40m\e[92mmassa_peers\e[0m'
echo -e 'To view the node status: \e[40m\e[92msystemctl status massad\e[0m'
echo -e 'To view the node log: \e[40m\e[92mmassa_log\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massad\e[0m\n'
