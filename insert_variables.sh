. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_log -v "sudo journalctl -f -n 100 -u massad" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_client -v "cd \$HOME/massa/massa-client/ \&\& ./massa-client; cd" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_node_info -v "cd \$HOME/massa/massa-client/ \&\& ./massa-client get_status; cd" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_cli_client -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_wallet_info -v "cd \$HOME/massa/massa-client/ \&\& ./massa-client wallet_info; cd" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_buy_rolls -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_peers -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_version -d
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_next_draws -d

#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_client -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a client" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_cli_client -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_wallet_info -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a wallet_info" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_buy_rolls -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a buy_rolls" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_peers -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a peers" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_version -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a version" -a
#. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n massa_next_draws -v ". <(wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/cli_client.sh) -l RU -a next_draws" -a
