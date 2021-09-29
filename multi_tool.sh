#!/bin/bash
# Default variables
type="install"
source="false"
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs, updates a Massa node, and opens required ports"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help         show the help page"
		echo -e "  -up, --update      update the node"
		echo -e "  -op, --open-ports  open required ports"
		echo -e "  -s, --source       install the node using a source code"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Massa/blob/main/multi_tool.sh - script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0
		;;
	-up|--update)
		type="update"
		shift
		;;
	-op|--open-ports)
		type="open_ports"
		shift
		;;
	-s|--source)
		source="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
ports_opening() {
	systemctl stop massad
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/ports_opening.sh) 31244 31245
	sed -i "s%.*# routable_ip *=.*%routable_ip=\"$(wget -qO- eth0.me)\"%" "$HOME/massa/massa-node/config/config.toml"
	sudo apt install net-tools -y
	netstat -ntlp | grep "massa-node"
	systemctl restart massad
}
# Actions
sudo apt install wget -y
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
if [ "$type" = "open_ports" ]; then
	ports_opening
elif [ "$type" = "update" ]; then
	printf_n "${C_LGn}Node updating...${RES}"
	rm -rf $HOME/massa/
	wget -qO massa.zip wget -qO massa.zip https://gitlab.com/massalabs/massa/-/jobs/artifacts/testnet/download?job=build-linux
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
	sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
	sed -i "s%.*# routable_ip *=.*%routable_ip=\"$(wget -qO- eth0.me)\"%" "$HOME/massa/massa-node/config/config.toml"
	sudo systemctl restart massad
	cd $HOME/massa/massa-client/
	sudo cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
	wallet_address="null"
	while [ "$wallet_address" = "null" ]; do
		wallet_address=$(./massa-client --cli true wallet_info | jq -r ".balances | keys[-1]")
		continue
	done
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) -n "massa_wallet_address" -v "$wallet_address"
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/insert_variables.sh)
	cd
	printf_n "${C_LGn}Done!${RES}\n"
else
	sudo apt update
	sudo apt upgrade -y
	sudo apt install unzip jq curl pkg-config git build-essential libssl-dev -y
	printf_n "${C_LGn}Node installation...${RES}"
	if [ "$source" = "true" ]; then
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		. $HOME/.cargo/env
		rustup toolchain install nightly
		rustup default nightly
		cd
		if [ ! -d $HOME/massa/ ]; then
			git clone --branch testnet https://gitlab.com/massalabs/massa.git
		fi
		cd $HOME/massa/massa-node/
		RUST_BACKTRACE=full cargo build --release
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
		printf_n "
${C_LGn}Done!${RES}
${C_LGn}Client installation...${RES}
"
		cd $HOME/massa/massa-client/
		cargo run --release wallet_new_privkey
		massa_wallet_address=$(cargo run --release -- --cli true wallet_info | jq -r ".balances | keys[]")
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) -n massa_log -v "sudo journalctl -f -n 100 -u massad" -a
	else
		wget -qO massa.zip https://gitlab.com/massalabs/massa/-/jobs/artifacts/testnet/download?job=build-linux
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
		while [ "$wallet_address" = "null" ]; do
			wallet_address=$(./massa-client --cli true wallet_info | jq -r ".balances | keys[-1]")
			continue
		done
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) -n "massa_wallet_address" -v "$wallet_address"
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/insert_variables.sh)
		mkdir $HOME/massa_backup
		sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
		sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
	fi
	ports_opening
	printf_n "${C_LGn}Done!${RES}"
	cd
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
	printf_n "
The node was ${C_LGn}started${RES}.

Remember to save files in this directory:
${C_LR}$HOME/massa_backup/${RES}

\tv ${C_LGn}Useful commands${RES} v

To start a client: ${C_LGn}massa_client${RES}
To view the node status: ${C_LGn}systemctl status massad${RES}
To view the node log: ${C_LGn}massa_log${RES}
To restart the node: ${C_LGn}systemctl restart massad${RES}

CLI client commands (use ${C_LGn}massa_cli_client -h${RES} to view the help page):
${C_LGn}`compgen -a | grep massa_ | sed "/massa_log/d"`${RES}
"
fi
