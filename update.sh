#!/bin/bash
sudo apt update
sudo apt install curl -y
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh | bash
sudo systemctl stop massad
mkdir $HOME/massa_buckup
sudo mv $HOME/massa/massa-client/wallet.dat $HOME/massa_buckup/wallet.dat
sudo mv $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_buckup/node_privkey.key
sudo rm -rf $HOME/massa
sudo apt upgrade -y
sudo apt install pkg-config curl git build-essential libssl-dev -y
cd
git clone --branch testnet https://gitlab.com/massalabs/massa.git
echo -e '\e[40m\e[92mNode installation...\e[0m'
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo build --release |& tee logs.txt
sudo cp $HOME/massa_buckup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
sudo systemctl start massad
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
cd $HOME/massa/massa-client/
cargo build --release
sudo cp $HOME/massa_buckup/wallet.dat $HOME/massa/massa-client/wallet.dat
massa_wallet_address=$(cargo run --release wallet_info | jq ".balances | keys[]")
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh | bash -s "massa_wallet_address" $massa_wallet_address
cargo run --release -- buy_rolls $massa_wallet_address 20 0
cargo run --release -- register_staking_keys $(cargo run --release wallet_info | jq -r ".wallet[0]")
cd
echo -e '\e[40m\e[92mDone!\e[0m'
curl -s https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh | bash
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the client was \e[40m\e[92mcompiled\e[0m, the wallet was \e[40m\e[92mcreated\e[0m.\n'
echo -e 'Remember to save this files:'
echo -e "\e[40m\e[92m/root/massa/massa-node/config/node_privkey.key\e[0m"
echo -e "\e[40m\e[92m/root/massa/massa-client/wallet.dat\e[0m\n\n"
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To start a client: \e[40m\e[92mcd $HOME/massa/massa-client/; cargo run --release; cd\e[0m'
echo -e 'To view the node status: \e[40m\e[92msystemctl status massad\e[0m'
echo -e 'To view the node log: \e[40m\e[92mjournalctl -n 100 -f -u massad\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massad\e[0m\n'
