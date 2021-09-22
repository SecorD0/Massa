#!/bin/bash
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Colors
W="\e[0m"
G="\033[1;32m"
R="\033[0;31m"
B="\033[1;34m"
# Default variables
action=""
language="EN"
raw_output="false"
max_buy="false"
# Options
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo -e "Usage: script ${G}[OPTIONS]${W} ${G}[ARGUMENTS]${W}"
		echo
		echo -e "You can use ${G}either${W} \"=\" or \" \" as an option and value delimiter"
		echo
		echo -e "${G}Options${W}:"
		echo -e "  ${B}-h${W}, --help               show help page"
		echo -e "  ${B}-a${W}, --action ACTION      execute the ACTION"
		echo -e "  ${B}-l${W}, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${G}EN${W}' (default), '${G}RU${W}'"
		echo -e "  ${B}-ro${W}, --raw-output        the raw output in '${G}wallet_info${W}' and ${G}other${W} actions"
		echo -e "  ${B}-mb${W}, --max-buy           buy ROLLs for the whole balance"
		echo
		echo -e "${G}Arguments${W} - any arguments for actions not specified in the script"
		echo
		echo -e "${G}Useful URLs${W}:"
		echo -e "https://github.com/SecorD0/Massa/blob/main/cli_client.sh - script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0
		;;
	-a*|--action*)
		if ! grep -q "=" <<< $1; then shift; fi
		action=`option_value $1`
		shift
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-ro*|--raw-output*)
		raw_output="true"
		shift
		;;
	-mb*|--max-buy*)
		max_buy="true"
		shift
		;;
	*)
		break
		;;
	esac
done
# Texts
if [ "$language" = "RU" ]; then
	t_wi1="${G}Основной кошелёк${W}"
	t_wi2="Адрес кошелька:  ${G}%s${W}"
	t_wi3="Публичный ключ:  ${G}%s${W}"
	t_wi4="Зарегистрирован для стейкинга: ${G}да${W}"
	t_wi5="Зарегистрирован для стейкинга: ${R}нет${W}"
	t_wi6="Баланс:          ${G}%.2f${W}"
	t_wi7="ROLL'ов всего:   ${G}%d${W}"
	t_wi8="Активные ROLL'ы: ${G}%d${W}"
	t_br1="${R}Баланс менее 100 токенов${W}"
	t_br2="Куплено ${G}%d${W} ROLL'ов"
	t_br3="${G}Введите количество ROLL'ов:${W} "
	t_br4="${R}Недостаточно${W} токенов для покупки, можно купить ${G}%s${W} ROLL'ов"
	t_v="Версия ноды: ${G}%s${W}"
	t_nd1="Запланировано слотов: ${G}%s${W}"
	t_nd2="Слотов ${R}не запланировано${W}, попробуйте позже ${G}ещё раз${W}"
	t_ctrp1="${G}Введите Discord ID:${W} "
	t_ctrp2="\nОтправьте Discord боту следующее:\n${G}%s${W}\n"
	t_done="${G}Готово!${W}"
	t_err="${R}Нет такого действия!${W}"
# Send Pull request with new texts to add a language - https://github.com/SecorD0/Massa/blob/main/cli_client.sh
#elif [ "$language" = ".." ]; then
else
	t_wi1="${G}The main wallet${W}"
	t_wi2="Wallet address: ${G}%s${W}"
	t_wi3="Public key:  ${G}%s${W}"
	t_wi4="Registered for staking: ${G}yes${W}"
	t_wi5="Registered for staking: ${R}no${W}"
	t_wi6="Balance:        ${G}%.2f${W}"
	t_wi7="Total ROLLs:    ${G}%d${W}"
	t_wi8="Active ROLLs:   ${G}%d${W}"
	t_br1="${R}Balance is less than 100 tokens${W}"
	t_br2="${G}%d${W} ROLLs were bought"
	t_br3="${G}Enter a ROLL count:${W} "
	t_br4="${R}Not enough${W} tokens for buying, you can buy ${G}%s${W} ROLLs"
	t_v="The node version: ${G}%s${W}"
	t_nd1="Draws scheduled: ${G}%s${W}"
	t_nd2="${R}No draws scheduled${W}, try ${G}again later${W}"
	t_ctrp1="${G}Enter a Discord ID:${W} "
	t_ctrp2="\nSend the following to Discord bot:\n${G}%s${W}\n"
	t_done="${G}Done!${W}"
	t_err="${R}There is no such action!${W}"
