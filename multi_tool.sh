#!/bin/bash
# Default variables
function="install"
source="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script performs many actions related to a Massa node"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h,  --help        show the help page"
		echo -e "  -op, --open-ports  open required ports"
		echo -e "  -s,  --source      install the node using a source code"
		echo -e "  -un, --uninstall   unistall the node"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Massa/blob/main/multi_tool.sh - script URL"
		echo -e "https://t.me/OnePackage — noderun and tech community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-op|--open-ports)
		function="open_ports"
		shift
		;;
	-s|--source)
		function="install_source"
		shift
		;;
	-un|--uninstall)
		function="uninstall"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
open_ports() {
	sudo systemctl stop massad
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/ports_opening.sh) 31244 31245
	sudo tee <<EOF >/dev/null $HOME/massa/massa-node/config/config.toml
[protocol]
routable_ip = "`wget -qO- eth0.me`"
EOF
	sudo systemctl restart massad
}
update() {
	printf_n "${C_LGn}Node updating...${RES}"
	if [ ! -n "$massa_password" ]; then
		printf_n "\n${C_R}There is no massa_password variable with the password, enter it to save it in the variable!${RES}"
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_password
	fi
	if [ ! -n "$massa_password" ]; then
		printf_n "${C_R}There is no massa_password variable with the password!${RES}\n"
		return 1 2>/dev/null; exit 1
	fi
	mkdir -p $HOME/massa_backup
	if [ ! -f $HOME/massa_backup/wallet.dat ]; then
		sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
	fi
	if [ ! -f $HOME/massa_backup/node_privkey.key ]; then
		sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
	fi
	if grep -q "wrong password" <<< `cd $HOME/massa/massa-client/; ./massa-client -p "$massa_password" 2>&1; cd`; then
		printf_n "
${C_R}Wrong password!${RES}
Enter the correct one with the following command and run the script again.
${C_LGn}. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_password${RES}
"
		return 1 2>/dev/null; exit 1
	fi
	local massa_version=`wget -qO- https://api.github.com/repos/massalabs/massa/releases/latest | jq -r ".tag_name"`
	wget -qO $HOME/massa.tar.gz "https://github.com/massalabs/massa/releases/download/${massa_version}/massa_${massa_version}_release_linux.tar.gz"
	if [ `wc -c < "$HOME/massa.tar.gz"` -ge 1000 ]; then
		rm -rf $HOME/massa/
		tar -xvf $HOME/massa.tar.gz
		chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client
		sudo tee <<EOF >/dev/null /etc/systemd/system/massad.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/massa-node/massa-node -p "$massa_password"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
		sudo systemctl enable massad
		sudo systemctl daemon-reload
		sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
		open_ports
		sudo cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/insert_variables.sh)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		printf_n "
The node was ${C_LGn}updated${RES}.

\tv ${C_LGn}Useful commands${RES} v

To run a client: ${C_LGn}massa_client${RES}
To view the node status: ${C_LGn}sudo systemctl status massad${RES}
To view the node log: ${C_LGn}massa_log${RES}
To restart the node: ${C_LGn}sudo systemctl restart massad${RES}

