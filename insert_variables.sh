. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_log -v "sudo journalctl -fn 100 -u massad" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_client -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a client" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_cli_client -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_node_info -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a node_info" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_wallet_info -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a wallet_info" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_buy_rolls -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a buy_rolls" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_peers -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_version -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_next_draws -d
