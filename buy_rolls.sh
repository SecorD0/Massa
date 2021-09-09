#!/bin/bash
# $1 - Buy for the whole balance? (true/false)
cd $HOME/massa/massa-client/
wallet_info=`./massa-client --cli true wallet_info`
address=`jq -r ".balances | keys[0]" <<< $wallet_info`
if [ "$1" = "true" ]; then
	balance=`printf "%d" jq -r ".balances[].final_ledger_data.balance" <<< $wallet_info`
	roll_count=$(($balance/100))
else
	read -p $'\e[40m\e[92mВведите количество покупаемы ROLL\'ов:\e[0m ' roll_count
fi
./massa-client buy_rolls $address $roll_count 0; cd
cd