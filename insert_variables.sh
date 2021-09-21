. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_address" $wallet_address
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_log" "sudo journalctl -f -n 100 -u massad" true "massa_status"
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_client" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU client" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_cli_client" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_wallet_info" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU wallet_info" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_buy_rolls" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU buy_rolls" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_peers" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU peers" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_version" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU version" true
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/insert_variable.sh) "massa_next_draws" ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) RU next_draws" true
