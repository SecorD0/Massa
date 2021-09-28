#!/bin/bash
# Default variables
action=""
language="EN"
raw_output="false"
max_buy="false"
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script provides advanced CLI client features"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES} ${C_LGn}[ARGUMENTS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help               show help page"
		echo -e "  -a, --action ACTION      execute the ACTION"
		echo -e "  -l, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -ro, --raw-output        the raw output in '${C_LGn}wallet_info${RES}' and ${C_LGn}other${RES} actions"
		echo -e "  -mb, --max-buy           buy ROLLs for the whole balance when using '${C_LGn}buy_rolls${RES}' command"
		echo
		echo -e "You can use ${C_LGn}either${RES} \"=\" or \" \" as an option and value delimiter"
		echo
		echo -e "${C_LGn}Arguments${RES} - any arguments separated by spaces for actions not specified in the script"
		echo
		echo -e "${C_LGn}Modified actions${RES}:"
		echo -e "  ${C_C}client${RES}                       launches the official GUI client"
		echo -e "  ${C_C}wallet_info${RES}                  shows processed/raw wallet info"
		echo -e "  ${C_C}buy_rolls${RES}                    buys a specified number of ROLLs or for the whole balance"
		echo -e "  ${C_C}peers${RES}                        shows peers"
		echo -e "  ${C_C}version${RES}                      shows the node version"
		echo -e "  ${C_C}next_draws${RES}                   shows next draws"
		echo -e "  ${C_C}register_staking_keys${RES}        registers the private key created first"
		echo -e "  ${C_C}cmd_testnet_rewards_program${RES}  after entering the Discord ID it gives you a hash for"
		echo -e "                               registering in the Discord bot"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Massa/blob/main/cli_client.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
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
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	-mb|--max-buy)
		max_buy="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Texts
if [ "$language" = "RU" ]; then
	t_wi1="Адрес кошелька:  ${C_LGn}%s${RES}"
	t_wi2=" (основной)"
	t_wi3="Публичный ключ:  ${C_LGn}%s${RES}"
	t_wi4="Зарегистрирован для стейкинга: ${C_LGn}да${RES}"
	t_wi5="Зарегистрирован для стейкинга: ${C_R}нет${RES}"
	t_wi6="Баланс:          ${C_LGn}%.2f${RES}"
	t_wi7="ROLL'ов всего:   ${C_LGn}%d${RES}"
	t_wi8="Активные ROLL'ы: ${C_LGn}%d${RES}"
	t_br1="${C_LR}Баланс менее 100 токенов${RES}"
	t_br2="Куплено ${C_LGn}%d${RES} ROLL'ов"
	t_br3="${C_LGn}Введите количество ROLL'ов:${RES} "
	t_br4="${C_LR}Недостаточно${RES} токенов для покупки, можно купить ${C_LGn}%s${RES} ROLL'ов"
	t_v="Версия ноды: ${C_LGn}%s${RES}"
	t_nd1="Запланировано слотов: ${C_LGn}%s${RES}"
	t_nd2="Слотов ${C_LR}не запланировано${RES}, попробуйте позже ${C_LGn}ещё раз${RES}"
	t_ctrp1="${C_LGn}Введите Discord ID:${RES} "
	t_ctrp2="\nОтправьте Discord боту следующее:\n${C_LGn}%s${RES}\n"
	t_done="${C_LGn}Готово!${RES}"
	t_err="${C_LR}Нет такого действия!${RES}"
# Send Pull request with new texts to add a language - https://github.com/SecorD0/Massa/blob/main/cli_client.sh
#elif [ "$language" = ".." ]; then
else
	t_wi1="Wallet address: ${C_LGn}%s${RES}"
	t_wi2=" (the main)"
	t_wi3="Public key:  ${C_LGn}%s${RES}"
	t_wi4="Registered for staking: ${C_LGn}yes${RES}"
	t_wi5="Registered for staking: ${C_LR}no${RES}"
	t_wi6="Balance:        ${C_LGn}%.2f${RES}"
	t_wi7="Total ROLLs:    ${C_LGn}%d${RES}"
	t_wi8="Active ROLLs:   ${C_LGn}%d${RES}"
	t_br1="${C_LR}Balance is less than 100 tokens${RES}"
	t_br2="${C_LGn}%d${RES} ROLLs were bought"
	t_br3="${C_LGn}Enter a ROLL count:${RES} "
	t_br4="${C_LR}Not enough${RES} tokens for buying, you can buy ${C_LGn}%s${RES} ROLLs"
	t_v="The node version: ${C_LGn}%s${RES}"
	t_nd1="Draws scheduled: ${C_LGn}%s${RES}"
	t_nd2="${C_LR}No draws scheduled${RES}, try ${C_LGn}again later${RES}"
	t_ctrp1="${C_LGn}Enter a Discord ID:${RES} "
	t_ctrp2="\nSend the following to Discord bot:\n${C_LGn}%s${RES}\n"
	t_done="${C_LGn}Done!${RES}"
	t_err="${C_LR}There is no such action!${RES}"
fi
# Actions
sudo apt install bc -y &>/dev/null
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
		for wallet in $wallets; do
			w_address=`jq -r ".key" <<< $wallet`
			w_pubkey=`printf "$raw" | grep -B 1 "^Address: ${w_address}" | grep -oP "(?<=^Public key: )([^%]+)(?=$)"`
			w_balance=`jq -r ".value.candidate_ledger_data.balance" <<< $wallet`
			w_total_rolls=`jq -r ".value.candidate_rolls" <<< $wallet`
			w_active_rolls=`jq -r ".value.active_rolls" <<< $wallet`
			printf "$t_wi1" "$w_address"
			if [ "$w_address" = "$address" ]; then
				printf_n "$t_wi2"
			else
				printf "\n"
			fi
			printf_n "$t_wi3" "$w_pubkey"
			if grep -q "$w_address" <<< "$staking_addresses"; then
				printf_n "$t_wi4"
			else
				printf_n "$t_wi5"
			fi
			printf_n "$t_wi6" "$w_balance"
			printf_n "$t_wi7" "$w_total_rolls"
			printf_n "$t_wi8" "$w_active_rolls"
		done
	fi
elif [ "$action" = "buy_rolls" ]; then
	balance_float=`jq -r "[.balances[]] | .[0].candidate_ledger_data.balance" <<< $wallet_info`
	roll_count=`printf "%d" $(bc -l <<< "$balance_float/100") 2>/dev/null`
	if [ "$max_buy" = "true" ]; then
		if [ "$roll_count" -eq "0" ]; then
			printf_n "$t_br1"
		else
			./massa-client buy_rolls "$address" "$roll_count" 0
			printf_n "$t_br2" "$roll_count"
		fi
	else
		printf "$t_br3"
		read -r rolls_for_buy
		resp=`./massa-client buy_rolls $address $rolls_for_buy 0`
		if grep -q 'not enough coins' <<< "$resp"; then
			printf_n "$t_br4" "$roll_count"
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
		printf_n "$t_nd1" "$draws_count"
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
	printf_n "$t_ctrp2" "$resp"
else
	resp=`./massa-client --cli "$raw_output" "$action" "$@" 2>&1`
	if grep -q 'error: Found argument' <<< "$resp"; then
		printf_n "$t_err"
	else
		printf_n "$resp"
	fi
fi
cd
