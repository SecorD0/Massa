#!/bin/bash
# $1 - Language (RU/EN)
# $2 - Action type
# $3 - Buy for the whole balance? (true/false)
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Colors
W="\e[0m"
G="\e[40m\e[92m"
R="\033[0;31m"
# Texts
if [ "$1" = "RU" ]; then
	t_br1="${R}Баланс менее 100 токенов${W}"
	t_br2="Куплено ${G}%d${W} ROLL'ов"
	t_br3="${G}Введите количество ROLL'ов:${W} "
	t_br4="${R}Недостаточно${W} токенов для покупки, можно купить ${G}%s${W} ROLL'ов"
	t_v="Версия ноды: ${G}%s${W}"
	t_nd1="Запланировано слотов: ${G}%s${W}"
	t_nd2="Слотов ${R}не запланировано${W}, попробуйте позже ${G}ещё раз${W}"
	t_ctrp="${G}Введите Discord ID:${W} "
	t_done="${G}Готово!${W}"
	t_err="${R}Нет такого действия!${W}"
# Send Pull request with new texts to add a language
#elif [ "$1" = ".." ]; then
else
	t_br1="${R}Balance is less than 100 tokens${W}"
	t_br2="${G}%d${W} ROLLs were bought"
	t_br3="${G}Enter a ROLL count:${W} "
	t_br4="${R}Not enough${W} tokens for buying, you can buy ${G}%s${W} ROLLs"
	t_v="The node version: ${G}%s${W}"
	t_nd1="Draws scheduled: ${G}%s${W}"
	t_nd2="${R}No draws scheduled${W}, try ${G}again later${W}"
	t_ctrp="${G}Enter a Discord ID:${W} "
	t_done="${G}Done!${W}"
	t_err="${R}There is no such action!${W}"
fi
# Actions
action="$2"
cd $HOME/massa/massa-client/
wallet_info=`./massa-client --cli true wallet_info`
address=`jq -r ".balances | keys[0]" <<< $wallet_info`
if [ "$action" = "client" ]; then
	./massa-client
elif [ "$action" = "wallet_info" ]; then
	./massa-client --cli false wallet_info
elif [ "$action" = "buy_rolls" ]; then
	balance_float=`jq -r ".balances[].final_ledger_data.balance" <<< $wallet_info`
	balance=`printf "%d" $balance_float 2> /dev/null`
	roll_count=$(($balance/100))
	if [ "$3" = "true" ]; then
		if [ "$roll_count" -eq "0" ]; then
			printf_n "$t_br1"
		else
			./massa-client buy_rolls $address $roll_count 0
			printf_n "$t_br2"
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
	printf "$t_ctrp"
	read -r discord_id
	./massa-client --cli true cmd_testnet_rewards_program $address discord_id
else
	printf_n "$t_err"
fi
cd
