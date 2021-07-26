#!/bin/bash
sudo apt update < "/dev/null"
sudo apt install curl -y < "/dev/null"
curl -s https://raw.githubusercontent.com/SecorD0/Massa/main/logo.sh | bash
sudo apt install pkg-config curl git build-essential libssl-dev < "/dev/null"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
cd $HOME
if [ ! -d $HOME/massa/ ]; then
	git clone https://gitlab.com/massalabs/massa.git
fi
echo -e '\e[40m\e[92mNode installation...\e[0m'
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo run --release compile |& tee logs.txt/ &
while [ ! -d $HOME/massa/massa-node/ledger/ ]
do
  sleep 10
done
kill -9 $(pgrep "massa-node")
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
sudo systemctl restart massa
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
cd $HOME/massa/massa-client/
cargo run --release our_ip
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mWallet creating...\e[0m'
rm $HOME/massa/massa-client/config/history.txt
cargo run -- --wallet wallet.dat wallet_new_privkey
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
cd
echo -e '\e[40m\e[92mDone!\e[0m'
curl -s https://raw.githubusercontent.com/SecorD0/Massa/main/logo.sh | bash
echo -e '\nThe node was \e[40m\e[92mstarted\e[0m, the client was \e[40m\e[92mcompiled\e[0m, the wallet was \e[40m\e[92mcreated\e[0m.\n'
echo -e '\tv \e[40m\e[92mUseful commands\e[0m v\n'
echo -e 'To start a client for blockchain interaction: \e[40m\e[92mcd $HOME/massa/massa-client/; cargo run --release; cd\e[0m'
echo -e 'To start a client for wallet interaction: \e[40m\e[92mcd $HOME/massa/massa-client/; cargo run -- --wallet wallet.dat; cd\e[0m'
echo -e 'To view the node status: \e[40m\e[92msystemctl status massa\e[0m'
echo -e 'To view the node log: \e[40m\e[92mjournalctl -n 100 -f -u massa\e[0m'
echo -e 'To restart the node: \e[40m\e[92msystemctl restart massa\e[0m\n'