CLI client commands (use ${C_LGn}massa_cli_client -h${RES} to view the help page):
${C_LGn}`compgen -a | grep massa_ | sed "/massa_log/d"`${RES}
"
	else
		printf_n "${C_LR}Archive with binary downloaded unsuccessfully!${RES}\n"
	fi
	rm -rf $HOME/massa.tar.gz
}
install() {
	if [ -d $HOME/massa/ ]; then
		update
	else
		if [ ! -n "$massa_password" ]; then
			printf_n "\n${C_LGn}Come up with a password to encrypt the keys and enter it.${RES}"
			. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_password
		fi
		if [ ! -n "$massa_password" ]; then
			printf_n "${C_R}There is no massa_password variable with the password!${RES}\n"
			return 1 2>/dev/null; exit 1
		fi
		sudo apt update
		sudo apt upgrade -y
		sudo apt install jq curl pkg-config git build-essential libssl-dev -y
		printf_n "${C_LGn}Node installation...${RES}"
		local massa_version=`wget -qO- https://api.github.com/repos/massalabs/massa/releases/latest | jq -r ".tag_name"`
		wget -qO $HOME/massa.tar.gz "https://github.com/massalabs/massa/releases/download/${massa_version}/massa_${massa_version}_release_linux.tar.gz"
		if [ `wc -c < "$HOME/massa.tar.gz"` -ge 1000 ]; then
			tar -xvf $HOME/massa.tar.gz
			rm -rf $HOME/massa.tar.gz
			chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client
			. <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/insert_variables.sh)
			sudo tee <<EOF >/dev/null /etc/systemd/system/massad.service
[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/massa-node/massa-node -p "$massa_password"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
			sudo systemctl enable massad
			sudo systemctl daemon-reload
			open_ports
			cd $HOME/massa/massa-client/
			printf_n "${C_LGn}Waiting for the node to start...${RES}"
			if [ ! -d $HOME/massa_backup ]; then
				while true; do
					if [ -f $HOME/massa/massa-node/config/node_privkey.key ]; then
						./massa-client -p "$massa_password" wallet_generate_secret_key
						mkdir -p $HOME/massa_backup
						sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
						sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
						break
					else
						sleep 5
					fi
				done
				
			else
				sudo cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key
				sudo systemctl restart massad
				sudo cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat	
			fi
			printf_n "${C_LGn}Done!${RES}"
			cd
			. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
			printf_n "
The node was ${C_LGn}started${RES}.

Remember to save files in this directory: ${C_LR}$HOME/massa_backup/${RES}
And password for decryption: ${C_LR}${massa_password}${RES}

\tv ${C_LGn}Useful commands${RES} v

To run a client: ${C_LGn}massa_client${RES}
To view the node status: ${C_LGn}sudo systemctl status massad${RES}
To view the node log: ${C_LGn}massa_log${RES}
To restart the node: ${C_LGn}sudo systemctl restart massad${RES}

CLI client commands (use ${C_LGn}massa_cli_client -h${RES} to view the help page):
${C_LGn}`compgen -a | grep massa_ | sed "/massa_log/d"`${RES}
"
		else
			rm -rf $HOME/massa.tar.gz
			printf_n "${C_LR}Archive with binary downloaded unsuccessfully!${RES}\n"
		fi
	fi
}
install_source() {
	if [ -d $HOME/massa/ ]; then
		printf_n "${C_LR}Node already installed!${RES}"
	else
		sudo apt update
		sudo apt upgrade -y
		sudo apt install jq curl pkg-config git build-essential libssl-dev -y
		printf_n "${C_LGn}Node installation...${RES}"
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/rust.sh) -n
		if [ ! -d $HOME/massa/ ]; then
			git clone --branch testnet https://gitlab.com/massalabs/massa.git
		fi
		cd $HOME/massa/massa-node/
		RUST_BACKTRACE=full cargo build --release
		printf "[Unit]
Description=Massa Node
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/massad.service
		sudo systemctl enable massad
		sudo systemctl daemon-reload
		open_ports
		printf_n "
${C_LGn}Done!${RES}
${C_LGn}Client installation...${RES}
"
		cd $HOME/massa/massa-client/
		cargo run --release wallet_new_privkey
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_log -v "sudo journalctl -f -n 100 -u massad" -a
	fi
	printf_n "${C_LGn}Done!${RES}"
	cd
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
	printf_n "
The node was ${C_LGn}started${RES}.

Remember to save files in this directory:
${C_LR}$HOME/massa_backup/${RES}

\tv ${C_LGn}Useful commands${RES} v

