#!/bin/bash
sudo apt update
sudo apt install wget -y
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
sudo apt upgrade -y
sudo apt install pkg-config curl git build-essential libssl-dev -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
sudo rustup toolchain install nightly
sudo rustup default nightly
cd
if [ ! -d $HOME/massa/ ]; then
	git clone --branch testnet https://gitlab.com/massalabs/massa.git
fi
echo -e '\e[40m\e[92mNode installation...\e[0m'
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo build --release |& tee logs.txt
sudo tee <<EOF >/dev/null /etc/systemd/system/massad.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable massad
sudo systemctl daemon-reload
sudo systemctl restart massad
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
cd $HOME/massa/massa-client/
cargo run --release wallet_new_privkey
massa_wallet_address=$(cargo run --release wallet_info | jq -r ".balances | keys[]")
cd
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_address" $massa_wallet_address
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_client" "cd \$HOME\/massa\/massa-client\/; cargo run --release; cd" true
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_status" "journalctl -n 100 -f -u massad" true
echo -e '\e[40m\e[92mDone!\e[0m'
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the client was \e[40m\e[92mcompiled\e[0m, the wallet was \e[40m\e[92mcreated\e[0m.\n'
echo -e 'Remember to save this files:'
echo -e "\e[40m\e[92m/root/massa/massa-node/config/node_privkey.key\e[0m"
echo -e "\e[40m\e[92m/root/massa/massa-client/wallet.dat\e[0m\n\n"
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To start a client: \e[40m\e[92mmassa_client\e[0m'
echo -e 'To view the node status: \e[40m\e[92msystemctl status massad\e[0m'
echo -e 'To view the node log: \e[40m\e[92mmassa_status\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massad\e[0m\n'
