#!/bin/bash
sudo apt update
sudo apt install curl -y
sudo apt install tmux -y
sudo apt install pkg-config curl git build-essential libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup toolchain install nightly
rustup default nightly
cd $HOME
git clone https://gitlab.com/massalabs/massa.git
echo -e '\e[40m\e[92mNode installation...\e[0m'
tmux new-session -d -s massa-node
tmux send-keys 'cd $HOME/massa/massa-node/' 'C-m'
tmux send-keys 'RUST_BACKTRACE=full cargo run --release |& tee logs.txt/' 'C-m'
while [ ! -d $HOME/massa/massa-node/ledger/ ]
do
  sleep 10
done
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mClient installation...\e[0m'
tmux new-session -d -s massa-client
tmux send-keys 'cd $HOME/massa/massa-client/' 'C-m'
tmux send-keys 'cargo run --release' 'C-m'
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
tmux send-keys 'quit' Enter
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\e[40m\e[92mWallet creating...\e[0m'
rm $HOME/massa/massa-client/config/history.txt
tmux send-keys 'cargo run -- --wallet wallet.dat' 'C-m'
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
tmux send-keys 'wallet_new_privkey' Enter
tmux send-keys 'quit' Enter
echo -e '\e[40m\e[92mDone!\e[0m'
echo -e '\nThe node and the client \e[40m\e[92mwere started\e[0m.\n\nCommand to enter node window: \e[40m\e[92mtmux attach -t massa-node\e[0m\nCommand to enter client window: \e[40m\e[92mtmux attach -t massa-client\e[0m\n'