To run a client: ${C_LGn}massa_client${RES}
To view the node status: ${C_LGn}sudo systemctl status massad${RES}
To view the node log: ${C_LGn}massa_log${RES}
To restart the node: ${C_LGn}sudo systemctl restart massad${RES}

CLI client commands (use ${C_LGn}massa_cli_client -h${RES} to view the help page):
${C_LGn}`compgen -a | grep massa_ | sed "/massa_log/d"`${RES}
"
}
uninstall() {
	sudo systemctl stop massad
	if [ ! -d $HOME/massa_backup ]; then
		mkdir $HOME/massa_backup
		sudo cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/wallet.dat
		sudo cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/node_privkey.key
	fi
	if [ -f $HOME/massa_backup/wallet.dat ] && [ -f $HOME/massa_backup/node_privkey.key ]; then
		rm -rf $HOME/massa/ /etc/systemd/system/massa.service /etc/systemd/system/massad.service
		sudo systemctl daemon-reload
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_password -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_log -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_client -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_cli_client -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_node_info -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_wallet_info -da
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_buy_rolls -da
		printf_n "${C_LGn}Done!${RES}"
	else
		printf_n "${C_LR}No backup of the necessary files was found, delete the node manually!${RES}"
	fi	
}
replace_bootstraps() {
	printf_n "This function deprecated!"
	return 0 2>/dev/null; exit 0
	
	local config_path="$HOME/massa/massa-node/base_config/config.toml"
	local bootstrap_list=`wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/bootstrap_list.txt | shuf -n42 | awk '{ print "        "$0"," }'`
	local len=`wc -l < "$config_path"`
	local start=`grep -n bootstrap_list "$config_path" | cut -d: -f1`
	local end=`grep -n "Path to the bootstrap whitelist file. This whitelist define IPs that can bootstrap on your node." "$config_path" | cut -d: -f1`
	local end=$((end-1))
	local first_part=`sed "${start},${len}d" "$config_path"`
	local second_part=`cat <<EOF
    bootstrap_list = [
        ["149.202.86.103:31245", "P12UbyLJDS7zimGWf3LTHe8hYY67RdLke1iDRZqJbQQLHQSKPW8j"],
        ["149.202.89.125:31245", "P12vxrYTQzS5TRzxLfFNYxn6PyEsphKWkdqx2mVfEuvJ9sPF43uq"],
        ["158.69.120.215:31245", "P12rPDBmpnpnbECeAKDjbmeR19dYjAUwyLzsa8wmYJnkXLCNF28E"],
        ["158.69.23.120:31245", "P1XxexKa3XNzvmakNmPawqFrE9Z2NFhfq1AhvV1Qx4zXq5p1Bp9"],
        ["198.27.74.5:31245", "P1qxuqNnx9kyAMYxUfsYiv2gQd5viiBX126SzzexEdbbWd2vQKu"],
        ["198.27.74.52:31245", "P1hdgsVsd4zkNp8cF1rdqqG6JPRQasAmx12QgJaJHBHFU1fRHEH"],
        ["54.36.174.177:31245", "P1gEdBVEbRFbBxBtrjcTDDK9JPbJFDay27uiJRE3vmbFAFDKNh7"],
        ["51.75.60.228:31245", "P13Ykon8Zo73PTKMruLViMMtE2rEG646JQ4sCcee2DnopmVM3P5"],
${bootstrap_list}
    ]
EOF`
	local third_part=`sed "1,${end}d" "$config_path"`
	echo -e "${first_part}\n${second_part}\n${third_part}" > "$config_path"
	sed -i.bak -e "s%retry_delay *=.*%retry_delay = 10000%; " "$config_path"
	printf_n "${C_LGn}Done!${RES}"
	if sudo systemctl status massad 2>&1 | grep -q running; then
		sudo systemctl restart massad
		printf_n "
You can view the node bootstrapping via ${C_LGn}massa_log${RES} command
"
	fi	
}

# Actions
sudo apt install wget -y &>/dev/null
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
cd
$function