fi
# Actions
cd $HOME/massa/massa-client/
wallet_info=`./massa-client --cli true wallet_info`
address=`jq -r ".balances | keys[0]" <<< $wallet_info`
if [ "$action" = "client" ]; then
	./massa-client
elif [ "$action" = "wallet_info" ]; then
	raw=`./massa-client --cli false wallet_info`
	if [ "$raw_output" = "true" ]; then
		printf_n "$raw"
	else
		staking_addresses=`./massa-client --cli true staking_addresses`
		wallets=`jq -r ".balances | to_entries[]" <<< $wallet_info | tr -d '[:space:]' | sed 's%}{%} {%'`
		printf_n "$t_wi1"
		for wallet in $wallets; do
			w_address=`jq -r ".key" <<< $wallet`
			w_pubkey=`printf "$raw" | grep -B 1 "^Address: ${w_address}" | grep -oP "(?<=^Public key: )([^%]+)(?=$)"`
			w_balance=`jq -r ".value.candidate_ledger_data.balance" <<< $wallet`
			w_total_rolls=`jq -r ".value.candidate_rolls" <<< $wallet`
			w_active_rolls=`jq -r ".value.active_rolls" <<< $wallet`
			printf_n "$t_wi2" $w_address
			printf_n "$t_wi3" $w_pubkey
			if grep -q "$w_address" <<< "$staking_addresses"; then
				printf_n "$t_wi4"
			else
				printf_n "$t_wi5"
			fi
			printf_n "$t_wi6" $w_balance
			printf_n "$t_wi7" $w_total_rolls
			printf_n "$t_wi8" $w_active_rolls
			printf_n
		done
	fi
elif [ "$action" = "buy_rolls" ]; then
	balance_float=`jq -r ".balances[].candidate_ledger_data.balance" <<< $wallet_info`
	balance=`printf "%d" $balance_float 2> /dev/null`
	roll_count=$(($balance/100))
	if [ "$max_buy" = "true" ]; then
		if [ "$roll_count" -eq "0" ]; then
			printf_n "$t_br1"
		else
			./massa-client buy_rolls $address $roll_count 0
			printf_n "$t_br2" $roll_count
		fi
	else
		printf "$t_br3"
		read -r rolls_for_buy
		resp=`./massa-client buy_rolls $address $rolls_for_buy 0`
		if grep -q 'not enough coins' <<< "$resp"; then
			printf_n "$t_br4" $roll_count
		else
			printf_n "$t_done"
		fi
	fi
elif [ "$action" = "peers" ]; then
	./massa-client --cli false peers
elif [ "$action" = "version" ]; then
	printf_n "$t_v" `./massa-client --cli true version | jq -r`
elif [ "$action" = "next_draws" ]; then
	draws_count=`./massa-client --cli true next_draws $address | jq length`
	if [ "$draws_count" -gt "0" ]; then
		printf_n "$t_nd1" $draws_count
	else
		printf_n "$t_nd2"
	fi
elif [ "$action" = "register_staking_keys" ]; then
	./massa-client register_staking_keys $(./massa-client --cli true wallet_info | jq -r ".wallet[0]")
	printf_n "$t_done"
elif [ "$action" = "cmd_testnet_rewards_program" ]; then
	printf "$t_ctrp1"
	read -r discord_id
	resp=`./massa-client --cli true cmd_testnet_rewards_program $address $discord_id | grep -oPm1 "(?<=: )([^%]+)(?=$)"`
	printf_n "$t_ctrp2" $resp
else
	resp=`./massa-client --cli "$raw_output" "$action" "$@" 2>&1`
	if grep -q 'error: Found argument' <<< "$resp"; then
		printf_n "$t_err"
	else
		printf_n "$resp"
	fi
fi
cd
