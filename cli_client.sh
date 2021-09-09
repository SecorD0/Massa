#!/bin/bash
# $1 - Action type
# $2 - Buy for the whole balance? (true/false)
cd $HOME/massa/massa-client/
wallet_info=`./massa-client --cli true wallet_info`
address=`jq -r ".balances | keys[0]" <<< $wallet_info`
if [ "$1" = "massa_client" ]; then
	./massa-client
elif [ "$1" = "massa_wallet_info" ]; then
	./massa-client --cli false wallet_info
elif [ "$1" = "massa_buy_rolls" ]; then
	if [ "$2" = "true" ]; then
		balance=`printf "%d" jq -r ".balances[0].final_ledger_data.balance" <<< $wallet_info`
		roll_count=$(($balance/100))
	else
		read -p $'\e[40m\e[92mВведите количество покупаемы ROLL\'ов:\e[0m ' roll_count
	fi
	./massa-client buy_rolls $address $roll_count 0
elif [ "$1" = "massa_peers" ]; then
	./massa-client --cli false peers
elif [ "$1" = "massa_version" ]; then
	./massa-client --cli false version
elif [ "$1" = "massa_next_draws" ]; then
	./massa-client next_draws $address
elif [ "$1" = "register_staking_keys" ]; then
	./massa-client register_staking_keys $(./massa-client --cli true wallet_info | jq -r ".wallet[0]")
elif [ "$1" = "cmd_testnet_rewards_program" ]; then
	./massa-client cmd_testnet_rewards_program $address `read -p $'\e[40m\e[92mВведите Discord ID:\e[0m ' R; echo $R`
else
	echo -e "\033[0;31mYou didn't specify an action\e[0m"
fi
cd
