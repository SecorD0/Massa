#!/bin/bash
sudo apt update
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
sudo systemctl stop massad
mkdir $HOME/massa_backup
sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
sudo apt upgrade -y
sudo apt install curl jq pkg-config git build-essential libssl-dev -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
cd $HOME/massa/
git stash
git checkout testnet
git pull
echo -e '\e[40m\e[92mNode installation...\e[0m'
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo build --release
sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
sed -i "s%.*# routable_ip *=.*%routable_ip=\"$(wget -qO- eth0.me)\"%" "$HOME/massa/massa-node/config/config.toml"
sudo systemctl restart massad
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
cd $HOME/massa/massa-client/
cargo build --release
sudo cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
massa_wallet_address=$(cargo run --release -- --cli true wallet_info | jq -r ".balances | keys[]")
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_address" $massa_wallet_address
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_log" "journalctl -f -n 100 -u massad" true "massa_status"
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_client" "cd \$HOME/massa/massa-client/; cargo run --release; cd" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_info" "cd \$HOME/massa/massa-client/; cargo run --release -- --cli false wallet_info 2> /dev/null; cd" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_peers" "cd \$HOME/massa/massa-client/; cargo run --release -- --cli false peers 2> /dev/null; cd" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_version" "cd \$HOME/massa/massa-client/; cargo run --release -- --cli false version 2> /dev/null; cd" true
cargo run --release -- buy_rolls $massa_wallet_address 20 0
cargo run --release -- register_staking_keys $(cargo run --release -- --cli true wallet_info | jq -r ".wallet[0]")
cd
echo -e '\e[40m\e[92mDone!\e[0m'
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the client was \e[40m\e[92mcompiled\e[0m.\n'
echo -e 'Remember to save files in this directory:'
echo -e "\033[0;31m$HOME/massa_backup/\e[0m\n\n"
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To start a client: \e[40m\e[92mmassa_client\e[0m'
echo -e 'To view a wallet info: \e[40m\e[92mmassa_wallet_info\e[0m'
echo -e 'To view peers: \e[40m\e[92mmassa_peers\e[0m'
echo -e 'To view the node status: \e[40m\e[92msystemctl status massad\e[0m'
echo -e 'To view the node log: \e[40m\e[92mmassa_log\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massad\e[0m\n'
