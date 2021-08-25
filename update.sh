#!/bin/bash
sudo apt update
sudo apt install wget -y
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
sudo systemctl stop massad
mkdir $HOME/massa_buckup
sudo mv $HOME/massa/massa-client/wallet.dat $HOME/massa_buckup/wallet.dat
sudo mv $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_buckup/node_privkey.key
sudo rm -rf $HOME/massa
sudo apt upgrade -y
sudo apt install curl jq pkg-config git build-essential libssl-dev -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
cd
git clone --branch testnet https://gitlab.com/massalabs/massa.git
echo -e '\e[40m\e[92mNode installation...\e[0m'
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo build --release |& tee logs.txt
sudo cp $HOME/massa_buckup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
sed -i "/\[network\]/a routable_ip=\"$(wget -qO- eth0.me)\"" "$HOME/massa/massa-node/config/config.toml"
sudo systemctl start massad
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
cd $HOME/massa/massa-client/
cargo build --release
sudo cp $HOME/massa_buckup/wallet.dat $HOME/massa/massa-client/wallet.dat
massa_wallet_address=$(cargo run --release wallet_info | jq -r ".balances | keys[]")
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_address" $massa_wallet_address
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_client" "cd \$HOME\/massa\/massa-client\/; cargo run --release; cd" true
. <(wget -qO - https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_log" "journalctl -n 100 -f -u massad" true "massa_status"
cargo run --release -- buy_rolls $massa_wallet_address 20 0
cargo run --release -- register_staking_keys $(cargo run --release wallet_info | jq -r ".wallet[0]")
cd
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
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massad\e[0m\n'#
